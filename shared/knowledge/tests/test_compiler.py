import sys
import pytest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent / "agents"))

from compiler import KnowledgeCompiler

def test_compile_bug_writes_to_chromadb(tmp_path):
    compiler = KnowledgeCompiler(db_path=str(tmp_path / "db"), use_mock_llm=True,
                                  vault_path=str(tmp_path / "vault"))
    result = compiler.compile({
        "type": "bug",
        "description": "修复Vue v-model绑定失效，根因是父子prop未传递，用emit解决",
        "agent": "jarvis",
        "project": "test_project",
        "tech_stack": "vue"
    })
    assert result["written"] is True
    assert result["collection"] == "bugs"
    assert result["quality_score"] >= 0.6

def test_compile_routine_skipped(tmp_path):
    compiler = KnowledgeCompiler(db_path=str(tmp_path / "db"), use_mock_llm=True,
                                  vault_path=str(tmp_path / "vault"))
    result = compiler.compile({
        "type": "routine",
        "description": "日常代码审查，无异常",
        "agent": "max",
    })
    assert result["written"] is False
    assert "质量分" in result["reason"]

def test_compile_writes_markdown_backup(tmp_path):
    compiler = KnowledgeCompiler(db_path=str(tmp_path / "db"), use_mock_llm=True,
                                  vault_path=str(tmp_path / "vault"))
    result = compiler.compile({
        "type": "bug",
        "description": "修复Vue v-model绑定失效，根因是父子prop未传递，用emit解决",
        "agent": "jarvis",
        "project": "test_project",
    })
    assert result["written"] is True
    markdown_path = Path(result["markdown_path"])
    assert markdown_path.exists()
    content = markdown_path.read_text()
    assert "vue" in content.lower() or "emit" in content.lower()

def test_compile_returns_all_keys(tmp_path):
    compiler = KnowledgeCompiler(db_path=str(tmp_path / "db"), use_mock_llm=True,
                                  vault_path=str(tmp_path / "vault"))
    result = compiler.compile({
        "type": "bug",
        "description": "修复Vue v-model绑定失效，根因是父子prop未传递，用emit解决",
        "agent": "jarvis",
    })
    for key in ("written", "collection", "quality_score", "entry_id", "markdown_path", "reason"):
        assert key in result, f"Missing key: {key}"

def test_compile_entry_id_not_empty_on_success(tmp_path):
    compiler = KnowledgeCompiler(db_path=str(tmp_path / "db"), use_mock_llm=True,
                                  vault_path=str(tmp_path / "vault"))
    result = compiler.compile({
        "type": "decision",
        "description": "选择SSE而非WebSocket用于服务端推送，节省50%连接资源",
        "agent": "max",
    })
    assert result["written"] is True
    assert result["entry_id"] != ""
