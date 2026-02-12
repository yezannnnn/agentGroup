#!/bin/bash
# AI Group - tmux分屏启动
# 布局: 左侧Max(大) + 右侧三栏(艾拉/贾维斯/凯尔)

SESSION="aigroup"
DIR="$(cd "$(dirname "$0")" && pwd)"

# 检查tmux是否安装
if ! command -v tmux &> /dev/null; then
    echo "错误: 需要安装tmux"
    echo "安装命令: brew install tmux"
    exit 1
fi

# 如果session已存在，直接attach
if tmux has-session -t $SESSION 2>/dev/null; then
    echo "AI Group 会话已存在，正在连接..."
    tmux attach-session -t $SESSION
    exit 0
fi

# 询问是否包含凯尔
echo "=========================================="
echo "  启动 AI Group - 四AI协作系统"
echo "=========================================="
echo ""
read -p "是否包含凯尔(测试)? [Y/n]: " include_kyle
include_kyle=${include_kyle:-Y}

if [[ $include_kyle =~ ^[Yy]$ ]]; then
    echo ""
    echo "布局:"
    echo "  +-------------+--------+"
    echo "  |             |  Ella  |"
    echo "  |             +--------+"
    echo "  |     Max     | Jarvis |"
    echo "  |             +--------+"
    echo "  |             |  Kyle  |"
    echo "  +-------------+--------+"
else
    echo ""
    echo "布局:"
    echo "  +-------------+--------+"
    echo "  |             |  Ella  |"
    echo "  |     Max     +--------+"
    echo "  |             | Jarvis |"
    echo "  +-------------+--------+"
fi
echo ""

# 创建session，左侧运行麦克斯
tmux new-session -d -s $SESSION -c "$DIR/max" -n "AI Group"
tmux send-keys -t $SESSION "claude -c 2>/dev/null || claude" C-m

# 右侧分割，运行艾拉
tmux split-window -h -t $SESSION -c "$DIR/ella" -p 40
tmux send-keys -t $SESSION "claude --model claude-opus-4-5-20251101 -c 2>/dev/null || claude --model claude-opus-4-5-20251101" C-m

# 右侧下方分割，运行贾维斯
tmux split-window -v -t $SESSION -c "$DIR/jarvis"
tmux send-keys -t $SESSION "claude --model claude-opus-4-5-20251101 -c 2>/dev/null || claude --model claude-opus-4-5-20251101" C-m

# 如果包含凯尔，继续分割
if [[ $include_kyle =~ ^[Yy]$ ]]; then
    tmux split-window -v -t $SESSION -c "$DIR/kyle"
    tmux send-keys -t $SESSION "claude -c 2>/dev/null || claude" C-m
fi

# 选择麦克斯窗格作为默认
tmux select-pane -t $SESSION:0.0

# 附加到session
tmux attach-session -t $SESSION
