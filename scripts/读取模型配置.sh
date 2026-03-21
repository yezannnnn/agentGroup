#!/bin/bash
# AI团队协作系统 - 模型配置读取工具
# 功能：从模型配置.json读取模型信息的工具函数

# 配置文件路径
if [ -n "${SCRIPT_DIR}" ]; then
    # 如果SCRIPT_DIR已设置（被start-*.sh脚本sourced时）
    CONFIG_FILE="$(realpath "${SCRIPT_DIR}")/模型配置.json"
else
    # 直接运行时使用相对路径
    CONFIG_FILE="$(dirname "$0")/../模型配置.json"
fi

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "错误：找不到模型配置文件 $CONFIG_FILE"
    exit 1
fi

# 检查jq命令是否可用
if ! command -v jq &> /dev/null; then
    echo "错误：需要安装jq命令来解析JSON配置文件"
    echo "请运行：brew install jq"
    exit 1
fi

# 获取模型ID
获取模型ID() {
    local model_name="$1"
    if [ -z "$model_name" ]; then
        echo "错误：请指定模型名称 (haiku|sonnet|opus)"
        return 1
    fi

    jq -r ".模型列表.${model_name}.模型ID // empty" "$CONFIG_FILE" 2>/dev/null || \
    jq -r ".[\"模型列表\"][\"${model_name}\"][\"模型ID\"] // empty" "$CONFIG_FILE"
}

# 获取模型显示名称
获取模型显示名称() {
    local model_name="$1"
    if [ -z "$model_name" ]; then
        echo "错误：请指定模型名称 (haiku|sonnet|opus)"
        return 1
    fi

    jq -r ".模型列表.${model_name}.显示名称 // empty" "$CONFIG_FILE" 2>/dev/null || \
    jq -r ".[\"模型列表\"][\"${model_name}\"][\"显示名称\"] // empty" "$CONFIG_FILE"
}

# 获取模型成本信息
获取模型成本信息() {
    local model_name="$1"
    if [ -z "$model_name" ]; then
        echo "错误：请指定模型名称 (haiku|sonnet|opus)"
        return 1
    fi

    local input_price=$(jq -r ".[\"模型列表\"][\"${model_name}\"][\"价格配置\"][\"输入价格_百万token\"] // empty" "$CONFIG_FILE")
    local output_price=$(jq -r ".[\"模型列表\"][\"${model_name}\"][\"价格配置\"][\"输出价格_百万token\"] // empty" "$CONFIG_FILE")

    if [ -n "$input_price" ] && [ -n "$output_price" ]; then
        echo "输入 \$${input_price}/MTok, 输出 \$${output_price}/MTok"
    else
        echo "未知成本"
    fi
}

# 检查Opus授权要求
检查Opus授权() {
    local auth_required=$(jq -r ".[\"模型列表\"][\"opus\"][\"需要授权\"] // false" "$CONFIG_FILE")
    if [ "$auth_required" == "true" ]; then
        return 0  # 需要授权
    else
        return 1  # 不需要授权
    fi
}

# 获取授权机制说明
获取授权机制说明() {
    jq -r ".[\"模型列表\"][\"opus\"][\"授权机制\"] // empty" "$CONFIG_FILE"
}

# 获取适用场景
获取适用场景() {
    local model_name="$1"
    if [ -z "$model_name" ]; then
        echo "错误：请指定模型名称 (haiku|sonnet|opus)"
        return 1
    fi

    jq -r ".[\"模型列表\"][\"${model_name}\"][\"适用场景\"] | join(\", \") // empty" "$CONFIG_FILE"
}

# 获取推荐使用率
获取推荐使用率() {
    local model_name="$1"
    if [ -z "$model_name" ]; then
        echo "错误：请指定模型名称 (haiku|sonnet|opus)"
        return 1
    fi

    jq -r ".[\"模型列表\"][\"${model_name}\"][\"推荐使用率\"] // empty" "$CONFIG_FILE"
}

# 获取AI偏好设置
获取AI偏好() {
    local ai_name="$1"
    if [ -z "$ai_name" ]; then
        echo "错误：请指定AI名称 (麦克斯|艾拉|贾维斯|凯尔)"
        return 1
    fi

    jq -r ".[\"AI偏好设置\"][\"${ai_name}\"] // empty" "$CONFIG_FILE"
}

# 显示帮助信息
显示帮助() {
    echo "AI团队协作系统 - 模型配置读取工具"
    echo ""
    echo "可用函数："
    echo "  获取模型ID <模型名称>           - 获取模型的完整ID"
    echo "  获取模型显示名称 <模型名称>     - 获取模型的显示名称"
    echo "  获取模型成本信息 <模型名称>     - 获取模型的价格信息"
    echo "  检查Opus授权                    - 检查是否需要Opus授权"
    echo "  获取授权机制说明                - 获取Opus授权机制说明"
    echo "  获取适用场景 <模型名称>         - 获取模型适用场景"
    echo "  获取推荐使用率 <模型名称>       - 获取模型推荐使用率"
    echo "  获取AI偏好 <AI名称>             - 获取AI的模型偏好"
    echo ""
    echo "支持的模型名称：haiku, sonnet, opus"
    echo "支持的AI名称：麦克斯, 艾拉, 贾维斯, 凯尔"
}

# 如果直接运行此脚本，显示帮助信息
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    if [ "$1" == "--help" ] || [ "$1" == "-h" ] || [ $# -eq 0 ]; then
        显示帮助
    else
        # 执行指定的函数
        "$@"
    fi
fi