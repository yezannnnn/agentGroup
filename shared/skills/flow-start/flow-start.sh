#!/bin/bash
# 🚀 /flow:start - 通用启动流程脚本
# 自动检测Agent角色并执行4个标准检查点

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AIGROUP_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# ============================================
# 1. 检测当前Agent角色
# ==========================================
detect_agent() {
    local current_dir=$(basename "$PWD")
    
    case "$current_dir" in
        max|ella|jarvis|kyle)
            echo "$current_dir"
            return 0
            ;;
        *)
            # 尝试从CLAUDE.md检测
            if [ -f "./CLAUDE.md" ]; then
                local agent_from_file=$(grep -oE "^(#|##)\s*(麦克斯|艾拉|贾维斯|凯尔)\s*\(" ./CLAUDE.md | head -1)
                if [ -n "$agent_from_file" ]; then
                    case "$agent_from_file" in
                        *麦克斯*) echo "max" ;;
                        *艾拉*) echo "ella" ;;
                        *贾维斯*) echo "jarvis" ;;
                        *凯尔*) echo "kyle" ;;
                    esac
                    return 0
                fi
            fi
            return 1
            ;;
    esac
}

# ============================================
# 2. 获取角色显示信息
# ==========================================
get_agent_info() {
    local agent="$1"
    
    case "$agent" in
        max)
            echo "麦克斯|Max|项目经理/产品顾问|监控进度、协调团队、输出报告"
            ;;
        ella)
            echo "艾拉|Ella|UI视觉设计师|UI设计、用户体验、设计系统"
            ;;
        jarvis)
            echo "贾维斯|Jarvis|开发工程师|前端开发、后端开发、运维部署"
            ;;
        kyle)
            echo "凯尔|Kyle|测试工程师|测试策略、自动化测试、质量保证"
            ;;
    esac
}

# ============================================
# 3. 执行4个检查点
# ==========================================
run_checkpoints() {
    local agent="$1"
    local quick_mode="$2"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${CYAN}🚀 启动检查点执行 - Agent: $agent${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # 检查点1: 人设检查
    echo -e "${BLUE}[1/4] 检查点1: 人设检查${NC}"
    if [ -f "./PERSONA.md" ]; then
        local role=$(grep -E "^(#|##)\s*(麦克斯|艾拉|贾维斯|凯尔)" ./PERSONA.md | head -1 | sed 's/^#* //')
        echo -e "${GREEN}  ✅ 已读取人设: $role${NC}"
    else
        echo -e "${YELLOW}  ⚠️  PERSONA.md 不存在${NC}"
    fi
    echo ""
    
    # 检查点2: 读取CLAUDE.md
    echo -e "${BLUE}[2/4] 检查点2: 读取CLAUDE.md${NC}"
    if [ -f "./CLAUDE.md" ]; then
        local line_count=$(wc -l < ./CLAUDE.md)
        echo -e "${GREEN}  ✅ 已读取 CLAUDE.md (共${line_count}行)${NC}"
    else
        echo -e "${RED}  ❌  CLAUDE.md 不存在${NC}"
        return 1
    fi
    echo ""
    
    # 检查点3: 通知检查
    echo -e "${BLUE}[3/4] 检查点3: 通知检查${NC}"
    local notify_script="$AIGROUP_DIR/shared/scripts/check_notifications_simple.sh"
    if [ -f "$notify_script" ]; then
        local result=$($notify_script "$agent" 2>&1)
        if echo "$result" | grep -q "无新通知"; then
            echo -e "${GREEN}  ✅ 通知检查: 无新通知${NC}"
        else
            echo -e "${YELLOW}  🔔 通知检查: 发现新通知${NC}"
        fi
    else
        echo -e "${YELLOW}  ⚠️  通知检查脚本不存在${NC}"
    fi
    echo ""
    
    # 检查点4: 记忆恢复
    echo -e "${BLUE}[4/4] 检查点4: 记忆恢复${NC}"
    if [ "$quick_mode" = "true" ]; then
        echo -e "${YELLOW}  ⏭️  快速模式: 跳过记忆恢复${NC}"
    else
        local memory_script="$AIGROUP_DIR/memory/utils.sh"
        if [ -f "$memory_script" ]; then
            local resume_result=$($memory_script resume "$agent" 2>&1 | head -3)
            local today_result=$($memory_script today "$agent" 2>&1 | grep -E "记录数|Token" | head -2)
            echo -e "${GREEN}  ✅ 记忆已恢复${NC}"
            echo "     $resume_result"
            echo "     $today_result"
        else
            echo -e "${YELLOW}  ⚠️  记忆系统脚本不存在${NC}"
        fi
    fi
    echo ""
}

# ============================================
# 4. 显示就绪状态
# ==========================================
show_ready_status() {
    local agent="$1"
    local info=$(get_agent_info "$agent")
    local name_cn=$(echo "$info" | cut -d'|' -f1)
    local name_en=$(echo "$info" | cut -d'|' -f2)
    local title=$(echo "$info" | cut -d'|' -f3)
    local duties=$(echo "$info" | cut -d'|' -f4)
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}🎯 $name_cn ($name_en) 已就绪${NC}"
    echo ""
    echo -e "👤 ${CYAN}我是谁:${NC} $title"
    echo -e "📍 ${CYAN}当前环境:${NC} $(pwd)"
    echo ""
    echo -e "${CYAN}🎯 我的职责:${NC}"
    IFS=',' read -ra DUTY_ARRAY <<< "$duties"
    for duty in "${DUTY_ARRAY[@]}"; do
        echo "  • $(echo "$duty" | xargs)"
    done
    echo ""
    echo -e "${CYAN}💡 你可以让我:${NC}"
    case "$agent" in
        max)
            echo "  • 查看项目状态 (/status)"
            echo "  • 记录会议/待办 (/meeting, /todo)"
            echo "  • 生成项目报告 (/report)"
            echo "  • Spawn 子代理执行任务"
            ;;
        ella)
            echo "  • 设计UI界面 (/design)"
            echo "  • 创建设计系统 (/design-system)"
            echo "  • 生成Figma设计稿"
            ;;
        jarvis)
            echo "  • 开发前端功能 (/frontend)"
            echo "  • 开发后端API (/backend)"
            echo "  • 代码审查 (/review)"
            ;;
        kyle)
            echo "  • 执行测试 (/test)"
            echo "  • 生成测试报告 (/test-report)"
            echo "  • Bug追踪 (/bug)"
            ;;
    esac
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "你好！我是${GREEN}$name_cn${NC}。我已经完成了4个启动检查点。"
    echo "有什么我可以帮你的吗？🚀"
}

# ============================================
# 主函数
# ==========================================
main() {
    local quick_mode="false"
    local verbose_mode="false"
    
    # 解析参数
    for arg in "$@"; do
        case "$arg" in
            --quick)
                quick_mode="true"
                ;;
            --verbose)
                verbose_mode="true"
                ;;
            --help|-h)
                echo "用法: /flow:start [选项]"
                echo ""
                echo "选项:"
                echo "  --quick     快速模式，跳过记忆恢复"
                echo "  --verbose   详细模式"
                echo "  --help      显示帮助"
                echo ""
                echo "自动检测当前Agent角色并执行4个标准启动检查点"
                exit 0
                ;;
        esac
    done
    
    # 检测Agent角色
    local agent=$(detect_agent)
    
    if [ -z "$agent" ]; then
        echo -e "${RED}❌ 错误: 无法识别当前Agent角色${NC}"
        echo ""
        echo "当前目录: $(pwd)"
        echo "请确认你在以下目录之一:"
        echo "  - aiGroup/max/"
        echo "  - aiGroup/ella/"
        echo "  - aiGroup/jarvis/"
        echo "  - aiGroup/kyle/"
        exit 1
    fi
    
    # 执行检查点
    run_checkpoints "$agent" "$quick_mode"
    
    # 显示就绪状态
    show_ready_status "$agent"
}

# 运行主函数
main "$@"
