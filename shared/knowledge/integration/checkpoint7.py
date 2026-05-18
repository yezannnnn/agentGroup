#!/usr/bin/env python3
"""
检查点7集成 — 任务完成后知识编译入口
用法: python3 checkpoint7.py '{"type":"bug","description":"...","agent":"jarvis"}'
"""

import sys
import json
from pathlib import Path

_AGENTS_DIR = Path(__file__).parent.parent / "agents"
sys.path.insert(0, str(_AGENTS_DIR))


def run_checkpoint7(task_data: dict) -> str:
    """
    执行知识编译，返回格式化输出字符串供Agent展示。
    编译失败时静默返回，不阻断任务完成。
    """
    try:
        from compiler import KnowledgeCompiler
        compiler = KnowledgeCompiler()
        result = compiler.compile(task_data)

        if result["written"]:
            return (
                f"🧠 记忆系统: [编译完成] "
                f"写入 {result['collection']} | "
                f"质量分: {result['quality_score']:.2f} | "
                f"ID: {result['entry_id']}"
            )
        else:
            return f"🧠 记忆系统: [跳过编译] {result['reason']}"

    except Exception as e:
        return f"🧠 记忆系统: [编译异常] {e}"


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("用法: python3 checkpoint7.py '{\"type\":\"bug\",\"description\":\"...\",\"agent\":\"jarvis\"}'")
        sys.exit(1)
    task_data = json.loads(sys.argv[1])
    print(run_checkpoint7(task_data))
