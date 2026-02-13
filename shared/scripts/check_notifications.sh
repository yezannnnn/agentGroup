#!/bin/bash

################################################################################
# 通知检查脚本 - 智能缓存版本
# 用途: AI会话启动时检查是否有新通知
# 使用: ./check_notifications.sh <AI_NAME>
# 示例: ./check_notifications.sh max
################################################################################

# 配置
AI_NAME="${1:-max}"  # 第一个参数为AI名称，默认max
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_DIR="$(dirname "$SCRIPT_DIR")"
NOTIFICATION_FILE="$SHARED_DIR/notifications.json"
CACHE_FILE="$SHARED_DIR/.notification_cache.json"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 输出函数
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检查依赖
if ! command -v jq &> /dev/null; then
    error "jq未安装，请先安装: brew install jq"
    exit 1
fi

# 检查文件存在性
if [ ! -f "$NOTIFICATION_FILE" ]; then
    error "通知文件不存在: $NOTIFICATION_FILE"
    exit 1
fi

if [ ! -f "$CACHE_FILE" ]; then
    warning "缓存文件不存在，创建新缓存"
    # 创建默认缓存
    cat > "$CACHE_FILE" <<EOF
{
  "meta": {
    "version": "1.0.0",
    "last_global_update": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  },
  "ai_agents": {
    "max": {"last_check_timestamp": "1970-01-01T00:00:00Z", "last_notification_mtime": 0, "unread_count": 0},
    "ella": {"last_check_timestamp": "1970-01-01T00:00:00Z", "last_notification_mtime": 0, "unread_count": 0},
    "jarvis": {"last_check_timestamp": "1970-01-01T00:00:00Z", "last_notification_mtime": 0, "unread_count": 0},
    "kyle": {"last_check_timestamp": "1970-01-01T00:00:00Z", "last_notification_mtime": 0, "unread_count": 0}
  },
  "file_mtimes": {}
}
EOF
fi

# 获取文件mtime（跨平台）
get_mtime() {
    local file="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        stat -f %m "$file" 2>/dev/null || echo "0"
    else
        stat -c %Y "$file" 2>/dev/null || echo "0"
    fi
}

# 主逻辑
info "检查通知更新 (AI: $AI_NAME)"
echo ""

# 1. 获取当前mtime
CURRENT_MTIME=$(get_mtime "$NOTIFICATION_FILE")
info "当前文件mtime: $CURRENT_MTIME"

# 2. 读取缓存mtime
CACHED_MTIME=$(jq -r ".ai_agents.$AI_NAME.last_notification_mtime // 0" "$CACHE_FILE")
info "缓存mtime: $CACHED_MTIME"

# 3. 比较判断
if [ "$CURRENT_MTIME" -gt "$CACHED_MTIME" ]; then
    success "检测到新通知！"
    echo ""

    # 4. 读取并过滤通知
    info "读取未读通知..."

    # 过滤条件：
    # - to 字段为当前AI或"all"
    # - read_by 数组不包含当前AI
    # - 未过期
    CURRENT_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    UNREAD_NOTIFICATIONS=$(jq --arg ai "$AI_NAME" --arg now "$CURRENT_ISO" '
        [.notifications[] |
         select((.to == $ai or .to == "all") and
                (.read_by | contains([$ai]) | not) and
                (.expires_at > $now))]
    ' "$NOTIFICATION_FILE")

    UNREAD_COUNT=$(echo "$UNREAD_NOTIFICATIONS" | jq 'length')

    if [ "$UNREAD_COUNT" -gt 0 ]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  📬 您有 $UNREAD_COUNT 条未读通知"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""

        # 显示通知摘要
        echo "$UNREAD_NOTIFICATIONS" | jq -r '.[] |
            "【\(.priority | ascii_upcase)】\(.subject)\n" +
            "  发送者: \(.from)\n" +
            "  时间: \(.timestamp)\n" +
            "  类型: \(.type)\n" +
            "  ID: \(.id)\n"'

        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        info "请使用 Read 工具查看详细内容: $NOTIFICATION_FILE"
    else
        success "无未读通知（所有通知已读或已过期）"
    fi

    # 5. 更新缓存
    info "更新缓存..."
    CURRENT_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    jq --arg ai "$AI_NAME" \
       --arg ts "$CURRENT_TIMESTAMP" \
       --argjson mtime "$CURRENT_MTIME" \
       --argjson count "$UNREAD_COUNT" \
       ".ai_agents[$ai].last_check_timestamp = \$ts |
        .ai_agents[$ai].last_notification_mtime = \$mtime |
        .ai_agents[$ai].unread_count = \$count |
        .file_mtimes.\"notifications.json\" = \$mtime" \
       "$CACHE_FILE" > "$CACHE_FILE.tmp" && mv "$CACHE_FILE.tmp" "$CACHE_FILE"

    success "缓存已更新"

    # 返回状态码：1表示有新通知
    exit 1
else
    success "无新通知（文件未修改）"
    echo ""
    info "上次检查: $(jq -r ".ai_agents.$AI_NAME.last_check_timestamp" "$CACHE_FILE")"

    # 返回状态码：0表示无新通知
    exit 0
fi
