# /todo - 待办事项管理

管理个人待办事项

## 使用方式

```
/todo                        # 查看所有待办
/todo add [内容]             # 添加待办
/todo done [序号]            # 完成待办
/todo del [序号]             # 删除待办
/todo remind [序号] [提前N分钟]  # 为待办设置系统提醒
```

## 执行步骤

### 查看待办 (/todo)
1. 读取 `./todos.md`
2. 按优先级和状态分组展示：
   - 🔴 紧急
   - 🟡 普通
   - ✅ 已完成（最近3条）

### 添加待办 (/todo add)
1. 解析内容，识别优先级标记（!紧急）
2. 追加到 `./todos.md`
3. 确认添加成功

### 完成待办 (/todo done)
1. 将指定待办标记为已完成
2. 记录完成时间
3. 询问是否有后续任务

### 删除待办 (/todo del)
1. 确认删除
2. 从列表移除

### 设置提醒 (/todo remind)
1. 解析待办序号和提前提醒时间（默认5分钟）
2. 从待办中提取时间信息
3. 计算提醒时间（待办时间 - 提前分钟数）
4. 使用 macOS 提醒事项 App 添加系统提醒：
   ```bash
   osascript <<'EOF'
   tell application "Reminders"
       set theDate to current date
       set hours of theDate to [提醒小时]
       set minutes of theDate to [提醒分钟]
       set seconds of theDate to 0
       tell default list
           make new reminder with properties {name:"[待办标题]", body:"[原始时间] 开始", due date:theDate, remind me date:theDate}
       end tell
   end tell
   EOF
   ```
5. 确认提醒设置成功

### 添加待办时快捷设置提醒
在 `/todo add` 时，如果内容包含具体时间，询问用户是否需要设置系统提醒
