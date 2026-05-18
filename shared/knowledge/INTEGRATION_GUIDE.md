# 检查点集成指南

## 检查点4: 知识查询

在任务开始前，调用知识查询功能：

```python
from shared.knowledge.integration.checkpoint4 import checkpoint4_knowledge_query

result = checkpoint4_knowledge_query(task_description, task_type)
output = format_checkpoint_output(result)
print(output)
```

## 检查点7: 知识编译

在任务完成后，调用知识编译功能：

```python
from shared.knowledge.integration.checkpoint7 import checkpoint7_knowledge_compilation

task_data = {
    'task_id': task_id,
    'description': description,
    'type': task_type,
    'solution': solution,
    'skills_used': skills_used,
    'success': True
}

result = checkpoint7_knowledge_compilation(task_data)
output = format_checkpoint_output(result)
print(output)
```

## 安装日期
2026-05-17 23:35:17

## 状态
系统已就绪，可以开始使用。
