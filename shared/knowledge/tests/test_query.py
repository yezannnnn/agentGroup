import sys
import pytest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent / "agents"))

from db_setup import KnowledgeDB
from query import KnowledgeQuery, QueryResult, ExecutionPath


def _seed_db(db_path: str):
    """插入已知数据供查询测试使用"""
    db = KnowledgeDB(db_path=db_path)
    db.add_entry("bugs", {
        "id": "bugs-test-001",
        "content": "Vue组件v-model失效：根因是父子prop未正确传递，用emit修复父组件状态",
        "metadata": {"agent": "jarvis", "tech_stack": "vue", "quality_score": 0.82,
                     "title": "Vue v-model失效", "key_tags": "vue,props,emit",
                     "project": "test", "compiled_at": "2026-05-18T10:00:00"}
    })
    db.add_entry("decisions", {
        "id": "decisions-test-001",
        "content": "SSE vs WebSocket消息推送：选SSE因为单向推送场景节省50%服务器连接资源",
        "metadata": {"agent": "max", "tech_stack": "sse", "quality_score": 0.80,
                     "title": "消息推送协议选型", "key_tags": "sse,websocket",
                     "project": "test", "compiled_at": "2026-05-18T10:00:00"}
    })


def test_query_returns_results(tmp_path):
    db_path = str(tmp_path / "db")
    _seed_db(db_path)
    q = KnowledgeQuery(db_path=db_path)
    result = q.query("Vue v-model 绑定问题")
    assert isinstance(result, QueryResult)
    assert len(result.matches) > 0


def test_high_similarity_fast_path(tmp_path):
    """相似度 > 0.85 应返回 FAST 路径"""
    db_path = str(tmp_path / "db")
    _seed_db(db_path)
    q = KnowledgeQuery(db_path=db_path)
    result = q.query("Vue v-model失效 父子prop未传递 emit修复")
    if result.top_similarity > 0.85:
        assert result.execution_path == ExecutionPath.FAST


def test_no_match_standard_path(tmp_path):
    """无相关历史时应返回 STANDARD 路径"""
    db_path = str(tmp_path / "db")
    _seed_db(db_path)
    q = KnowledgeQuery(db_path=db_path)
    result = q.query("量子计算芯片散热解决方案")
    assert result.execution_path == ExecutionPath.STANDARD


def test_query_result_format(tmp_path):
    """返回格式必须包含 formatted_output 供检查点4直接展示"""
    db_path = str(tmp_path / "db")
    _seed_db(db_path)
    q = KnowledgeQuery(db_path=db_path)
    result = q.query("Vue 组件调试")
    assert hasattr(result, "formatted_output")
    assert isinstance(result.formatted_output, str)


def test_execution_path_enum_values():
    """ExecutionPath enum must have FAST, REFERENCE, STANDARD"""
    assert ExecutionPath.FAST == "FAST"
    assert ExecutionPath.REFERENCE == "REFERENCE"
    assert ExecutionPath.STANDARD == "STANDARD"


def test_match_entry_has_title_property(tmp_path):
    """MatchEntry.title should fallback to entry_id when not in metadata"""
    db_path = str(tmp_path / "db")
    _seed_db(db_path)
    q = KnowledgeQuery(db_path=db_path)
    result = q.query("Vue v-model 绑定问题")
    for match in result.matches:
        assert isinstance(match.title, str)
        assert len(match.title) > 0
