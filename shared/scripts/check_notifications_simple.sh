#!/bin/bash

################################################################################
# 通知检查脚本 - 简化版（无需jq依赖）
# 用途: AI会话启动时检查是否有新通知（仅检测mtime变化）
# 使用: ./check_notifications_simple.sh <AI_NAME>
# 示例: ./check_notifications_simple.sh max
################################################################################

# 配置
AI_NAME="${1:-max}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_DIR="$(dirname "$SCRIPT_DIR")"
NOTIFICATION_FILE="$SHARED_DIR/notifications.json"
CACHE_DIR="$SHARED_DIR/.cache"
CACHE_FILE="$CACHE_DIR/${AI_NAME}_last_check.txt"

# 创建缓存目录
mkdir -p "$CACHE_DIR"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

# 检查通知文件存在性
if [ ! -f "$NOTIFICATION_FILE" ]; then
    error "通知文件不存在: $NOTIFICATION_FILE"
    exit 2
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

# 将mtime转换为可读时间
mtime_to_date() {
    local mtime="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        date -r "$mtime" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "未知时间"
    else
        date -d "@$mtime" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "未知时间"
    fi
}

# 主逻辑
echo ""
info "AI通知检查 - $AI_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 获取当前mtime
CURRENT_MTIME=$(get_mtime "$NOTIFICATION_FILE")
CURRENT_DATE=$(mtime_to_date "$CURRENT_MTIME")

info "通知文件最后修改: $CURRENT_DATE"

# 读取缓存的mtime
if [ -f "$CACHE_FILE" ]; then
    CACHED_MTIME=$(cat "$CACHE_FILE" 2>/dev/null || echo "0")
    CACHED_DATE=$(mtime_to_date "$CACHED_MTIME")
    info "上次检查时间: $CACHED_DATE"
else
    CACHED_MTIME=0
    warning "首次检查，无历史记录"
fi

echo ""

# 比较判断
if [ "$CURRENT_MTIME" -gt "$CACHED_MTIME" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "  ${GREEN}📬 检测到通知文件有更新！${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    success "建议读取通知文件: $NOTIFICATION_FILE"
    echo ""

    # 更新缓存
    echo "$CURRENT_MTIME" > "$CACHE_FILE"
    info "缓存已更新"

    # 返回状态码1表示有新通知
    exit 1
else
    success "无新通知（文件未修改）"
    echo ""

    # 返回状态码0表示无新通知
    exit 0
fi
