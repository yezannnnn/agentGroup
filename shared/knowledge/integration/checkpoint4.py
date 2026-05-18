#!/usr/bin/env python3
"""
检查点4集成: 知识查询
在任务开始前查询相关知识和推荐Skills
"""

import sys
import json
from pathlib import Path

# 添加agents目录到路径
sys.path.append(str(Path(__file__).parent.parent / "agents"))

from query import KnowledgeQueryAgent

def checkpoint4_knowledge_query(task_description: str, task_type: str = "general") -> dict:
    """
    检查点4: 智能知识查询

    Args:
        task_description: 任务描述
        task_type: 任务类型

    Returns:
        查询结果，包含推荐Skills和相关经验
    """
    try:
        vault_path = Path(__file__).parent.parent / "vault"
        agent = KnowledgeQueryAgent(str(vault_path))

        result = agent.query_knowledge(task_description, task_type)

        # 格式化为检查点输出
        output = {
            "checkpoint": "4-knowledge-query",
            "status": "completed",
            "query": task_description,
            "recommendations": {
                "skills": result.get('recommended_skills', []),
                "approach": result.get('suggested_approach', ''),
                "similar_cases": len(result.get('similar_cases', [])),
                "confidence": result.get('analysis', {}).get('confidence', 0.5)
            },
            "knowledge_found": len(result.get('related_documents', [])),
            "potential_issues": result.get('potential_issues', [])
        }

        return output

    except Exception as e:
        return {
            "checkpoint": "4-knowledge-query",
            "status": "error",
            "error": str(e),
            "fallback": {
                "skills": ["systematic-debugging"],
                "approach": "使用标准流程处理"
            }
        }

def format_checkpoint_output(result: dict) -> str:
    """格式化检查点输出"""
    if result["status"] == "error":
        return f"""🧰 检查点4: Skill检查 [知识查询失败]
⚠️ 知识库查询错误: {result['error']}
📋 默认建议: {', '.join(result['fallback']['skills'])}"""

    skills = result['recommendations']['skills']
    confidence = result['recommendations']['confidence']
    knowledge_count = result['knowledge_found']

    confidence_emoji = "🎯" if confidence > 0.8 else "📋" if confidence > 0.5 else "⚠️"

    output = f"""🧰 检查点4: Skill智能识别 [知识库增强] {confidence_emoji}
🔍 知识查询: 找到 {knowledge_count} 个相关经验
📋 推荐Skills: {', '.join(skills) if skills else '无特定建议'}
💡 建议方法: {result['recommendations']['approach'][:100]}...
🎯 置信度: {confidence:.1%}"""

    if result['potential_issues']:
        output += f"\n⚠️ 注意事项: {', '.join(result['potential_issues'][:2])}"

    return output

def main():
    """命令行测试"""
    if len(sys.argv) < 2:
        print("用法: python checkpoint4.py '任务描述' [任务类型]")
        sys.exit(1)

    task_desc = sys.argv[1]
    task_type = sys.argv[2] if len(sys.argv) > 2 else "general"

    result = checkpoint4_knowledge_query(task_desc, task_type)
    output = format_checkpoint_output(result)

    print(output)
    print("\n" + "="*50)
    print(json.dumps(result, ensure_ascii=False, indent=2))

if __name__ == "__main__":
    main()