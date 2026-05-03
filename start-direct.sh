#!/bin/bash
# 直接启动脚本（无交互）
# 用法: ./start-direct.sh [ai] [engine] [option]
# 示例: ./start-direct.sh ella opencode continue

AI="${1:-max}"
ENGINE="${2:-opencode}"
OPTION="${3:-new}"

echo "🚀 直接启动模式 (无交互)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "AI: $AI"
echo "引擎: $ENGINE"
echo "选项: $OPTION"
echo ""

# 检查目录
if [ ! -d "./$AI" ]; then
    echo "❌ 错误: $AI 目录不存在"
    exit 1
fi

cd "./$AI"

# 根据参数启动
case "$OPTION" in
    "continue")
        echo "🔄 继续最近会话..."
        if [ "$ENGINE" = "opencode" ]; then
            opencode . --continue
        else
            kimi --continue
        fi
        ;;
    "list")
        echo "📋 列出会话..."
        if [ "$ENGINE" = "opencode" ]; then
            opencode session list
        else
            kimi --list-sessions
        fi
        ;;
    *)
        echo "🆕 新建会话..."
        if [ "$ENGINE" = "opencode" ]; then
            opencode .
        else
            kimi --work-dir .
        fi
        ;;
esac