#!/usr/bin/env python3
"""
LLM质量过滤器
在知识写入ChromaDB前：提炼内容、打质量分、分类到正确collection
"""

import os
import json
import re
from dataclasses import dataclass, field
from typing import Optional, Dict, Any

QUALITY_THRESHOLD = 0.6

CLASSIFICATION_PROMPT = """你是aiGroup知识库的质量过滤器。分析以下任务经验，判断是否值得写入知识库。

任务描述: {content}
任务类型: {task_type}

评估标准:
- 0.0-0.5: 常规执行，无新知识（日常报告、状态更新、简单重复操作）
- 0.6-0.75: 有一定参考价值（解决了常见问题，有明确步骤）
- 0.76-0.9: 高价值（解决了复杂问题，有根因分析，或做了有权衡的决策）
- 0.91-1.0: 极高价值（解决了罕见问题，发现了重要规律，有显著效果数据）

Collection分类规则:
- bugs: 包含bug描述+根因+解决方案
- decisions: 包含方案对比+选择理由+权衡
- best_practices: 包含可复用的做法/模式/工作流
- projects: 包含项目架构/框架/核心模块描述

以JSON格式返回（不要markdown代码块）:
{{
  "quality_score": 0.0-1.0,
  "collection": "bugs|decisions|best_practices|projects",
  "refined_content": "提炼后的核心知识（去除过程噪音，保留洞察，50-200字）",
  "title": "简短标题（15字以内）",
  "key_tags": ["标签1", "标签2"]
}}"""

# Mock响应（use_mock=True时使用，避免测试消耗API）
_MOCK_RESPONSES = {
    "routine": {"quality_score": 0.3, "collection": "best_practices",
                "refined_content": "常规操作", "title": "日常任务", "key_tags": []},
    "bug": {"quality_score": 0.82, "collection": "bugs",
            "refined_content": "Vue v-model失效：根因是父子prop未正确传递，用emit修复",
            "title": "Vue v-model绑定失效", "key_tags": ["vue", "props", "emit"]},
    "decision": {"quality_score": 0.80, "collection": "decisions",
                 "refined_content": "SSE vs WebSocket：服务端推送选SSE，节省50%连接资源",
                 "title": "消息推送协议选型", "key_tags": ["sse", "websocket"]},
    "project": {"quality_score": 0.85, "collection": "projects",
                "refined_content": "WeChatPadPro: FastAPI+Vue3+Redis, 核心routes/v1_webhook.py",
                "title": "WeChatPadPro架构", "key_tags": ["fastapi", "vue3", "redis"]},
}


@dataclass
class FilterResult:
    passed: bool
    collection: str
    quality_score: float
    content: str          # 提炼后的内容
    metadata: Dict[str, Any] = field(default_factory=dict)
    title: str = ""
    key_tags: list = field(default_factory=list)
    reject_reason: str = ""


class LLMFilter:
    """LLM质量过滤器，支持mock模式用于测试"""

    def __init__(self, use_mock: bool = False):
        self.use_mock = use_mock
        if not use_mock:
            import anthropic
            self.client = anthropic.Anthropic(api_key=os.environ.get("ANTHROPIC_API_KEY"))

    def filter(self, content: str, task_type: str = "general",
               extra_metadata: Optional[Dict] = None) -> FilterResult:
        """
        过滤并提炼知识条目。

        Args:
            content: 原始任务描述/经验
            task_type: 任务类型提示（bug/decision/project/general/routine）
            extra_metadata: 额外元数据（agent/project/tech_stack等）

        Returns:
            FilterResult，passed=False 表示质量不足，不应写入
        """
        if self.use_mock:
            raw = _MOCK_RESPONSES.get(task_type, _MOCK_RESPONSES["routine"])
        else:
            raw = self._call_llm(content, task_type)

        quality_score = raw.get("quality_score", 0.0)

        if quality_score < QUALITY_THRESHOLD:
            return FilterResult(
                passed=False,
                collection=raw.get("collection", "best_practices"),
                quality_score=quality_score,
                content="",
                reject_reason=f"质量分 {quality_score:.2f} < 阈值 {QUALITY_THRESHOLD}",
            )

        metadata = extra_metadata or {}
        metadata["quality_score"] = quality_score
        metadata["key_tags"] = ",".join(raw.get("key_tags", []))
        metadata["title"] = raw.get("title", "")

        return FilterResult(
            passed=True,
            collection=raw["collection"],
            quality_score=quality_score,
            content=raw["refined_content"],
            metadata=metadata,
            title=raw.get("title", ""),
            key_tags=raw.get("key_tags", []),
        )

    def _call_llm(self, content: str, task_type: str) -> Dict:
        prompt = CLASSIFICATION_PROMPT.format(content=content, task_type=task_type)
        message = self.client.messages.create(
            model="claude-haiku-4-5-20251001",
            max_tokens=512,
            messages=[{"role": "user", "content": prompt}],
        )
        text = message.content[0].text.strip()
        # 去除可能的markdown包裹
        text = re.sub(r"^```(?:json)?\s*|\s*```$", "", text, flags=re.MULTILINE)
        return json.loads(text)
