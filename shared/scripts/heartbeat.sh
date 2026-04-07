#!/bin/bash
# ============================================================
# clawborate / agentGroup 心跳通知触发脚本
# 功能: 检查未读通知，向对应 Agent 注入触发消息
# 运行方式: 由 cron 每1分钟调用
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_DIR="$(dirname "$SCRIPT_DIR")"
AGENT_GROUP_DIR="$(dirname "$SHARED_DIR")"
NOTIFICATIONS_FILE="$SHARED_DIR/notifications.json"
STATE_FILE="$SHARED_DIR/scripts/heartbeat_state.json"

HEARTBEAT_MSG="[SYSTEM HEARTBEAT] 你有新的未读通知，请立即执行强制检查点流程处理通知。"

# Agent 目录映射（兼容 bash 3.x，不使用关联数组）
agent_dir() {
  case "$1" in
    ella)   echo "$AGENT_GROUP_DIR/ella" ;;
    jarvis) echo "$AGENT_GROUP_DIR/jarvis" ;;
    kyle)   echo "$AGENT_GROUP_DIR/kyle" ;;
    max)    echo "$AGENT_GROUP_DIR/max" ;;
    *)      echo "" ;;
  esac
}

# ============================================================
# 初始化状态文件
# ============================================================
if [ ! -f "$STATE_FILE" ]; then
  echo '{"triggered": []}' > "$STATE_FILE"
fi

# ============================================================
# 读取已触发通知 ID 列表
# ============================================================
triggered_ids=$(python3 -c "
import json
with open('$STATE_FILE') as f:
    data = json.load(f)
print(' '.join(data.get('triggered', [])))
")

# ============================================================
# 读取 notifications.json，找出未读且未触发的通知
# ============================================================
notifications=$(python3 -c "
import json
from datetime import datetime, timezone

with open('$NOTIFICATIONS_FILE') as f:
    data = json.load(f)

now = datetime.now(timezone.utc)
triggered = set('$triggered_ids'.split()) if '$triggered_ids'.strip() else set()
results = []

for n in data.get('notifications', []):
    nid = n.get('id', '')
    to = n.get('to', '')
    expires = n.get('expires_at', '')
    acknowledged = n.get('acknowledged_by', [])

    # 跳过已过期
    if expires:
        try:
            exp_dt = datetime.fromisoformat(expires.replace('Z', '+00:00'))
            if now > exp_dt:
                continue
        except:
            pass

    # 跳过已确认
    if acknowledged:
        continue

    # 跳过已触发
    if nid in triggered:
        continue

    results.append(f'{nid}:{to}')

print('\n'.join(results))
")

if [ -z "$notifications" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] heartbeat: 无需触发，无新通知"
  exit 0
fi

# ============================================================
# 对每条通知的目标 Agent 触发心跳
# ============================================================
newly_triggered=""

while IFS= read -r line; do
  [ -z "$line" ] && continue
  notif_id="${line%%:*}"
  target="${line##*:}"

  # 处理 "all" 广播
  if [ "$target" = "all" ]; then
    targets="ella jarvis kyle"
  else
    targets="$target"
  fi

  for agent in $targets; do
    dir="$(agent_dir "$agent")"
    if [ -z "$dir" ] || [ ! -d "$dir" ]; then
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] heartbeat: ⚠️  未知 Agent 或目录不存在: $agent"
      continue
    fi

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] heartbeat: 🔔 触发 $agent (通知: $notif_id)"
    (
      cd "$dir"
      claude -p "$HEARTBEAT_MSG" \
        --dangerously-skip-permissions \
        --output-format text \
        2>/dev/null || true
    )
  done

  newly_triggered="$newly_triggered $notif_id"
done <<< "$notifications"

# ============================================================
# 更新状态文件
# ============================================================
if [ -n "$(echo $newly_triggered | tr -d ' ')" ]; then
  python3 -c "
import json
existing = '$triggered_ids'.split() if '$triggered_ids'.strip() else []
new_ids = '$newly_triggered'.split()
with open('$STATE_FILE') as f:
    data = json.load(f)
data['triggered'] = list(set(existing + new_ids))
data['last_run'] = '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
with open('$STATE_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
  count=$(echo $newly_triggered | wc -w | tr -d ' ')
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] heartbeat: ✅ 已触发 $count 条通知"
fi
