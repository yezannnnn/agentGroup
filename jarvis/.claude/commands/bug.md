# /bug - 记录Bug

记录Bug到 `../shared/tasks/bugs.md`

## 使用方式
/bug [bug描述]

## 执行步骤

1. 解析bug信息

2. 生成bug ID: BUG-YYYYMMDD-序号

3. 追加到 `../shared/tasks/bugs.md`，格式：
```markdown
## BUG-XXXXXX-XX

- **描述**: xxx
- **发现时间**: YYYY-MM-DD HH:mm
- **严重程度**: 高/中/低
- **状态**: 待修复
- **相关文件**: xxx
- **复现步骤**:
  1. xxx
- **修复记录**:
```

4. 确认记录并询问是否立即处理
