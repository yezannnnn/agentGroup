#!/bin/bash
# AI Group - 交互式启动面板

SESSION="aigroup"
DIR="$(cd "$(dirname "$0")" && pwd)"

# 检查tmux
if ! command -v tmux &> /dev/null; then
    echo "错误: 需要安装tmux"
    echo "安装命令: brew install tmux"
    exit 1
fi

# 如果session已存在
if tmux has-session -t $SESSION 2>/dev/null; then
    echo "AI Group 会话已存在"
    echo ""
    echo "  1) 连接到现有会话"
    echo "  2) 关闭并重新启动"
    echo "  3) 退出"
    echo ""
    read -p "请选择 [1-3]: " choice

    case $choice in
        1) tmux attach-session -t $SESSION; exit 0 ;;
        2) tmux kill-session -t $SESSION ;;
        *) exit 0 ;;
    esac
fi

echo "=========================================="
echo "  AI Group - 启动面板"
echo "=========================================="
echo ""
echo "  a) 全员启动 (Max + 艾拉 + 贾维斯 + 凯尔)"
echo "  b) 三人模式 (Max + 艾拉 + 贾维斯)"
echo "  c) 仅Max"
echo "  d) 设计开发 (艾拉 + 贾维斯)"
echo "  q) 退出"
echo ""
read -p "请选择: " selection

case $selection in
    a|A)
        # 全员: Max左 + 右三栏
        tmux new-session -d -s $SESSION -c "$DIR/max" -n "AI Group"
        tmux send-keys -t $SESSION "claude -c 2>/dev/null || claude" C-m

        tmux split-window -h -t $SESSION -c "$DIR/ella" -p 40
        tmux send-keys -t $SESSION "claude --model claude-opus-4-5-20251101 -c 2>/dev/null || claude --model claude-opus-4-5-20251101" C-m

        tmux split-window -v -t $SESSION -c "$DIR/jarvis"
        tmux send-keys -t $SESSION "claude --model claude-opus-4-5-20251101 -c 2>/dev/null || claude --model claude-opus-4-5-20251101" C-m

        tmux split-window -v -t $SESSION -c "$DIR/kyle"
        tmux send-keys -t $SESSION "claude -c 2>/dev/null || claude" C-m

        tmux select-pane -t $SESSION:0.0
        tmux attach-session -t $SESSION
        ;;
    b|B)
        # 三人: Max左 + 右两栏
        tmux new-session -d -s $SESSION -c "$DIR/max" -n "AI Group"
        tmux send-keys -t $SESSION "claude -c 2>/dev/null || claude" C-m

        tmux split-window -h -t $SESSION -c "$DIR/ella" -p 40
        tmux send-keys -t $SESSION "claude --model claude-opus-4-5-20251101 -c 2>/dev/null || claude --model claude-opus-4-5-20251101" C-m

        tmux split-window -v -t $SESSION -c "$DIR/jarvis"
        tmux send-keys -t $SESSION "claude --model claude-opus-4-5-20251101 -c 2>/dev/null || claude --model claude-opus-4-5-20251101" C-m

        tmux select-pane -t $SESSION:0.0
        tmux attach-session -t $SESSION
        ;;
    c|C)
        # 仅Max
        tmux new-session -d -s $SESSION -c "$DIR/max" -n "AI Group"
        tmux send-keys -t $SESSION "claude -c 2>/dev/null || claude" C-m
        tmux attach-session -t $SESSION
        ;;
    d|D)
        # 设计开发: 艾拉左 + 贾维斯右
        tmux new-session -d -s $SESSION -c "$DIR/ella" -n "设计+开发"
        tmux send-keys -t $SESSION "claude --model claude-opus-4-5-20251101 -c 2>/dev/null || claude --model claude-opus-4-5-20251101" C-m

        tmux split-window -h -t $SESSION -c "$DIR/jarvis"
        tmux send-keys -t $SESSION "claude --model claude-opus-4-5-20251101 -c 2>/dev/null || claude --model claude-opus-4-5-20251101" C-m

        tmux attach-session -t $SESSION
        ;;
    *)
        exit 0
        ;;
esac
