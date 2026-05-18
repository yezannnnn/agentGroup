import sys
import pytest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent / "agents"))

from db_setup import KnowledgeDB

def test_collections_created(tmp_path):
    db = KnowledgeDB(db_path=str(tmp_path))
    collections = db.list_collections()
    assert "bugs" in collections
    assert "decisions" in collections
    assert "best_practices" in collections
    assert "projects" in collections

def test_collection_metadata_schema(tmp_path):
    db = KnowledgeDB(db_path=str(tmp_path))
    db.add_entry("bugs", {
        "id": "test-bug-001",
        "content": "Vue组件状态丢失",
        "metadata": {"severity": "medium", "agent": "jarvis", "tech_stack": "vue", "project": "test"}
    })
    result = db.query("bugs", "Vue状态", n_results=1)
    assert len(result) == 1
    assert result[0]["metadata"]["severity"] == "medium"

def test_duplicate_prevention(tmp_path):
    db = KnowledgeDB(db_path=str(tmp_path))
    entry = {"id": "dup-001", "content": "重复测试", "metadata": {"agent": "max"}}
    db.add_entry("decisions", entry)
    db.add_entry("decisions", entry)
    results = db.query("decisions", "重复测试", n_results=10)
    ids = [r["id"] for r in results]
    assert ids.count("dup-001") == 1

def test_unknown_collection_raises(tmp_path):
    db = KnowledgeDB(db_path=str(tmp_path))
    with pytest.raises(ValueError, match="Unknown collection"):
        db.add_entry("nonexistent", {"id": "x", "content": "y", "metadata": {}})
    with pytest.raises(ValueError, match="Unknown collection"):
        db.query("nonexistent", "test")
    with pytest.raises(ValueError, match="Unknown collection"):
        db.count("nonexistent")


def test_add_entry_missing_keys_raises(tmp_path):
    db = KnowledgeDB(db_path=str(tmp_path))
    with pytest.raises(ValueError, match="missing required keys"):
        db.add_entry("bugs", {"id": "x"})  # missing content and metadata


def test_query_all_returns_all_collections(tmp_path):
    db = KnowledgeDB(db_path=str(tmp_path))
    db.add_entry("bugs", {"id": "b1", "content": "memory leak in worker", "metadata": {"type": "bug"}})
    results = db.query_all("memory leak", n_results=1)
    assert set(results.keys()) == {"bugs", "decisions", "best_practices", "projects"}
    assert len(results["bugs"]) == 1
    assert results["bugs"][0]["id"] == "b1"
