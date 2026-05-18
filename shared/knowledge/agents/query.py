#!/usr/bin/env python3
"""
知识查询器 — 检查点4调用
返回相似历史经验 + 执行路径建议（FAST/REFERENCE/STANDARD）
"""

from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path
from typing import List, Dict, Any, Optional

_BASE_DIR = Path(__file__).parent.parent

FAST_THRESHOLD = 0.85       # > 0.85 → 跳过探索，直接复用
REFERENCE_THRESHOLD = 0.60  # 0.60-0.85 → 参考历史，仍验证


class ExecutionPath(str, Enum):
    FAST = "FAST"           # 跳过探索，直接展示历史方案
    REFERENCE = "REFERENCE" # 展示历史经验作参考
    STANDARD = "STANDARD"   # 无历史引导，正常流程


@dataclass
class MatchEntry:
    entry_id: str
    collection: str
    content: str
    similarity: float
    metadata: Dict[str, Any] = field(default_factory=dict)

    @property
    def title(self) -> str:
        return self.metadata.get("title", self.entry_id)

    @property
    def collection_emoji(self) -> str:
        return {"bugs": "🐛", "decisions": "⚖️",
                "best_practices": "✨", "projects": "📁"}.get(self.collection, "📄")


@dataclass
class QueryResult:
    matches: List[MatchEntry]
    execution_path: ExecutionPath
    top_similarity: float
    formatted_output: str


class KnowledgeQuery:
    """跨4个collection的知识查询器"""

    def __init__(self, db_path: Optional[str] = None):
        from db_setup import KnowledgeDB
        self.db = KnowledgeDB(db_path=db_path)

    def query(self, task_description: str, n_per_collection: int = 2) -> QueryResult:
        """
        查询与任务描述相关的历史知识。

        Args:
            task_description: 当前任务描述
            n_per_collection: 每个collection最多返回条数

        Returns:
            QueryResult，包含matches列表、执行路径建议、格式化输出
        """
        all_results = self.db.query_all(task_description, n_results=n_per_collection)

        matches: List[MatchEntry] = []
        for collection, entries in all_results.items():
            for e in entries:
                if e["similarity"] > 0.0:
                    matches.append(MatchEntry(
                        entry_id=e["id"],
                        collection=collection,
                        content=e["content"],
                        similarity=e["similarity"],
                        metadata=e["metadata"],
                    ))

        matches.sort(key=lambda m: m.similarity, reverse=True)
        top_similarity = matches[0].similarity if matches else 0.0
        execution_path = self._determine_path(top_similarity)
        formatted = self._format_output(matches[:3], execution_path, top_similarity)

        return QueryResult(
            matches=matches,
            execution_path=execution_path,
            top_similarity=top_similarity,
            formatted_output=formatted,
        )

    def _determine_path(self, top_similarity: float) -> ExecutionPath:
        if top_similarity >= FAST_THRESHOLD:
            return ExecutionPath.FAST
        elif top_similarity >= REFERENCE_THRESHOLD:
            return ExecutionPath.REFERENCE
        return ExecutionPath.STANDARD

    def _format_output(self, top_matches: List[MatchEntry],
                       path: ExecutionPath, top_sim: float) -> str:
        if not top_matches or path == ExecutionPath.STANDARD:
            return ""

        path_labels = {
            ExecutionPath.FAST: "⚡ 快速路径：发现高度相似历史方案，建议直接复用",
            ExecutionPath.REFERENCE: "📖 参考路径：发现相关历史经验，供参考",
        }
        lines = [f"\n🧠 历史经验参考 [{path_labels[path]}]"]
        for m in top_matches:
            sim_pct = int(m.similarity * 100)
            lines.append(f"  {m.collection_emoji}[{m.collection}] {m.title} (相似度: {sim_pct}%)")
            preview = m.content[:80] + "..." if len(m.content) > 80 else m.content
            lines.append(f"    └ {preview}")

        if path == ExecutionPath.FAST:
            lines.append("  ⚡ 建议：跳过探索阶段，直接确认是否采用上述方案")

        return "\n".join(lines)
