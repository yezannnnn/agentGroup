# 通知缓存机制 - 快速上手指南

**版本**: v1.0.0
**目标用户**: AI团队成员（麦克斯、艾拉、贾维斯、凯尔）

---

## 一分钟快速上手

### AI成员使用（在CLAUDE.md初始化步骤中添加）

```bash
# 在会话启动时执行
/Users/yuhao/Desktop/yezannnnn/aiGroup/shared/scripts/check_notifications_simple.sh max
```

**输出解读**:
- **Exit code = 1** → 有新通知，需要读取 `notifications.json`
- **Exit code = 0** → 无新通知，跳过读取

---

## 完整集成示例（推荐）

在各AI的`CLAUDE.md`初始化步骤中添加：

```markdown
## 初始化步骤（必须执行）

1. **读取人设文件** `./PERSONA.md`
2. **读取共享状态** `../shared/status.json`
3. **【新增】检查通知更新**:
   ```bash
   # 检查是否有新通知
   ../shared/scripts/check_notifications_simple.sh max  # 替换为对应AI名称

   # 根据退出码判断
   if [ $? -eq 1 ]; then
     # 有新通知，使用Read工具读取
     # 文件路径: ../shared/notifications.json
   fi
   ```
4. **检查待办事项** `../shared/tasks/todos.md`
```

---

## 文件说明

### 核心文件

| 文件路径 | 用途 | 谁维护 |
|---------|------|--------|
| `notifications.json` | 存储所有通知 | 麦克斯发送，各AI读取 |
| `.notification_cache.json` | 高级缓存（需要jq） | 系统自动 |
| `.cache/{ai_name}_last_check.txt` | 简化缓存（纯Bash） | 系统自动 |
| `scripts/check_notifications_simple.sh` | 检查脚本（推荐） | 系统维护 |

### 通知结构示例

```json
{
  "id": "notif_20260213_001",
  "timestamp": "2026-02-13T10:30:00Z",
  "priority": "high",
  "type": "task_assignment",
  "from": "max",
  "to": "jarvis",
  "subject": "紧急Bug修复",
  "content": {
    "task_id": "bug_001",
    "file": "frontend/src/App.vue",
    "issue": "描述问题"
  },
  "read_by": [],
  "acknowledged_by": [],
  "expires_at": "2026-03-15T10:30:00Z"
}
```

---

## 使用场景

### 场景1: AI会话启动检查（最常用）

```bash
# 在CLAUDE.md初始化步骤执行
cd /Users/yuhao/Desktop/yezannnnn/aiGroup/shared/scripts
./check_notifications_simple.sh max

# 检查返回值
if [ $? -eq 1 ]; then
  echo "有新通知，需要读取"
  # 然后使用Read工具读取 ../shared/notifications.json
fi
```

### 场景2: 麦克斯发送通知

**方法A: 直接编辑JSON文件**（推荐）
```bash
# 使用Edit工具编辑 notifications.json
# 添加新的通知对象到 notifications 数组

# 文件保存后，mtime自动更新，触发其他AI的检查
```

**方法B: 使用jq命令**（高级）
```bash
jq '.notifications += [{
  "id": "notif_20260213_004",
  "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
  "priority": "normal",
  "type": "information",
  "from": "max",
  "to": "all",
  "subject": "团队会议提醒",
  "content": {"message": "明天15:00开会"},
  "read_by": [],
  "acknowledged_by": [],
  "expires_at": "'$(date -u -v+30d +"%Y-%m-%dT%H:%M:%SZ")'"
}]' notifications.json > notifications.json.tmp && \
mv notifications.json.tmp notifications.json
```

### 场景3: 标记通知为已读

```bash
# 读取通知后，更新read_by字段
jq '(.notifications[] | select(.id == "notif_20260213_001").read_by) += ["jarvis"]' \
   notifications.json > notifications.json.tmp && \
   mv notifications.json.tmp notifications.json
```

---

## Token优化效果

### 对比数据

**传统方式**（每次会话都读取）:
```
步骤1: 读取notifications.json → 1500 tokens
步骤2: 处理所有通知 → 3000 tokens
总计: 4500 tokens/会话
```

**缓存优化方式**:
```
步骤1: 执行检查脚本 → 150 tokens
步骤2: 如果无更新，跳过 → 0 tokens
总计（无更新）: 150 tokens/会话 (节省97%)
总计（有更新）: 1650 tokens/会话 (节省63%)
```

### 实际收益（月度估算）

假设每天每个AI启动3次会话：
- 4个AI × 3次/天 × 30天 = 360次会话
- 其中90%无新通知（324次），10%有新通知（36次）

**传统方式月消耗**:
```
360次 × 4500 tokens = 1,620,000 tokens
约 $24.30（按Sonnet价格）
```

**优化后月消耗**:
```
324次 × 150 tokens + 36次 × 1650 tokens = 108,000 tokens
约 $1.62（按Sonnet价格）
```

**月节省**: $22.68 (93%节省率)

---

## 常见问题

### Q1: 脚本返回exit code 1是错误吗？

**A**: 不是错误！这是设计行为：
- Exit code 1 = 检测到新通知（需要读取）
- Exit code 0 = 无新通知（跳过读取）
- Exit code 2 = 真正的错误（文件不存在等）

### Q2: 如何测试缓存机制？

**A**:
```bash
# 第一次运行（会检测到更新）
./check_notifications_simple.sh max

# 第二次运行（应该显示无更新）
./check_notifications_simple.sh max

# 修改notifications.json后再运行（又会检测到更新）
touch ../notifications.json
./check_notifications_simple.sh max
```

### Q3: 缓存文件在哪里？

**A**:
- 简化版缓存: `shared/.cache/{ai_name}_last_check.txt`
- 高级版缓存: `shared/.notification_cache.json`（需要jq）

这些文件由系统自动管理，无需手动编辑。

### Q4: 如何清空缓存强制重新读取？

**A**:
```bash
# 删除特定AI的缓存
rm /Users/yuhao/Desktop/yezannnnn/aiGroup/shared/.cache/max_last_check.txt

# 或者删除所有AI的缓存
rm -rf /Users/yuhao/Desktop/yezannnnn/aiGroup/shared/.cache/*
```

### Q5: 多个AI同时检查会冲突吗？

**A**: 不会。每个AI有独立的缓存文件：
- max → `.cache/max_last_check.txt`
- ella → `.cache/ella_last_check.txt`
- jarvis → `.cache/jarvis_last_check.txt`
- kyle → `.cache/kyle_last_check.txt`

---

## 高级功能

### 批量检查多个文件

编辑 `check_strategy` 配置：

```json
{
  "check_strategy": {
    "quick_check_files": [
      "notifications.json",
      "status.json"
    ],
    "periodic_check_files": [
      "tasks/todos.md",
      "tasks/meetings.md"
    ]
  }
}
```

### 通知优先级过滤

只读取高优先级通知（需要jq）:

```bash
jq '[.notifications[] |
     select(.priority == "high" and
            .to == "max" and
            (.read_by | contains(["max"]) | not))]' \
     notifications.json
```

### 统计未读通知

```bash
jq --arg ai "max" \
   '[.notifications[] |
     select((.to == $ai or .to == "all") and
            (.read_by | contains([$ai]) | not))] |
     length' \
     notifications.json
```

---

## 维护建议

### 定期清理（麦克斯职责）

**每月执行一次**:
```bash
# 删除已过期的通知
CURRENT_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
jq --arg now "$CURRENT_ISO" \
   '.notifications = [.notifications[] | select(.expires_at > $now)]' \
   notifications.json > notifications.json.tmp && \
   mv notifications.json.tmp notifications.json
```

### 备份通知历史

```bash
# 每月备份
cp notifications.json "notifications_backup_$(date +%Y%m).json"
```

---

## 故障排查

### 问题1: 脚本没有执行权限

```bash
chmod +x /Users/yuhao/Desktop/yezannnnn/aiGroup/shared/scripts/check_notifications_simple.sh
```

### 问题2: 缓存失效，总是显示有新通知

```bash
# 检查缓存文件内容
cat /Users/yuhao/Desktop/yezannnnn/aiGroup/shared/.cache/max_last_check.txt

# 手动设置为当前mtime
stat -f %m notifications.json > .cache/max_last_check.txt  # macOS
stat -c %Y notifications.json > .cache/max_last_check.txt  # Linux
```

### 问题3: 文件权限错误

```bash
# 确保shared目录和脚本可访问
chmod -R 755 /Users/yuhao/Desktop/yezannnnn/aiGroup/shared/scripts
```

---

## 下一步

1. **立即行动**: 在你的CLAUDE.md初始化步骤中添加检查脚本调用
2. **测试验证**: 运行一次脚本，确认能正常检测
3. **查看详细文档**: 阅读 `NOTIFICATION_CACHE_IMPLEMENTATION.md` 了解完整设计

---

**相关文档**:
- `NOTIFICATION_CACHE_IMPLEMENTATION.md` - 完整实现文档
- `notifications.json` - 通知数据文件
- `scripts/check_notifications_simple.sh` - 检查脚本

**维护者**: 麦克斯 (Max)
**最后更新**: 2026-02-13
