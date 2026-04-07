#!/bin/bash
# AI团队协作系统 - 模型配置验证工具
# 功能：验证所有模型配置是否正常工作

# 引入配置读取器
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/读取模型配置.sh"

echo "🔍 AI团队协作系统 - 模型配置验证"
echo "=================================="

# 验证配置文件
echo "1. 验证配置文件..."
if [ -f "${SCRIPT_DIR}/../模型配置.json" ]; then
    echo "✅ 配置文件存在：模型配置.json"

    # 验证JSON格式
    if jq . "${SCRIPT_DIR}/../模型配置.json" > /dev/null 2>&1; then
        echo "✅ JSON格式正确"
    else
        echo "❌ JSON格式错误"
        exit 1
    fi
else
    echo "❌ 配置文件不存在：模型配置.json"
    exit 1
fi

echo ""

# 验证模型ID获取
echo "2. 验证模型ID获取..."
for model in haiku sonnet opus; do
    model_id=$(获取模型ID "$model")
    if [ -n "$model_id" ]; then
        echo "✅ $model: $model_id"
    else
        echo "❌ $model: 无法获取模型ID"
    fi
done

echo ""

# 验证显示名称获取
echo "3. 验证显示名称获取..."
for model in haiku sonnet opus; do
    display_name=$(获取模型显示名称 "$model")
    if [ -n "$display_name" ]; then
        echo "✅ $model: $display_name"
    else
        echo "❌ $model: 无法获取显示名称"
    fi
done

echo ""

# 验证成本信息获取
echo "4. 验证成本信息获取..."
for model in haiku sonnet opus; do
    cost_info=$(获取模型成本信息 "$model")
    if [ -n "$cost_info" ]; then
        echo "✅ $model: $cost_info"
    else
        echo "❌ $model: 无法获取成本信息"
    fi
done

echo ""

# 验证Opus授权检查
echo "5. 验证Opus授权检查..."
if 检查Opus授权; then
    auth_desc=$(获取授权机制说明)
    echo "✅ Opus需要授权: $auth_desc"
else
    echo "❌ Opus授权检查失败"
fi

echo ""

# 验证AI偏好设置
echo "6. 验证AI偏好设置..."
for ai in 麦克斯 艾拉 贾维斯 凯尔; do
    preference=$(获取AI偏好 "$ai")
    if [ -n "$preference" ]; then
        echo "✅ $ai: $preference"
    else
        echo "❌ $ai: 无法获取偏好设置"
    fi
done

echo ""

# 验证启动脚本
echo "7. 验证启动脚本..."
for script in start-max.sh start-ella.sh start-jarvis.sh start-kyle.sh; do
    if [ -f "${SCRIPT_DIR}/../$script" ]; then
        if grep -q "source.*读取模型配置.sh" "${SCRIPT_DIR}/../$script"; then
            echo "✅ $script: 已集成配置读取器"
        else
            echo "⚠️  $script: 未集成配置读取器"
        fi
    else
        echo "❌ $script: 文件不存在"
    fi
done

echo ""

# 验证panel.sh
echo "8. 验证panel.sh..."
if [ -f "${SCRIPT_DIR}/../panel.sh" ]; then
    if grep -q "source.*读取模型配置.sh" "${SCRIPT_DIR}/../panel.sh"; then
        echo "✅ panel.sh: 已集成配置读取器"
    else
        echo "⚠️  panel.sh: 未集成配置读取器"
    fi

    # 检查是否还有硬编码的模型ID
    if grep -q "claude-opus-4-5-20251101\|claude-sonnet-4-20250514" "${SCRIPT_DIR}/../panel.sh"; then
        echo "⚠️  panel.sh: 仍有硬编码模型ID"
    else
        echo "✅ panel.sh: 已移除硬编码模型ID"
    fi
else
    echo "❌ panel.sh: 文件不存在"
fi

echo ""

# 验证CLAUDE.md文件
echo "9. 验证CLAUDE.md文件..."
for ai_dir in max ella jarvis kyle; do
    claude_file="${SCRIPT_DIR}/../${ai_dir}/CLAUDE.md"
    if [ -f "$claude_file" ]; then
        if grep -q "价格参考 (MTok = 百万Token)" "$claude_file"; then
            echo "✅ ${ai_dir}/CLAUDE.md: 包含价格参考"
        else
            echo "⚠️  ${ai_dir}/CLAUDE.md: 未找到价格参考"
        fi
    else
        echo "❌ ${ai_dir}/CLAUDE.md: 文件不存在"
    fi
done

echo ""
echo "=================================="
echo "🎯 验证完成！"

# 显示模型版本汇总
echo ""
echo "📊 当前模型配置汇总："
echo "  - Haiku: $(获取模型显示名称 haiku) ($(获取模型ID haiku))"
echo "  - Sonnet: $(获取模型显示名称 sonnet) ($(获取模型ID sonnet))"
echo "  - Opus: $(获取模型显示名称 opus) ($(获取模型ID opus))"

echo ""
echo "💰 成本信息："
for model in haiku sonnet opus; do
    echo "  - $(获取模型显示名称 "$model"): $(获取模型成本信息 "$model")"
done