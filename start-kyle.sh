#!/bin/bash
# 启动凯尔 (Kyle) - 质检测试
# 用法: ./start-kyle.sh [opus]

cd "$(dirname "$0")/kyle"

# 模型选择
if [ "$1" = "opus" ]; then
  MODEL="claude-opus-4-5-20251101"
  MODEL_NAME="Opus 4.5"
else
  MODEL="claude-sonnet-4-20250514"
  MODEL_NAME="Sonnet 4"
fi

echo "=========================================="
echo "  启动凯尔 (Kyle) - 质检测试"
echo "  模型: Claude $MODEL_NAME"
echo "=========================================="
echo ""

# 默认继承上次会话，如果没有历史则新建
claude --model $MODEL -c 2>/dev/null || claude --model $MODEL
