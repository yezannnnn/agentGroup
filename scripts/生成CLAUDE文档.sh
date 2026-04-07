#!/bin/bash
# AI团队协作系统 - CLAUDE.md文档自动生成工具
# 功能：从模型配置.json自动更新CLAUDE.md文件中的价格表

# 引入配置读取器
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/读取模型配置.sh"

# 生成价格表内容
生成价格表() {
    echo "**价格参考 (MTok = 百万Token)**："

    for model in haiku sonnet opus; do
        local display_name=$(获取模型显示名称 "$model")
        local cost_info=$(获取模型成本信息 "$model")
        echo "- $display_name: $cost_info"
    done
}

# 生成状态判断标准
生成状态判断标准() {
    echo "**状态判断标准**："

    # 从配置文件读取状态标准 - 直接写出内容
    echo "- 🟢 正常: <2,000 tokens, <\$0.05"
    echo "- 🟡 注意: 2,000-5,000 tokens, \$0.05-\$0.15"
    echo "- 🔴 警告: 5,000-20,000 tokens, \$0.15-\$0.50"
    echo "- ⚫ 高成本: >20,000 tokens, >\$0.50"
}

# 更新单个CLAUDE.md文件
更新CLAUDE文档() {
    local file_path="$1"
    local ai_name="$2"

    if [ ! -f "$file_path" ]; then
        echo "错误：文件不存在 $file_path"
        return 1
    fi

    echo "正在更新 $file_path ..."

    # 备份原文件
    cp "$file_path" "${file_path}.backup"

    # 创建临时文件
    local temp_file=$(mktemp)

    # 标记是否在价格区域内
    local in_price_section=false
    local in_status_section=false
    local price_updated=false
    local status_updated=false

    while IFS= read -r line; do
        if [[ $line == *"价格参考 (MTok = 百万Token)"* ]]; then
            in_price_section=true
            echo "$line" >> "$temp_file"
            生成价格表 >> "$temp_file"
            price_updated=true
            continue
        elif [[ $line == *"状态判断标准"* ]]; then
            in_status_section=true
            echo "$line" >> "$temp_file"
            生成状态判断标准 >> "$temp_file"
            status_updated=true
            continue
        elif [[ $in_price_section == true ]]; then
            # 跳过旧的价格行直到遇到下一个标题
            if [[ $line == "###"* ]] || [[ $line == "**状态判断标准"* ]]; then
                in_price_section=false
                echo "" >> "$temp_file"
                echo "$line" >> "$temp_file"
            fi
            continue
        elif [[ $in_status_section == true ]]; then
            # 跳过旧的状态行直到遇到下一个标题
            if [[ $line == "###"* ]] || [[ $line == "**"* && $line != *"状态判断标准"* ]]; then
                in_status_section=false
                echo "" >> "$temp_file"
                echo "$line" >> "$temp_file"
            fi
            continue
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$file_path"

    # 如果找到并更新了价格信息，替换原文件
    if [ "$price_updated" = true ] || [ "$status_updated" = true ]; then
        mv "$temp_file" "$file_path"
        echo "✅ 已更新 $ai_name 的CLAUDE.md文档"
    else
        rm "$temp_file"
        echo "⚠️  未找到价格表或状态判断标准，跳过 $ai_name"
    fi

    # 清理备份文件（可选）
    # rm "${file_path}.backup"
}

# 主函数
main() {
    echo "开始更新CLAUDE.md文档..."
    echo "=================================="

    # 更新所有AI的CLAUDE.md文件
    更新CLAUDE文档 "${SCRIPT_DIR}/../max/CLAUDE.md" "麦克斯"
    更新CLAUDE文档 "${SCRIPT_DIR}/../ella/CLAUDE.md" "艾拉"
    更新CLAUDE文档 "${SCRIPT_DIR}/../jarvis/CLAUDE.md" "贾维斯"
    更新CLAUDE文档 "${SCRIPT_DIR}/../kyle/CLAUDE.md" "凯尔"

    echo "=================================="
    echo "CLAUDE.md文档更新完成！"

    # 显示当前价格信息
    echo ""
    echo "当前模型价格："
    生成价格表

    echo ""
    echo "当前状态判断标准："
    生成状态判断标准
}

# 显示帮助信息
显示帮助() {
    echo "AI团队协作系统 - CLAUDE.md文档生成工具"
    echo ""
    echo "用法："
    echo "  $0              - 更新所有CLAUDE.md文件"
    echo "  $0 --help       - 显示此帮助信息"
    echo "  $0 --price      - 只显示价格信息"
    echo "  $0 --status     - 只显示状态标准"
    echo ""
    echo "功能："
    echo "  - 自动从模型配置.json读取最新价格信息"
    echo "  - 更新所有AI的CLAUDE.md文档中的价格表"
    echo "  - 更新状态判断标准"
    echo "  - 自动备份原文件为 .backup"
}

# 参数处理
case "${1:-}" in
    --help|-h)
        显示帮助
        ;;
    --price|-p)
        echo "当前模型价格："
        生成价格表
        ;;
    --status|-s)
        echo "当前状态判断标准："
        生成状态判断标准
        ;;
    "")
        main
        ;;
    *)
        echo "错误：未知参数 $1"
        echo "使用 --help 查看帮助信息"
        exit 1
        ;;
esac