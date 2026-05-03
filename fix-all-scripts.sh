#!/bin/bash
# 批量修复所有启动脚本的交互问题

echo "🔧 开始修复所有启动脚本的交互问题..."
echo ""

# 定义修复函数
fix_read_command() {
    local script_file="$1"
    echo "修复脚本: $script_file"

    # 备份原文件
    cp "$script_file" "$script_file.backup"

    # 替换第一个read命令（选择菜单）
    sed -i '' 's/read -p "请选择 \[1-3\] (默认: 1): " choice.*/echo -n "请选择 [1-3] (默认: 1): "; read choice < \/dev\/tty || choice="1"/' "$script_file"

    # 替换第二个read命令（会话ID输入）
    sed -i '' 's/read -p "请输入要恢复的会话 ID (直接回车新建会话): " session_id.*/echo -n "请输入要恢复的会话 ID (直接回车新建会话): "; read session_id < \/dev\/tty || session_id=""/' "$script_file"
}

# 修复所有相关脚本
for script in start-*-kimi.sh start-*-opencode.sh; do
    if [ -f "$script" ]; then
        fix_read_command "$script"
        echo "✅ 已修复: $script"
    fi
done

echo ""
echo "🎉 所有脚本修复完成！"
echo ""
echo "📋 修复说明："
echo "- 使用 echo + read 分离模式"
echo "- 强制从 /dev/tty 读取"
echo "- 添加默认值处理"
echo ""
echo "💡 如果还有问题，请尝试直接运行:"
echo "   opencode . --continue"