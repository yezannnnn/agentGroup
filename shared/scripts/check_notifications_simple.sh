#!/bin/bash

################################################################################
# 通知检查脚本 v2
# 用途: 检查是否有针对当前 AI 的未读通知
# 使用: ./check_notifications_simple.sh <AI_NAME>
# 示例: ./check_notifications_simple.sh max
#
# 修复 (v2):
# - 不再依赖 read 字段（语义不一致），改用 read_by 列表判断已读
# - 缓存仅在确认无未读通知时才更新，避免"检测到变化但通知丢失"的问题
# - exit code = 1 时同时输出具体的未读通知 ID
################################################################################

AI_NAME="${1:-max}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_DIR="$(dirname "$SCRIPT_DIR")"
NOTIFICATION_FILE="$SHARED_DIR/notifications.json"
CACHE_DIR="$SHARED_DIR/.cache"
CACHE_FILE="$CACHE_DIR/${AI_NAME}_last_check.txt"

mkdir -p "$CACHE_DIR"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }

if [ ! -f "$NOTIFICATION_FILE" ]; then
    echo -e "\033[0;31m[✗]\033[0m 通知文件不存在: $NOTIFICATION_FILE"
    exit 2
fi

# 获取文件 mtime（跨平台）
get_mtime() {
    local raw
    if [[ "$OSTYPE" == "darwin"* ]]; then
        raw=$(stat -f %m "$1" 2>/dev/null || echo "0")
    else
        raw=$(stat -c %Y "$1" 2>/dev/null || echo "0")
    fi
    # 截取整数部分（macOS stat 可能返回小数秒）
    echo "$raw" | awk '{print int($1)}'
}

mtime_to_date() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        date -r "$1" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "未知时间"
    else
        date -d "@$1" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "未知时间"
    fi
}

echo ""
info "AI通知检查 - $AI_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

CURRENT_MTIME=$(get_mtime "$NOTIFICATION_FILE")
info "通知文件最后修改: $(mtime_to_date "$CURRENT_MTIME")"

CACHED_MTIME=0
if [ -f "$CACHE_FILE" ]; then
    RAW_CACHED=$(cat "$CACHE_FILE" 2>/dev/null || echo "0")
    CACHED_MTIME=$(echo "$RAW_CACHED" | awk '{print int($1)}')
    info "上次检查时间: $(mtime_to_date "$CACHED_MTIME")"
else
    warning "首次检查，无历史记录"
fi

echo ""

# 快速路径：文件未变化，肯定没有新通知
if [ "$CURRENT_MTIME" -le "$CACHED_MTIME" ]; then
    success "无新通知（文件未修改）"
    echo ""
    exit 0
fi

# 文件有变化，读取 JSON 过滤实际未读通知
# 判断依据：to == AI_NAME（忽略大小写）且 AI_NAME 不在 read_by 列表中
UNREAD_IDS=$(python3 - "$AI_NAME" "$NOTIFICATION_FILE" <<'PYEOF'
import json, sys

name = sys.argv[1].lower()
path = sys.argv[2]

try:
    with open(path) as f:
        data = json.load(f)
except Exception as e:
    print(f"ERROR: {e}", file=sys.stderr)
    sys.exit(2)

unread = []
for n in data.get("notifications", []):
    to = str(n.get("to", "")).lower()
    if to != name and to != "all":
        continue
    read_by = [str(x).lower() for x in n.get("read_by", [])]
    if name in read_by:
        continue
    nid = n.get("id") or "(no-id)"
    unread.append(nid)

for nid in unread:
    print(nid)

sys.exit(0 if not unread else 1)
PYEOF
)

UNREAD_EXIT=$?

if [ $UNREAD_EXIT -eq 1 ]; then
    COUNT=$(echo "$UNREAD_IDS" | grep -c .)
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "  ${GREEN}📬 发现 ${COUNT} 条未读通知${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "$UNREAD_IDS" | while read -r nid; do
        [ -n "$nid" ] && echo "  → $nid"
    done
    echo ""
    info "请读取通知文件并处理上述通知: $NOTIFICATION_FILE"
    info "处理完成后将自己名字加入各通知的 read_by 列表"
    echo ""
    # ⚠️ 注意：此处不更新缓存，确保未处理通知不会被跳过
    # 缓存将在下次检查且无未读通知时自动更新
    exit 1
else
    # 文件有变化但无针对此 AI 的未读通知，安全地更新缓存
    success "无新通知（文件有变化但均非针对 $AI_NAME 或已在 read_by）"
    echo "$CURRENT_MTIME" > "$CACHE_FILE"
    echo ""
    exit 0
fi
