#!/bin/bash
# 测试增强版交互输入

echo "🧪 测试增强版交互输入修复"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  1) 测试选项1"
echo "  2) 测试选项2"
echo "  3) 测试选项3"
echo ""

# 使用新的交互方式
echo -n "请选择 [1-3] (默认: 1): "; read choice < /dev/tty || choice="1"

echo ""
echo "✅ 您的选择: $choice"

if [ "$choice" = "3" ]; then
    echo ""
    echo "测试第二个输入..."
    echo -n "请输入测试内容 (可为空): "; read test_input < /dev/tty || test_input=""
    echo "✅ 您输入的内容: '$test_input'"
fi

echo ""
echo "🎉 增强版交互修复测试完成！"