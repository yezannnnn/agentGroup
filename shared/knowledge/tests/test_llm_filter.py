# shared/knowledge/tests/test_llm_filter.py
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent / "agents"))

import pytest
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
    """质量分 < 0.6 的条目应被拒绝（mock模式）"""
    f = LLMFilter(use_mock=True)
    result = f.filter("完成了日常代码审查", task_type="routine")
    assert result.passed is False
    assert result.quality_score < 0.6

def test_bug_classified_correctly():
    """mock模式：bug类型分类到 bugs collection"""
    f = LLMFilter(use_mock=True)
    result = f.filter(
        "修复了Vue组件中v-model绑定失效问题",
        task_type="bug"
    )
    assert result.passed is True
    assert result.collection == "bugs"
    assert result.quality_score >= 0.6

def test_decision_classified_correctly():
    """mock模式：decision类型分类到 decisions collection"""
    f = LLMFilter(use_mock=True)
    result = f.filter("评估了WebSocket和SSE", task_type="decision")
    assert result.passed is True
    assert result.collection == "decisions"

def test_project_classified_correctly():
    """mock模式：project类型分类到 projects collection"""
    f = LLMFilter(use_mock=True)
    result = f.filter("WeChatPadPro项目架构", task_type="project")
    assert result.passed is True
    assert result.collection == "projects"

def test_pre_evaluated_used_directly():
    """pre_evaluated 数据直接使用，不走 mock，不调任何 API"""
    f = LLMFilter(use_mock=False)  # 非mock模式
    result = f.filter(
        "任意描述",
        task_type="general",
        pre_evaluated={
            "quality_score": 0.88,
            "collection": "decisions",
            "refined_content": "选择PostgreSQL而非MySQL，原因是JSONB支持和窗口函数",
            "title": "数据库选型",
            "key_tags": ["postgresql", "database"],
        }
    )
    assert result.passed is True
    assert result.collection == "decisions"
    assert result.quality_score == 0.88
    assert "PostgreSQL" in result.content

def test_pre_evaluated_low_quality_rejected():
    """pre_evaluated 质量分低时仍被拒绝"""
    f = LLMFilter(use_mock=False)
    result = f.filter(
        "日常任务",
        pre_evaluated={
            "quality_score": 0.3,
            "collection": "best_practices",
            "refined_content": "常规操作",
        }
    )
    assert result.passed is False
    # LLMFilter.reject_reason always starts with "质量分" when score < 0.6
    assert "质量分" in result.reject_reason

def test_no_pre_evaluated_no_mock_rejected():
    """无预评估、非mock模式时拒绝并给出明确提示"""
    f = LLMFilter(use_mock=False)
    result = f.filter("未提供自评的任务", task_type="bug")
    assert result.passed is False
    assert "自我评估" in result.reject_reason

def test_extra_metadata_not_mutated():
    """filter() 不得修改调用方传入的 dict"""
    f = LLMFilter(use_mock=True)
    meta = {"agent": "jarvis", "project": "test"}
    original_keys = set(meta.keys())
    f.filter("修复了Vue v-model问题", task_type="bug", extra_metadata=meta)
    assert set(meta.keys()) == original_keys
