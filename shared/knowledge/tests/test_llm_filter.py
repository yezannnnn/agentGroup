# shared/knowledge/tests/test_llm_filter.py
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent / "agents"))

from llm_filter import LLMFilter, FilterResult

def test_filter_result_structure():
    """FilterResult 必须有 passed/collection/quality_score/content/metadata 字段"""
    r = FilterResult(
        passed=True,
        collection="bugs",
        quality_score=0.85,
        content="测试内容",
        metadata={"agent": "jarvis"}
    )
    assert r.passed is True
    assert r.collection == "bugs"
    assert 0.0 <= r.quality_score <= 1.0

def test_low_quality_rejected():
    """质量分 < 0.6 的条目应被拒绝"""
    f = LLMFilter(use_mock=True)
    result = f.filter("完成了日常代码审查", task_type="routine")
    assert result.passed is False
    assert result.quality_score < 0.6

def test_bug_classified_correctly():
    """包含 bug 解决方案的任务应分类到 bugs collection"""
    f = LLMFilter(use_mock=True)
    result = f.filter(
        "修复了Vue组件中v-model绑定失效问题，根因是父子组件prop未正确传递，解决方案是使用emit更新父组件状态",
        task_type="bug"
    )
    assert result.passed is True
    assert result.collection == "bugs"
    assert result.quality_score >= 0.6

def test_decision_classified_correctly():
    """技术方案选择应分类到 decisions collection"""
    f = LLMFilter(use_mock=True)
    result = f.filter(
        "评估了WebSocket和SSE两种方案，选择SSE因为服务端推送场景下SSE无需维护双向连接，降低50%服务器资源消耗",
        task_type="decision"
    )
    assert result.passed is True
    assert result.collection == "decisions"

def test_project_classified_correctly():
    """项目架构描述应分类到 projects collection"""
    f = LLMFilter(use_mock=True)
    result = f.filter(
        "WeChatPadPro项目：FastAPI后端 + Vue3前端 + Redis缓存，核心模块routes/v1_webhook.py处理消息推送",
        task_type="project"
    )
    assert result.passed is True
    assert result.collection == "projects"
