#!/bin/bash
# ================================================================
# aiGroup 项目 - .gitignore 规则检查脚本
# 版本: v1.0
# 创建日期: 2026-02-12
# 维护人: 麦克斯 (Max)
# ================================================================

set -e

PROJECT_ROOT="/Users/yuhao/Desktop/yezannnnn/aiGroup"

cd "$PROJECT_ROOT"

echo "================================================================"
echo "  aiGroup 项目 .gitignore 规则检查"
echo "================================================================"
echo ""

# 颜色定义
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# 检查计数
TOTAL_CHECKS=0
PASSED_CHECKS=0
WARNINGS=0
ERRORS=0

# 检查函数
check_files() {
    local pattern=$1
    local description=$2
    local severity=$3  # ERROR or WARNING

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    echo "检查: $description"

    result=$(git ls-files | grep -E "$pattern" || true)

    if [ -z "$result" ]; then
        echo -e "${GREEN}✅ 通过${NC} - 未发现问题"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        if [ "$severity" == "ERROR" ]; then
            echo -e "${RED}🔴 错误${NC} - 发现不应追踪的文件:"
            ERRORS=$((ERRORS + 1))
        else
            echo -e "${YELLOW}⚠️  警告${NC} - 发现以下文件:"
            WARNINGS=$((WARNINGS + 1))
        fi
        echo "$result" | sed 's/^/    /'
    fi
    echo ""
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  第 1 部分: 系统文件检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

check_files "\.(DS_Store)$" "macOS 系统文件 (.DS_Store)" "ERROR"
check_files "\.(Thumbs\.db|desktop\.ini)$" "Windows 系统文件" "ERROR"
check_files "^\.directory$" "Linux 系统文件" "ERROR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  第 2 部分: 临时和日志文件检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

check_files "\.(log|tmp|swp|swo)$" "日志和临时文件" "ERROR"
check_files "\.(bak|backup|old)$" "备份文件" "WARNING"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  第 3 部分: 设计源文件检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

check_files "\.(psd|ai|fig|sketch|xd)$" "大型设计源文件" "ERROR"
check_files "shared/designs/.*\.(png|jpg|jpeg)$" "设计目录导出图片（预览图除外）" "WARNING"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  第 4 部分: 缓存和依赖检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

check_files "__pycache__|\.pyc$|\.pyo$" "Python 缓存文件" "ERROR"
check_files "node_modules/|\.cache/" "Node.js 依赖和缓存" "ERROR"
check_files "\.(egg-info|pytest_cache)/" "Python 包管理和测试缓存" "ERROR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  第 5 部分: 敏感信息检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

check_files "\.(env|key|pem)$|secrets/" "敏感配置和密钥文件" "ERROR"
check_files "settings\.local\.json$" "本地配置文件" "ERROR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  第 6 部分: 编辑器配置检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

check_files "\.vscode/|\.idea/|\.cursor/" "编辑器配置目录" "WARNING"

echo "================================================================"
echo "  检查结果汇总"
echo "================================================================"
echo ""
echo "总检查项:   $TOTAL_CHECKS"
echo -e "${GREEN}通过:       $PASSED_CHECKS${NC}"
echo -e "${YELLOW}警告:       $WARNINGS${NC}"
echo -e "${RED}错误:       $ERRORS${NC}"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ 检查失败 - 发现 $ERRORS 个错误${NC}"
    echo "建议: 使用 'git rm --cached <file>' 移除不应追踪的文件"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  检查通过（有警告） - 发现 $WARNINGS 个警告${NC}"
    echo "建议: 检查警告文件是否应该保留在版本控制中"
    exit 0
else
    echo -e "${GREEN}✅ 检查完全通过 - .gitignore 规则正常工作${NC}"
    exit 0
fi
