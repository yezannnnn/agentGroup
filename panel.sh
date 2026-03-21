#!/bin/bash
# AI Group - 交互式启动面板

SESSION="aigroup"
DIR="$(cd "$(dirname "$0")" && pwd)"

# 引入配置读取器
source "${DIR}/scripts/读取模型配置.sh"

# 获取AI偏好模型
MAX_MODEL=$(获取模型ID "sonnet")  # Max使用默认Sonnet
ELLA_MODEL=$(获取模型ID "opus")   # Ella使用Opus进行复杂设计
JARVIS_MODEL=$(获取模型ID "opus") # Jarvis使用Opus进行架构工作
KYLE_MODEL=$(获取模型ID "sonnet") # Kyle使用Sonnet进行测试

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
        tmux send-keys -t $SESSION "claude --model $MAX_MODEL -c 2>/dev/null || claude --model $MAX_MODEL" C-m

        tmux split-window -h -t $SESSION -c "$DIR/ella" -p 40
        tmux send-keys -t $SESSION "claude --model $ELLA_MODEL -c 2>/dev/null || claude --model $ELLA_MODEL" C-m

        tmux split-window -v -t $SESSION -c "$DIR/jarvis"
        tmux send-keys -t $SESSION "claude --model $JARVIS_MODEL -c 2>/dev/null || claude --model $JARVIS_MODEL" C-m

        tmux split-window -v -t $SESSION -c "$DIR/kyle"
        tmux send-keys -t $SESSION "claude --model $KYLE_MODEL -c 2>/dev/null || claude --model $KYLE_MODEL" C-m

        tmux select-pane -t $SESSION:0.0
        tmux attach-session -t $SESSION
        ;;
    b|B)
        # 三人: Max左 + 右两栏
        tmux new-session -d -s $SESSION -c "$DIR/max" -n "AI Group"
        tmux send-keys -t $SESSION "claude --model $MAX_MODEL -c 2>/dev/null || claude --model $MAX_MODEL" C-m

        tmux split-window -h -t $SESSION -c "$DIR/ella" -p 40
        tmux send-keys -t $SESSION "claude --model $ELLA_MODEL -c 2>/dev/null || claude --model $ELLA_MODEL" C-m

        tmux split-window -v -t $SESSION -c "$DIR/jarvis"
        tmux send-keys -t $SESSION "claude --model $JARVIS_MODEL -c 2>/dev/null || claude --model $JARVIS_MODEL" C-m

        tmux select-pane -t $SESSION:0.0
        tmux attach-session -t $SESSION
        ;;
    c|C)
        # 仅Max
        tmux new-session -d -s $SESSION -c "$DIR/max" -n "AI Group"
        tmux send-keys -t $SESSION "claude --model $MAX_MODEL -c 2>/dev/null || claude --model $MAX_MODEL" C-m
        tmux attach-session -t $SESSION
        ;;
    d|D)
        # 设计开发: 艾拉左 + 贾维斯右
        tmux new-session -d -s $SESSION -c "$DIR/ella" -n "设计+开发"
        tmux send-keys -t $SESSION "claude --model $ELLA_MODEL -c 2>/dev/null || claude --model $ELLA_MODEL" C-m

        tmux split-window -h -t $SESSION -c "$DIR/jarvis"
        tmux send-keys -t $SESSION "claude --model $ELLA_MODEL -c 2>/dev/null || claude --model $ELLA_MODEL" C-m

        tmux attach-session -t $SESSION
        ;;
    *)
        exit 0
        ;;
esac
