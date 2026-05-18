#!/bin/bash
# 启动艾拉 (Ella) - UI/UX设计
# 用法: ./start-ella.sh [opus]

cd "$(dirname "$0")/ella"

# 模型选择
if [ "$1" = "opus" ]; then
  MODEL="opus"
  MODEL_NAME="Opus"
else
  MODEL="sonnet"
  MODEL_NAME="Sonnet"
fi

echo "=========================================="
echo "  启动艾拉 (Ella) - UI/UX设计"
echo "  模型: Claude $MODEL_NAME"
echo "=========================================="
echo ""

# 默认继承上次会话，如果没有历史则新建
claude --model $MODEL -c 2>/dev/null || claude --model $MODEL
