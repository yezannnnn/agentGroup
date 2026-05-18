#!/usr/bin/env python3
"""
知识编译器 — 检查点7入口
流程: Agent自评数据 → 阈值判断 → ChromaDB写入 + Markdown副本
Agent 在调用前已完成质量评估，task_data 中包含 quality_score/collection/refined_content。
"""

import hashlib
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, Optional

_BASE_DIR = Path(__file__).parent.parent
_VAULT_DIR = _BASE_DIR / "vault"

_VAULT_SUBDIRS = {
    "bugs": "Bugs",
    "decisions": "Decisions",
    "best_practices": "BestPractices",
    "projects": "Projects",
}


class KnowledgeCompiler:
    """
    知识编译器：接收任务完成数据，过滤后写入ChromaDB + Markdown副本。
    """

    def __init__(self, db_path: Optional[str] = None, use_mock_llm: bool = False,
                 vault_path: Optional[str] = None):
        from db_setup import KnowledgeDB
        from llm_filter import LLMFilter
        self.db = KnowledgeDB(db_path=db_path)
        self.llm_filter = LLMFilter(use_mock=use_mock_llm)
        self.vault_path = Path(vault_path) if vault_path else _VAULT_DIR
        for subdir in _VAULT_SUBDIRS.values():
            (self.vault_path / subdir).mkdir(parents=True, exist_ok=True)

    def compile(self, task_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        编译一条任务经验。

        task_data 结构:
          type           (str)   — bug/decision/best_practice/project/routine/general
          description    (str)   — 原始任务描述
          agent          (str)   — 执行的agent名称
          project        (str, optional) — 项目名
          tech_stack     (str, optional) — 技术栈
          --- Agent自评字段（有则直接写入，无则走mock/拒绝）---
          quality_score  (float) — Agent自评质量分 0.0-1.0
          collection     (str)   — bugs/decisions/best_practices/projects
          refined_content(str)   — Agent提炼的核心知识（50-200字）
          title          (str, optional) — 简短标题
          key_tags       (list, optional) — 标签列表

        Returns:
          {"written": bool, "collection": str, "quality_score": float,
           "entry_id": str, "markdown_path": str, "reason": str}
        """
        content = task_data.get("description", "")
        task_type = task_data.get("type", "general")

        extra_metadata = {
            "agent": task_data.get("agent", "unknown"),
            "project": task_data.get("project", ""),
            "tech_stack": task_data.get("tech_stack", ""),
            "compiled_at": datetime.now().isoformat(),
        }

        # 检测 Agent 自评字段：有则直接使用，不走LLM
        pre_evaluated = None
        if all(k in task_data for k in ("quality_score", "collection", "refined_content")):
            pre_evaluated = {
                "quality_score": task_data["quality_score"],
                "collection": task_data["collection"],
                "refined_content": task_data["refined_content"],
                "title": task_data.get("title", ""),
                "key_tags": task_data.get("key_tags", []),
            }

        result = self.llm_filter.filter(content, task_type, extra_metadata, pre_evaluated)

        if not result.passed:
            return {
                "written": False,
                "collection": result.collection,
                "quality_score": result.quality_score,
                "entry_id": "",
                "markdown_path": "",
                "reason": result.reject_reason,
            }

        entry_id = self._make_id(result.collection, result.content)

        self.db.add_entry(result.collection, {
            "id": entry_id,
            "content": result.content,
            "metadata": result.metadata,
        })

        md_path = self._write_markdown(entry_id, result)

        return {
            "written": True,
            "collection": result.collection,
            "quality_score": result.quality_score,
            "entry_id": entry_id,
            "markdown_path": str(md_path),
            "reason": "编译成功",
        }

    def _make_id(self, collection: str, content: str) -> str:
        h = hashlib.md5(content.encode()).hexdigest()[:8]
        ts = datetime.now().strftime("%Y%m%d")
        return f"{collection}-{ts}-{h}"

    def _write_markdown(self, entry_id: str, result) -> Path:
        subdir = _VAULT_SUBDIRS.get(result.collection, "BestPractices")
        md_dir = self.vault_path / subdir
        md_path = md_dir / f"{entry_id}.md"
        lines = [
            f"# {result.title or entry_id}",
            "",
            f"**质量分**: {result.quality_score:.2f}  ",
            f"**标签**: {', '.join(result.key_tags)}  ",
            f"**Agent**: {result.metadata.get('agent', '')}  ",
            f"**项目**: {result.metadata.get('project', '')}  ",
            f"**编译时间**: {result.metadata.get('compiled_at', '')}",
            "",
            "---",
            "",
            result.content,
        ]
        md_path.write_text("\n".join(lines), encoding="utf-8")
        return md_path
