#!/bin/bash
# 启动凯尔 (Kyle) - QA测试
# 用法: ./start-kyle.sh [opus|haiku]

# 保存启动脚本目录
SCRIPT_DIR="$(dirname "$0")"

# 引入配置读取器
source "${SCRIPT_DIR}/scripts/读取模型配置.sh"

cd "${SCRIPT_DIR}/kyle"

# 动态模型选择
if [ "$1" = "opus" ]; then
  MODEL=$(获取模型ID "opus")
  MODEL_NAME=$(获取模型显示名称 "opus")
  COST_INFO=$(获取模型成本信息 "opus")

  # 检查Opus授权
  if 检查Opus授权; then
    echo "⚠️  $(获取授权机制说明)"
    echo -n "继续使用Opus模型？ [y/N]: "
    read -r response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      echo "已取消，使用默认Sonnet模型"
      MODEL=$(获取模型ID "sonnet")
      MODEL_NAME=$(获取模型显示名称 "sonnet")
      COST_INFO=$(获取模型成本信息 "sonnet")
    fi
  fi
elif [ "$1" = "haiku" ]; then
  MODEL=$(获取模型ID "haiku")
  MODEL_NAME=$(获取模型显示名称 "haiku")
  COST_INFO=$(获取模型成本信息 "haiku")
else
  MODEL=$(获取模型ID "sonnet")
  MODEL_NAME=$(获取模型显示名称 "sonnet")
  COST_INFO=$(获取模型成本信息 "sonnet")
fi

echo "=========================================="
echo "  启动凯尔 (Kyle) - QA测试"
echo "  模型: Claude $MODEL_NAME"
echo "  成本: $COST_INFO"
echo "  适用: $(获取适用场景 $(echo $MODEL_NAME | cut -d' ' -f1 | tr '[:upper:]' '[:lower:]'))"
echo "=========================================="
echo ""

# 默认继承上次会话，如果没有历史则新建
claude --model $MODEL -c 2>/dev/null || claude --model $MODEL
