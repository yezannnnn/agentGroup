#!/usr/bin/env python3
"""
知识过滤器 — 结构化 Agent 自评结果为 FilterResult
Agent 在检查点7前自我评估质量分和分类，本模块负责数据结构化和阈值判断。
不调用任何外部 API：Agent 自身就是 LLM，已在上下文中完成推理。
"""

from dataclasses import dataclass, field
from typing import Optional, Dict, Any, List

QUALITY_THRESHOLD = 0.6

# Mock响应（use_mock=True时使用，模拟Agent自评结果，仅用于单元测试）
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
    content: str
    metadata: Dict[str, Any] = field(default_factory=dict)
    title: str = ""
    key_tags: List[str] = field(default_factory=list)
    reject_reason: str = ""


class LLMFilter:
    """
    知识过滤器 — 将 Agent 自评数据结构化为 FilterResult。

    正常使用：Agent 自评后传入 pre_evaluated，本类只做阈值判断和结构化。
    测试使用：use_mock=True，使用内置 _MOCK_RESPONSES 模拟自评结果。
    """

    def __init__(self, use_mock: bool = False):
        self.use_mock = use_mock

    def filter(self, content: str, task_type: str = "general",
               extra_metadata: Optional[Dict[str, Any]] = None,
               pre_evaluated: Optional[Dict[str, Any]] = None) -> FilterResult:
        """
        结构化过滤结果。

        Args:
            content:       原始任务描述
            task_type:     任务类型（bug/decision/project/routine/general）
            extra_metadata: 额外元数据（agent/project/tech_stack/compiled_at）
            pre_evaluated: Agent 自评结果，含 quality_score/collection/refined_content

        Returns:
            FilterResult，passed=False 表示质量不足或未提供自评，不应写入
        """
        if pre_evaluated is not None:
            raw = pre_evaluated
        elif self.use_mock:
            raw = _MOCK_RESPONSES.get(task_type, _MOCK_RESPONSES["routine"])
        else:
            # 无预评估且非mock：拒绝并提示Agent需要先自评
            return FilterResult(
                passed=False,
                collection="best_practices",
                quality_score=0.0,
                content="",
                reject_reason="未提供预评估数据：Agent需在调用前自我评估质量分和分类",
            )

        quality_score = float(raw.get("quality_score", 0.0))

        if quality_score < QUALITY_THRESHOLD:
            return FilterResult(
                passed=False,
                collection=raw.get("collection", "best_practices"),
                quality_score=quality_score,
                content="",
                reject_reason=f"质量分 {quality_score:.2f} < 阈值 {QUALITY_THRESHOLD}",
            )

        metadata = dict(extra_metadata) if extra_metadata else {}
        metadata["quality_score"] = quality_score
        metadata["key_tags"] = ",".join(raw.get("key_tags", []))
        metadata["title"] = raw.get("title", "")

        return FilterResult(
            passed=True,
            collection=raw["collection"],
            quality_score=quality_score,
            content=raw.get("refined_content", content),
            metadata=metadata,
            title=raw.get("title", ""),
            key_tags=raw.get("key_tags", []),
        )
