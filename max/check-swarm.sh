#!/bin/bash
# Agent Swarm 环境检查脚本
# 用于启动前检查是否支持 Agent Swarm

echo "=========================================="
echo "  🤖 Agent Swarm 环境检查"
echo "=========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

CHECK_PASS=0
CHECK_FAIL=0

# 检查1: 检查 kimi 命令
echo "🔍 检查1: kimi 命令..."
if command -v kimi &> /dev/null; then
    echo -e "${GREEN}✅ 通过${NC}: 检测到 kimi 命令"
    kimi --version 2>/dev/null || echo "   版本信息不可用"
    ((CHECK_PASS++))
else
    echo -e "${RED}❌ 失败${NC}: 未检测到 kimi 命令"
    echo "   提示: 请安装 Kimi Code CLI"
    ((CHECK_FAIL++))
fi
echo ""

# 检查2: 检查工作目录
echo "🔍 检查2: 工作目录..."
if [ -f "CLAUDE.md" ]; then
    echo -e "${GREEN}✅ 通过${NC}: 当前目录包含 CLAUDE.md"
    echo "   工作目录: $(pwd)"
    ((CHECK_PASS++))
else
    echo -e "${YELLOW}⚠️ 警告${NC}: 当前目录未找到 CLAUDE.md"
    echo "   工作目录: $(pwd)"
    echo "   提示: 请在 Agent 目录下运行此脚本"
    ((CHECK_FAIL++))
fi
echo ""

# 检查3: 检查共享目录结构
echo "🔍 检查3: 共享目录结构..."
if [ -d "../shared" ]; then
    echo -e "${GREEN}✅ 通过${NC}: 共享目录存在"
    echo "   共享目录: $(realpath ../shared 2>/dev/null || echo '../shared')"
    
    # 检查关键文件
    if [ -f "../shared/status.json" ]; then
        echo -e "${GREEN}✅${NC}: status.json 存在"
    else
        echo -e "${YELLOW}⚠️${NC}: status.json 不存在（将自动创建）"
    fi
    
    if [ -f "../shared/skills/swarm-task-manager/SKILL.md" ]; then
        echo -e "${GREEN}✅${NC}: Agent Swarm Skill 存在"
    else
        echo -e "${RED}❌${NC}: Agent Swarm Skill 不存在"
    fi
    ((CHECK_PASS++))
else
    echo -e "${RED}❌ 失败${NC}: 共享目录不存在"
    echo "   提示: 请确保目录结构正确"
    ((CHECK_FAIL++))
fi
echo ""

# 检查4: 检查子 Agent 目录
echo "🔍 检查4: 团队成员目录..."
AGENTS=("max" "ella" "jarvis" "kyle")
FOUND_AGENTS=()
for agent in "${AGENTS[@]}"; do
    if [ -d "../$agent" ]; then
        FOUND_AGENTS+=("$agent")
    fi
done

if [ ${#FOUND_AGENTS[@]} -eq 4 ]; then
    echo -e "${GREEN}✅ 通过${NC}: 所有团队成员目录存在"
    echo "   成员: ${FOUND_AGENTS[*]}"
    ((CHECK_PASS++))
else
    echo -e "${YELLOW}⚠️ 警告${NC}: 部分团队成员目录缺失"
    echo "   找到: ${FOUND_AGENTS[*]}"
    echo "   缺失: $(echo "${AGENTS[@]}" | tr ' ' '\n' | grep -v "$(echo "${FOUND_AGENTS[@]}" | tr ' ' '|')" || echo "无")"
    ((CHECK_FAIL++))
fi
echo ""

# 检查5: AI 工具检测（提示信息）
echo "🔍 检查5: AI 工具支持..."
echo -e "${YELLOW}⚠️ 提示${NC}: 此检查需要 AI 协助完成"
echo "   请在 AI 对话中执行以下检查："
echo ""
echo "   Step 1: 检查模型类型"
echo "   - 系统提示是否包含 'Kimi Code CLI'?"
echo "   - 如果是 Claude Code，则不支持 Agent Swarm"
echo ""
echo "   Step 2: 检查可用工具"
echo "   - 可用工具列表中是否包含 'Task' 或 'MultiAgent'?"
echo "   - 尝试理解 Task 工具的使用方式"
echo ""
echo "   Step 3: 功能测试（可选）"
echo "   - 尝试使用 Task 工具执行简单测试"
echo ""

# 总结
echo "=========================================="
echo "  📊 检查结果"
echo "=========================================="
echo -e "通过: ${GREEN}$CHECK_PASS${NC} 项"
echo -e "失败: ${RED}$CHECK_FAIL${NC} 项"
echo ""

if [ $CHECK_FAIL -eq 0 ]; then
    echo -e "${GREEN}✅ 基础环境检查通过${NC}"
    echo ""
    echo "⚠️  但请注意："
    echo "   以上只是基础环境检查，"
    echo "   真正的 Agent Swarm 支持需要 AI 内部工具支持。"
    echo ""
    echo "   请在 AI 对话中确认："
    echo "   1. 当前是否为 Kimi K2.5 模型？"
    echo "   2. 是否支持 Task 工具 spawn 子代理？"
    echo ""
    exit 0
else
    echo -e "${YELLOW}⚠️  部分检查未通过${NC}"
    echo "   请根据提示修复环境问题"
    echo ""
    exit 1
fi
