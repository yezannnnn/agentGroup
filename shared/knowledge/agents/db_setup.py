#!/usr/bin/env python3
"""
ChromaDB 4-Collection 初始化
知识库存储层，4个独立collection对应4种知识类型
"""

import chromadb
from pathlib import Path
from typing import List, Dict, Any, Optional

_BASE_DIR = Path(__file__).parent.parent

COLLECTIONS = {
    "bugs": "Bug记录：根因分析和解决方案",
    "decisions": "技术/产品决策和教训",
    "best_practices": "代码/设计/测试最佳实践",
    "projects": "项目技术架构和框架概览",
}


class KnowledgeDB:
    """ChromaDB知识库，管理4个独立collection"""

    def __init__(self, db_path: Optional[str] = None):
        if db_path is None:
            db_path = str(_BASE_DIR / "chromadb")
        Path(db_path).mkdir(parents=True, exist_ok=True)
        self.client = chromadb.PersistentClient(path=db_path)
        self._ensure_collections()

    def _ensure_collections(self):
        self._collections = {}
        for name, description in COLLECTIONS.items():
            self._collections[name] = self.client.get_or_create_collection(
                name=name,
                metadata={"description": description, "hnsw:space": "cosine"}
            )

    def list_collections(self) -> List[str]:
        return list(self._collections.keys())

    def add_entry(self, collection: str, entry: Dict[str, Any]) -> None:
        """
        写入一条知识条目，重复ID自动覆盖。
        entry: {id: str, content: str, metadata: dict}
        """
        if collection not in self._collections:
            raise ValueError(f"Unknown collection: {collection}. Valid: {list(self._collections)}")
        required_keys = {"id", "content", "metadata"}
        missing = required_keys - entry.keys()
        if missing:
            raise ValueError(f"entry missing required keys: {missing}")
        col = self._collections[collection]
        existing = col.get(ids=[entry["id"]])
        if existing["ids"]:
            col.update(
                ids=[entry["id"]],
                documents=[entry["content"]],
                metadatas=[entry["metadata"]],
            )
        else:
            col.add(
                ids=[entry["id"]],
                documents=[entry["content"]],
                metadatas=[entry["metadata"]],
            )

    def query(self, collection: str, query_text: str, n_results: int = 5,
              where: Optional[Dict] = None) -> List[Dict[str, Any]]:
        """
        语义搜索，返回带相似度分数的结果列表。
        Returns: [{"id": str, "content": str, "metadata": dict, "similarity": float}]
        """
        if collection not in self._collections:
            raise ValueError(f"Unknown collection: {collection}. Valid: {list(self._collections)}")
        col = self._collections[collection]
        if col.count() == 0:
            return []
        kwargs = {"query_texts": [query_text], "n_results": min(n_results, col.count())}
        if where:
            kwargs["where"] = where
        results = col.query(**kwargs)
        output = []
        for i, doc_id in enumerate(results["ids"][0]):
            distance = results["distances"][0][i]
            # cosine distance in [0,1] for normalized embeddings; clamp defensively
            similarity = max(0.0, 1.0 - distance)
            output.append({
                "id": doc_id,
                "content": results["documents"][0][i],
                "metadata": results["metadatas"][0][i],
                "similarity": round(similarity, 4),
            })
        return output

    def query_all(self, query_text: str, n_results: int = 3) -> Dict[str, List[Dict]]:
        """跨所有4个collection查询，每个返回top n_results"""
        return {
            name: self.query(name, query_text, n_results)
            for name in self._collections
        }

    def count(self, collection: str) -> int:
        if collection not in self._collections:
            raise ValueError(f"Unknown collection: {collection}. Valid: {list(self._collections)}")
        return self._collections[collection].count()
