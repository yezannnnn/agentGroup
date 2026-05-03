#!/bin/bash

# Webhook服务日志查看工具
SERVER="116.62.114.210"
PASSWORD="Wehook123@"

echo "📋 Webhook日志查看工具"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 参数处理
case "$1" in
    "live"|"real"|"realtime")
        echo "🔴 实时日志 (按Ctrl+C退出):"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER "
            cd /opt/webhooks
            pm2 logs webhook-service --raw
        "
        ;;
    "tail"|"latest"|"")
        LINES=${2:-50}
        echo "📄 最新 $LINES 行日志:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER "
            cd /opt/webhooks
            echo '=== 标准输出日志 ==='
            pm2 logs webhook-service --out --lines $LINES --raw
            echo ''
            echo '=== 错误日志 ==='
            pm2 logs webhook-service --err --lines $LINES --raw
        "
        ;;
    "status")
        echo "📊 服务状态:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER "
            cd /opt/webhooks
            pm2 status
            echo ''
            echo '📈 系统资源:'
            pm2 monit --no-interaction | head -20
        "
        ;;
    "clear")
        echo "🧹 清空日志:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER "
            cd /opt/webhooks
            pm2 flush webhook-service
            echo '✅ 日志已清空'
        "
        ;;
    "search")
        if [ -z "$2" ]; then
            echo "❌ 请提供搜索关键词: ./log-viewer.sh search 关键词"
            exit 1
        fi
        KEYWORD="$2"
        LINES=${3:-100}
        echo "🔍 搜索关键词 '$KEYWORD' (最近 $LINES 行):"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER "
            cd /opt/webhooks
            pm2 logs webhook-service --lines $LINES --raw | grep -i '$KEYWORD' | tail -20
        "
        ;;
    "webhook")
        echo "🪝 Webhook专项日志 (包含Token验证和转发信息):"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER "
            cd /opt/webhooks
            pm2 logs webhook-service --lines 200 --raw | grep -E '(Token|webhook|转发|POST /webhook)' | tail -30
        "
        ;;
    "help")
        echo "🆘 使用说明:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "用法: ./log-viewer.sh [命令] [参数]"
        echo ""
        echo "命令:"
        echo "  (无参数)          显示最新50行日志"
        echo "  tail [行数]       显示最新N行日志"
        echo "  live              实时查看日志"
        echo "  status            查看服务状态"
        echo "  clear             清空日志"
        echo "  search <关键词>   搜索包含关键词的日志"
        echo "  webhook           查看Webhook相关日志"
        echo "  help              显示此帮助"
        echo ""
        echo "示例:"
        echo "  ./log-viewer.sh                    # 最新50行日志"
        echo "  ./log-viewer.sh tail 100           # 最新100行日志"
        echo "  ./log-viewer.sh live               # 实时日志"
        echo "  ./log-viewer.sh search token       # 搜索token相关日志"
        echo "  ./log-viewer.sh webhook            # 查看webhook处理日志"
        ;;
    *)
        echo "❌ 未知命令: $1"
        echo "使用 './log-viewer.sh help' 查看帮助"
        exit 1
        ;;
esac

echo ""
echo "💡 提示: 使用 './log-viewer.sh help' 查看所有可用命令"