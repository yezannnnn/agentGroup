#!/bin/bash
# 启动 Kyle-Kimi 模式 - 使用 Kimi AI 引擎，但加载 Kyle(Claude) 的人设
# 角色: 质检测试专家
# 用法: ./start-kyle-kimi.sh

cd "$(dirname "$0")"

echo "=========================================="
echo "  启动 Kyle-Kimi 模式"
echo "  AI引擎: Kimi (Moonshot AI)"
echo "  人设来源: kyle/CLAUDE.md"
echo "  角色: 质检测试专家"
echo "=========================================="
echo ""

# 检查 kyle 目录是否存在
if [ ! -d "./kyle" ]; then
    echo "❌ 错误: kyle 目录不存在"
    exit 1
fi

# 进入 kyle 目录（Kimi 将在这里工作，读取 CLAUDE.md 等人设）
cd "./kyle"

echo "✅ 工作目录: $(pwd)"
echo ""

# 检查并显示已加载的人设文档
echo "📄 已加载的人设文档:"
[ -f "./CLAUDE.md" ] && echo "   ✅ CLAUDE.md - 核心人设（Claude版）"
[ -f "./PERSONA.md" ] && echo "   ✅ PERSONA.md - 基础人设"
[ -f "./SKILLS.md" ] && echo "   ✅ SKILLS.md - 技能文档"
[ -d "./skills" ] && echo "   ✅ skills/ - 技能目录 ($(ls ./skills 2>/dev/null | wc -l) 个技能)"

echo ""
echo "💡 提示: Kimi 将使用 Kyle(Claude) 的测试人设和技能"
echo "💡 与 ./start-kyle.sh 的区别: AI引擎不同，人设相同"
echo ""

# ==========================================
# 会话继承选择
# ==========================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🔄 会话继承选项"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  1) 🆕 新建会话 (默认)"
echo "  2) 📜 继续最近会话 (--continue)"
echo "  3) 📋 列出所有会话 (--list-sessions)"
echo ""
echo -n "请选择 [1-3] (默认: 1): "; read choice < /dev/tty || choice="1"
echo ""

# 处理用户选择
SESSION_OPTION=""
case "$choice" in
    2)
        echo "✅ 已选择: 继续最近会话"
        SESSION_OPTION="--continue"
        ;;
    3)
        echo "📋 正在列出所有可用会话..."
        echo ""
        kimi --list-sessions
        echo ""
        echo -n "请输入要恢复的会话 ID (直接回车新建会话): "; read session_id < /dev/tty || session_id=""
        if [ -n "$session_id" ]; then
            SESSION_OPTION="--session $session_id"
            echo "✅ 已选择: 恢复会话 $session_id"
        else
            echo "✅ 已选择: 新建会话"
        fi
        ;;
    *)
        echo "✅ 已选择: 新建会话"
        SESSION_OPTION=""
        ;;
esac

echo ""
echo "正在启动 Kimi..."
echo ""

# 启动 Kimi，工作目录设为 kyle/
if [ -n "$SESSION_OPTION" ]; then
    kimi --work-dir . $SESSION_OPTION
else
    kimi --work-dir .
fi
