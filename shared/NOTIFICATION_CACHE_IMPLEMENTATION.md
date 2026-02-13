# 基于文件时间戳的智能通知缓存机制

**版本**: v1.0.0
**创建日期**: 2026-02-13
**作者**: 麦克斯 (Max)
**适用范围**: aiGroup团队所有AI成员

---

## 一、核心设计理念

### 问题背景
传统通知系统需要每次会话都完整读取通知文件，导致：
- 重复读取已处理的通知（Token浪费）
- 无法区分"新通知"和"已读通知"
- 缺乏通知状态的持久化跟踪

### 解决方案
基于文件修改时间戳（mtime）的智能缓存机制：
- 只在文件有变化时才重新读取
- 持久化每个AI的检查状态
- 零额外存储成本（利用文件系统原生mtime）

---

## 二、文件结构说明

### 2.1 `.notification_cache.json`（缓存文件）

**位置**: `/Users/yuhao/Desktop/yezannnnn/aiGroup/shared/.notification_cache.json`

**核心字段说明**:

```json
{
  "ai_agents": {
    "max": {
      "last_check_timestamp": "会话启动时间（ISO 8601）",
      "last_notification_mtime": "上次检查时notifications.json的mtime（Unix时间戳）",
      "unread_count": "未读通知数量",
      "last_read_notification_id": "最后读取的通知ID"
    }
  },
  "file_mtimes": {
    "notifications.json": "上次记录的mtime",
    "status.json": "上次记录的mtime",
    "tasks/todos.md": "上次记录的mtime"
  }
}
```

**字段用途**:
- `last_check_timestamp`: 会话级别的时间戳，用于判断是否需要全量检查
- `last_notification_mtime`: 文件级别的mtime，用于判断文件是否修改
- `unread_count`: 快速判断是否有新通知，无需读取完整文件
- `last_read_notification_id`: 用于增量读取，只处理新增通知

### 2.2 `notifications.json`（通知文件）

**位置**: `/Users/yuhao/Desktop/yezannnnn/aiGroup/shared/notifications.json`

**通知结构**:

```json
{
  "notifications": [
    {
      "id": "唯一标识符（notif_YYYYMMDD_序号）",
      "timestamp": "创建时间（ISO 8601）",
      "priority": "优先级（high/normal/low）",
      "type": "通知类型（task_assignment/review_request/information/alert）",
      "from": "发送者（AI名称或system）",
      "to": "接收者（AI名称或all）",
      "subject": "通知标题",
      "content": {
        "自定义内容结构，根据type不同而变化"
      },
      "actions": [
        {
          "label": "操作按钮文本",
          "action": "操作类型",
          "target": "操作目标"
        }
      ],
      "read_by": ["已读AI列表"],
      "acknowledged_by": ["已确认AI列表"],
      "expires_at": "过期时间（ISO 8601）"
    }
  ]
}
```

**通知类型定义**:

| type | 说明 | 典型使用场景 | priority建议 |
|------|------|--------------|--------------|
| `task_assignment` | 任务分配 | 麦克斯分配任务给成员 | high/normal |
| `review_request` | 审核请求 | 贾维斯请求凯尔测试 | normal |
| `information` | 信息通知 | 会议提醒、状态更新 | low |
| `alert` | 警报提醒 | Token超限、系统错误 | high |

---

## 三、时间戳检查实现（核心）

### 3.1 获取文件mtime的Bash命令

#### macOS/BSD系统
```bash
stat -f %m /path/to/file
```

**输出**: Unix时间戳（秒级，例如：1707825600）

#### Linux系统
```bash
stat -c %Y /path/to/file
```

**输出**: Unix时间戳（秒级）

#### 跨平台兼容方案（推荐）
```bash
# 检测系统类型并使用对应命令
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  FILE_MTIME=$(stat -f %m "/path/to/file")
else
  # Linux
  FILE_MTIME=$(stat -c %Y "/path/to/file")
fi

echo "$FILE_MTIME"
```

### 3.2 完整检查流程的Bash脚本

#### 场景1: AI会话启动时的通知检查

```bash
#!/bin/bash

# 配置
AI_NAME="max"  # 当前AI名称（max/ella/jarvis/kyle）
SHARED_DIR="/Users/yuhao/Desktop/yezannnnn/aiGroup/shared"
CACHE_FILE="$SHARED_DIR/.notification_cache.json"
NOTIFICATION_FILE="$SHARED_DIR/notifications.json"

# 1. 获取当前notifications.json的mtime
if [[ "$OSTYPE" == "darwin"* ]]; then
  CURRENT_MTIME=$(stat -f %m "$NOTIFICATION_FILE")
else
  CURRENT_MTIME=$(stat -c %Y "$NOTIFICATION_FILE")
fi

# 2. 读取缓存中的last_notification_mtime（需要jq工具）
CACHED_MTIME=$(jq -r ".ai_agents.$AI_NAME.last_notification_mtime" "$CACHE_FILE")

# 3. 比较时间戳
if [ "$CURRENT_MTIME" -gt "$CACHED_MTIME" ]; then
  echo "检测到新通知！文件已修改"
  echo "缓存mtime: $CACHED_MTIME"
  echo "当前mtime: $CURRENT_MTIME"

  # 标记：需要读取notifications.json
  NEED_READ=true
else
  echo "无新通知，跳过读取"
  NEED_READ=false
fi

# 4. 如果需要读取，更新缓存
if [ "$NEED_READ" = true ]; then
  # 读取通知内容（使用Read工具）
  # [在实际AI代码中执行]

  # 更新缓存（使用jq更新JSON）
  CURRENT_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  jq ".ai_agents.$AI_NAME.last_check_timestamp = \"$CURRENT_TIMESTAMP\" | \
      .ai_agents.$AI_NAME.last_notification_mtime = $CURRENT_MTIME | \
      .file_mtimes.\"notifications.json\" = $CURRENT_MTIME" \
      "$CACHE_FILE" > "$CACHE_FILE.tmp" && mv "$CACHE_FILE.tmp" "$CACHE_FILE"

  echo "缓存已更新"
fi
```

#### 场景2: 批量检查多个文件

```bash
#!/bin/bash

AI_NAME="max"
SHARED_DIR="/Users/yuhao/Desktop/yezannnnn/aiGroup/shared"
CACHE_FILE="$SHARED_DIR/.notification_cache.json"

# 定义需要监控的文件列表
declare -A FILES=(
  ["notifications.json"]="$SHARED_DIR/notifications.json"
  ["status.json"]="$SHARED_DIR/status.json"
  ["tasks/todos.md"]="$SHARED_DIR/tasks/todos.md"
  ["tasks/meetings.md"]="$SHARED_DIR/tasks/meetings.md"
)

# 检测系统类型
if [[ "$OSTYPE" == "darwin"* ]]; then
  STAT_CMD="stat -f %m"
else
  STAT_CMD="stat -c %Y"
fi

# 遍历检查
for FILE_KEY in "${!FILES[@]}"; do
  FILE_PATH="${FILES[$FILE_KEY]}"

  # 文件存在性检查
  if [ ! -f "$FILE_PATH" ]; then
    echo "警告: $FILE_KEY 不存在，跳过"
    continue
  fi

  # 获取当前mtime
  CURRENT_MTIME=$($STAT_CMD "$FILE_PATH")

  # 读取缓存mtime
  CACHED_MTIME=$(jq -r ".file_mtimes.\"$FILE_KEY\"" "$CACHE_FILE")

  # 比较
  if [ "$CURRENT_MTIME" -gt "$CACHED_MTIME" ]; then
    echo "✓ $FILE_KEY 有更新 (mtime: $CACHED_MTIME → $CURRENT_MTIME)"
    # 在这里触发读取逻辑
  else
    echo "✗ $FILE_KEY 无变化"
  fi
done
```

#### 场景3: 检查是否需要全量刷新（24小时检查）

```bash
#!/bin/bash

AI_NAME="max"
CACHE_FILE="/Users/yuhao/Desktop/yezannnnn/aiGroup/shared/.notification_cache.json"

# 读取上次检查时间
LAST_CHECK=$(jq -r ".ai_agents.$AI_NAME.last_check_timestamp" "$CACHE_FILE")

# 转换为Unix时间戳
if [[ "$OSTYPE" == "darwin"* ]]; then
  LAST_CHECK_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$LAST_CHECK" +%s 2>/dev/null || echo 0)
else
  LAST_CHECK_EPOCH=$(date -d "$LAST_CHECK" +%s 2>/dev/null || echo 0)
fi

CURRENT_EPOCH=$(date +%s)
DIFF_HOURS=$(( (CURRENT_EPOCH - LAST_CHECK_EPOCH) / 3600 ))

# 判断是否超过24小时
FULL_CHECK_INTERVAL=24
if [ "$DIFF_HOURS" -ge "$FULL_CHECK_INTERVAL" ]; then
  echo "距离上次全量检查已 $DIFF_HOURS 小时，执行全量刷新"
  NEED_FULL_CHECK=true
else
  echo "上次检查在 $DIFF_HOURS 小时前，使用快速检查"
  NEED_FULL_CHECK=false
fi
```

---

## 四、AI集成实现流程

### 4.1 会话初始化检查（强制执行）

每个AI在会话启动时必须执行以下步骤：

```
步骤1: 执行时间戳检查
├─ 使用Bash工具运行检查脚本
├─ 获取NEED_READ标志
└─ 判断是否需要读取文件

步骤2: 条件性读取
├─ 如果NEED_READ=true
│   ├─ 使用Read工具读取notifications.json
│   ├─ 过滤出to="当前AI"或to="all"的通知
│   ├─ 过滤掉read_by包含当前AI的通知
│   └─ 输出未读通知摘要
└─ 如果NEED_READ=false
    └─ 输出"无新通知"

步骤3: 更新缓存
├─ 使用jq更新.notification_cache.json
├─ 更新last_check_timestamp为当前时间
├─ 更新last_notification_mtime为文件当前mtime
└─ 更新unread_count
```

### 4.2 简化版实现（推荐用于实际集成）

在CLAUDE.md的初始化步骤中添加：

```markdown
## 初始化步骤（必须执行）

1. **读取人设文件** `./PERSONA.md`
2. **读取共享状态** `../shared/status.json`
3. **【新增】检查通知更新**:
   ```bash
   # 快速检查是否有新通知
   AI_NAME="max"  # 根据实际AI替换
   NOTIFICATION_FILE="../shared/notifications.json"
   CACHE_FILE="../shared/.notification_cache.json"

   # 获取mtime
   CURRENT_MTIME=$(stat -f %m "$NOTIFICATION_FILE" 2>/dev/null || stat -c %Y "$NOTIFICATION_FILE")
   CACHED_MTIME=$(jq -r ".ai_agents.$AI_NAME.last_notification_mtime" "$CACHE_FILE")

   # 如果有更新则读取
   if [ "$CURRENT_MTIME" -gt "$CACHED_MTIME" ]; then
     # 读取notifications.json并过滤
     # 更新缓存
   fi
   ```
4. **检查会议记录** `../shared/tasks/meetings.md`（如存在）
5. **检查待办事项** `../shared/tasks/todos.md`（如存在）
```

---

## 五、高级功能设计

### 5.1 增量读取优化

**场景**: 当notifications数组非常大（100+条）时，避免每次都读取全部。

**实现方案**:
1. 在缓存中记录`last_read_notification_id`
2. 读取时使用jq过滤：
   ```bash
   jq '[.notifications[] | select(.id > "notif_上次ID")] |
       [.[] | select(.to == "max" or .to == "all") |
       select(.read_by | contains(["max"]) | not)]' \
       notifications.json
   ```
3. 只处理ID大于上次ID的新通知

### 5.2 通知过期自动清理

**Bash定期任务**（可选，由麦克斯执行）:

```bash
#!/bin/bash

NOTIFICATION_FILE="/Users/yuhao/Desktop/yezannnnn/aiGroup/shared/notifications.json"
CURRENT_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# 使用jq过滤掉已过期的通知
jq --arg now "$CURRENT_TIMESTAMP" \
   '.notifications = [.notifications[] | select(.expires_at > $now)]' \
   "$NOTIFICATION_FILE" > "$NOTIFICATION_FILE.tmp" && \
   mv "$NOTIFICATION_FILE.tmp" "$NOTIFICATION_FILE"

echo "已清理过期通知"
```

### 5.3 通知统计仪表盘

**快速生成统计报告**:

```bash
#!/bin/bash

CACHE_FILE="/Users/yuhao/Desktop/yezannnnn/aiGroup/shared/.notification_cache.json"

echo "=== 通知系统状态 ==="
echo ""

# 各AI未读数量
echo "未读通知统计:"
for AI in max ella jarvis kyle; do
  UNREAD=$(jq -r ".ai_agents.$AI.unread_count" "$CACHE_FILE")
  echo "  $AI: $UNREAD 条"
done

echo ""

# 文件更新时间
echo "文件最后修改:"
jq -r '.file_mtimes | to_entries[] | "  \(.key): \(.value)"' "$CACHE_FILE" | \
  while read line; do
    FILE=$(echo "$line" | cut -d: -f1)
    MTIME=$(echo "$line" | cut -d: -f2 | xargs)
    DATE=$(date -r "$MTIME" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "未知")
    echo "$FILE: $DATE"
  done
```

---

## 六、Token优化效果分析

### 传统方式（每次会话）
```
步骤1: 读取notifications.json (1500 tokens)
步骤2: 读取全部通知内容 (3000 tokens)
步骤3: 过滤和处理 (500 tokens)
总计: 5000 tokens/会话
```

### 缓存优化方式
```
步骤1: 执行mtime检查脚本 (200 tokens)
步骤2: 如果无更新，跳过读取 (0 tokens)
步骤3: 如果有更新，读取notifications.json (1500 tokens)
步骤4: 只读取新通知（增量） (800 tokens)
总计（无更新）: 200 tokens/会话 (节省96%)
总计（有更新）: 2500 tokens/会话 (节省50%)
```

### 实际使用场景预估
假设每天4个AI各启动3次会话（共12次会话）：
- 其中10次无新通知（使用200 tokens）
- 其中2次有新通知（使用2500 tokens）

**日Token消耗**:
- 传统方式: 12 × 5000 = 60,000 tokens
- 优化方式: 10 × 200 + 2 × 2500 = 7,000 tokens
- **节省率: 88%**

**月Token节省**（按30天计）:
- 节省: (60,000 - 7,000) × 30 = 1,590,000 tokens
- **约等于节省 $23.85（按Sonnet价格计算）**

---

## 七、故障处理和边界情况

### 7.1 缓存文件损坏

**问题**: `.notification_cache.json`格式错误或丢失。

**处理**:
```bash
# 检查文件有效性
if ! jq empty "$CACHE_FILE" 2>/dev/null; then
  echo "缓存文件损坏，重新初始化"
  # 从模板恢复或重建
  cp "$CACHE_FILE.template" "$CACHE_FILE"
fi
```

### 7.2 文件mtime异常

**问题**: 文件被外部工具修改，mtime异常增大。

**处理**:
- 设置最大时间差阈值（例如不超过当前时间）
- 异常时强制重置缓存并全量读取

```bash
CURRENT_EPOCH=$(date +%s)
if [ "$FILE_MTIME" -gt "$CURRENT_EPOCH" ]; then
  echo "警告: mtime异常（未来时间），强制重置"
  FILE_MTIME=0
fi
```

### 7.3 多AI并发写入

**问题**: 多个AI同时更新缓存文件导致冲突。

**解决方案**:
1. 使用文件锁机制（flock）
2. 或者每个AI只写入自己的字段（使用jq的update操作）

```bash
# 使用文件锁
(
  flock -x 200
  # 执行jq更新
  jq "..." "$CACHE_FILE" > "$CACHE_FILE.tmp" && mv "$CACHE_FILE.tmp" "$CACHE_FILE"
) 200>"$CACHE_FILE.lock"
```

---

## 八、快速上手指南

### 对于AI开发者

**最小化实现（3步上手）**:

```bash
# 步骤1: 在AI启动脚本添加检查
AI_NAME="你的AI名称"
SHARED_DIR="/Users/yuhao/Desktop/yezannnnn/aiGroup/shared"
NOTIFICATION_FILE="$SHARED_DIR/notifications.json"
CACHE_FILE="$SHARED_DIR/.notification_cache.json"

# 步骤2: 获取mtime并比较
CURRENT_MTIME=$(stat -f %m "$NOTIFICATION_FILE" 2>/dev/null || stat -c %Y "$NOTIFICATION_FILE")
CACHED_MTIME=$(jq -r ".ai_agents.$AI_NAME.last_notification_mtime" "$CACHE_FILE")

# 步骤3: 条件读取
if [ "$CURRENT_MTIME" -gt "$CACHED_MTIME" ]; then
  # 使用Read工具读取notifications.json
  # 处理通知
  # 更新缓存
  jq ".ai_agents.$AI_NAME.last_notification_mtime = $CURRENT_MTIME" \
     "$CACHE_FILE" > "$CACHE_FILE.tmp" && mv "$CACHE_FILE.tmp" "$CACHE_FILE"
fi
```

### 对于项目管理者（麦克斯）

**通知发送标准流程**:

1. 编辑`notifications.json`，添加新通知
2. 确保通知ID唯一且递增（notif_YYYYMMDD_序号）
3. 设置合理的`expires_at`（通常30天）
4. 文件保存后，mtime自动更新，触发AI检查

**示例**:
```bash
# 添加新通知
jq '.notifications += [{
  "id": "notif_20260213_004",
  "timestamp": "2026-02-13T16:00:00Z",
  "priority": "high",
  "type": "task_assignment",
  "from": "max",
  "to": "jarvis",
  "subject": "紧急任务",
  "content": {...},
  "read_by": [],
  "acknowledged_by": [],
  "expires_at": "2026-03-15T16:00:00Z"
}]' notifications.json > notifications.json.tmp && mv notifications.json.tmp notifications.json
```

---

## 九、扩展可能性

### 9.1 集成桌面通知

**macOS通知**:
```bash
osascript -e 'display notification "你有新的任务分配" with title "AI团队通知"'
```

### 9.2 邮件/Webhook集成

当检测到高优先级通知时：
```bash
if [ "$PRIORITY" = "high" ]; then
  # 发送邮件
  echo "重要通知: $SUBJECT" | mail -s "AI团队紧急通知" user@example.com

  # 或调用Webhook
  curl -X POST https://hooks.example.com/notify \
       -H "Content-Type: application/json" \
       -d "{\"message\": \"$SUBJECT\"}"
fi
```

### 9.3 统计仪表盘

使用`jq`生成团队通知效率报告：
```bash
# 计算平均响应时间
jq '[.notifications[] |
    select(.read_by | length > 0) |
    {
      id: .id,
      sent: .timestamp,
      read: .read_by[0].timestamp,
      response_time: (.read_by[0].timestamp - .timestamp)
    }] |
    map(.response_time) |
    add / length' notifications.json
```

---

## 十、总结

### 核心优势
✅ **零存储成本** - 利用文件系统原生mtime
✅ **高效检查** - 200 tokens vs 5000 tokens (96%节省)
✅ **可扩展性** - 支持批量文件监控
✅ **持久化** - 会话间状态保持
✅ **简单实现** - 3行Bash即可集成

### 适用场景
- 团队协作通知系统
- 文件变更监控
- 任务状态同步
- 日志更新追踪

### 维护建议
- 每月清理一次过期通知
- 定期备份缓存文件
- 监控mtime异常情况
- 收集使用统计优化策略

---

**版本历史**:
- v1.0.0 (2026-02-13): 初始版本，完整实现设计

**相关文档**:
- `/shared/notifications.json` - 通知数据文件
- `/shared/.notification_cache.json` - 缓存状态文件
- 各AI的`CLAUDE.md` - 集成配置

**联系人**: 麦克斯 (Max) - 项目经理
