#!/bin/bash

# 麦克斯技能自动安装脚本
echo "🚀 开始为麦克斯安装项目管理技能..."

# 创建技能目录
SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"

echo "📁 技能目录已创建: $SKILLS_DIR"

# 安装核心项目管理系统
echo "📦 安装 CCPM (Claude Code Project Manager)..."
if [ ! -d "$SKILLS_DIR/ccpm" ]; then
    git clone https://github.com/automazeio/ccpm.git "$SKILLS_DIR/ccpm"
    echo "✅ CCPM 安装完成"
else
    echo "⚠️  CCPM 已存在，跳过安装"
fi

# 安装产品管理技能集
echo "📦 安装产品管理技能集..."
if [ ! -d "$SKILLS_DIR/pm-claude-skills" ]; then
    git clone https://github.com/Sh1n/pm-claude-skills--.git "$SKILLS_DIR/pm-claude-skills"
    echo "✅ 产品管理技能集安装完成"
else
    echo "⚠️  产品管理技能集已存在，跳过安装"
fi

# 安装综合技能库
echo "📦 安装综合技能库..."
if [ ! -d "$SKILLS_DIR/claude-skills" ]; then
    git clone https://github.com/alirezarezvani/claude-skills.git "$SKILLS_DIR/claude-skills"
    echo "✅ 综合技能库安装完成"
else
    echo "⚠️  综合技能库已存在，跳过安装"
fi

# 安装项目管理框架
echo "📦 安装项目管理框架..."
if [ ! -d "$SKILLS_DIR/claude-simone" ]; then
    git clone https://github.com/Helmi/claude-simone.git "$SKILLS_DIR/claude-simone"
    echo "✅ 项目管理框架安装完成"
else
    echo "⚠️  项目管理框架已存在，跳过安装"
fi

# 创建技能快速启动脚本
echo "📝 创建技能快速启动脚本..."
cat > "$SKILLS_DIR/max-skills.sh" << 'EOF'
#!/bin/bash
# 麦克斯技能快速启动

echo "🎯 麦克斯技能工具箱"
echo "====================="
echo "1. 项目状态检查"
echo "2. 生成会议记录"
echo "3. 分析团队效率"
echo "4. 创建PRD文档"
echo "5. 风险评估"
echo "6. 待办事项管理"
echo "====================="

read -p "请选择功能 (1-6): " choice

case $choice in
    1) echo "🔍 执行项目状态检查..." ;;
    2) echo "📝 生成会议记录..." ;;
    3) echo "📊 分析团队效率..." ;;
    4) echo "📋 创建PRD文档..." ;;
    5) echo "⚠️  执行风险评估..." ;;
    6) echo "✅ 管理待办事项..." ;;
    *) echo "❌ 无效选择" ;;
esac
EOF

chmod +x "$SKILLS_DIR/max-skills.sh"
echo "✅ 快速启动脚本创建完成"

# 验证安装
echo ""
echo "🎉 麦克斯技能安装完成！"
echo ""
echo "📍 已安装的技能:"
echo "   - CCPM项目管理系统"
echo "   - 产品管理技能集（可节省8-9小时/周）"
echo "   - 综合技能库"
echo "   - 项目管理框架"
echo ""
echo "🚀 使用方法:"
echo "   1. 启动Claude Code: claude --project max"
echo "   2. 查看技能列表: /skills list"
echo "   3. 快速启动: ~/.claude/skills/max-skills.sh"
echo ""
echo "📖 详细说明请查看: max/skills-setup.md"