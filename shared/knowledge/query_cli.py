#!/usr/bin/env python3
"""
主动知识查询CLI
用法: python3 query_cli.py "查询关键词" [collection]
对话中触发: /knowledge "React性能优化"
"""

import sys
from pathlib import Path

_AGENTS_DIR = Path(__file__).parent / "agents"
sys.path.insert(0, str(_AGENTS_DIR))


def main():
    if len(sys.argv) < 2:
        print("用法: python3 query_cli.py '查询关键词' [bugs|decisions|best_practices|projects]")
        sys.exit(1)

    query_text = sys.argv[1]
    target_collection = sys.argv[2] if len(sys.argv) >= 3 else None

    from query import KnowledgeQuery
    from db_setup import KnowledgeDB

    kq = KnowledgeQuery()

    if target_collection:
        db = KnowledgeDB()
        raw = db.query(target_collection, query_text, n_results=5)
        print(f"\n🔍 在 [{target_collection}] 搜索: {query_text}\n")
        if not raw:
            print("  暂无相关记录")
            return
        for entry in raw:
            sim_pct = int(entry["similarity"] * 100)
            title = entry["metadata"].get("title", entry["id"])
            print(f"  [{sim_pct}%] {title}")
            print(f"    {entry['content'][:120]}...")
            print()
    else:
        result = kq.query(query_text, n_per_collection=3)
        print(f"\n🔍 全库搜索: {query_text}")
        print(f"执行路径建议: {result.execution_path.value}")
        print(f"最高相似度: {int(result.top_similarity * 100)}%\n")

        if not result.matches:
            print("  暂无相关历史经验")
            return

        for m in result.matches[:6]:
            sim_pct = int(m.similarity * 100)
            print(f"  {m.collection_emoji}[{m.collection}] [{sim_pct}%] {m.title}")
            print(f"    {m.content[:100]}...")
            print()


if __name__ == "__main__":
    main()
