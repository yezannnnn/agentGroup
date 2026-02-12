#!/bin/bash
# ================================================================
# aiGroup 项目 - 系统文件清理脚本
# 版本: v1.0
# 创建日期: 2026-02-12
# 维护人: 麦克斯 (Max)
# ================================================================

set -e

PROJECT_ROOT="/Users/yuhao/Desktop/yezannnnn/aiGroup"

cd "$PROJECT_ROOT"

echo "================================================================"
echo "  aiGroup 项目系统文件清理工具"
echo "================================================================"
echo ""

# 颜色定义
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 统计
total_files=0
deleted_files=0

echo -e "${BLUE}查找项目中的系统文件...${NC}"
echo ""

# 查找 .DS_Store 文件
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  macOS 系统文件 (.DS_Store)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ds_store_files=$(find . -name ".DS_Store" -type f | grep -v ".git/" || true)

if [ -z "$ds_store_files" ]; then
    echo -e "${GREEN}✅ 未发现 .DS_Store 文件${NC}"
else
    echo "发现以下 .DS_Store 文件:"
    echo "$ds_store_files"
    count=$(echo "$ds_store_files" | wc -l | tr -d ' ')
    total_files=$((total_files + count))
fi
echo ""

# 查找 Thumbs.db 文件
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Windows 系统文件 (Thumbs.db, desktop.ini)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

windows_files=$(find . \( -name "Thumbs.db" -o -name "desktop.ini" \) -type f | grep -v ".git/" || true)

if [ -z "$windows_files" ]; then
    echo -e "${GREEN}✅ 未发现 Windows 系统文件${NC}"
else
    echo "发现以下 Windows 系统文件:"
    echo "$windows_files"
    count=$(echo "$windows_files" | wc -l | tr -d ' ')
    total_files=$((total_files + count))
fi
echo ""

# 查找 Vim/Emacs 临时文件
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  编辑器临时文件 (.swp, *~)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

temp_files=$(find . \( -name "*.swp" -o -name "*.swo" -o -name "*~" \) -type f | grep -v ".git/" || true)

if [ -z "$temp_files" ]; then
    echo -e "${GREEN}✅ 未发现编辑器临时文件${NC}"
else
    echo "发现以下临时文件:"
    echo "$temp_files"
    count=$(echo "$temp_files" | wc -l | tr -d ' ')
    total_files=$((total_files + count))
fi
echo ""

# 汇总
echo "================================================================"
echo "  清理汇总"
echo "================================================================"
echo ""

if [ $total_files -eq 0 ]; then
    echo -e "${GREEN}✅ 项目非常干净，未发现需要清理的系统文件${NC}"
    echo ""
    exit 0
fi

echo -e "${YELLOW}发现 $total_files 个系统文件需要清理${NC}"
echo ""

# 询问是否删除
read -p "$(echo -e ${YELLOW}是否删除这些文件？[y/N]:${NC} )" -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}已取消操作${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}开始清理...${NC}"
echo ""

# 删除 .DS_Store
if [ -n "$ds_store_files" ]; then
    echo "$ds_store_files" | while read file; do
        if [ -f "$file" ]; then
            rm "$file"
            echo "  删除: $file"
            deleted_files=$((deleted_files + 1))
        fi
    done
fi

# 删除 Windows 文件
if [ -n "$windows_files" ]; then
    echo "$windows_files" | while read file; do
        if [ -f "$file" ]; then
            rm "$file"
            echo "  删除: $file"
            deleted_files=$((deleted_files + 1))
        fi
    done
fi

# 删除临时文件
if [ -n "$temp_files" ]; then
    echo "$temp_files" | while read file; do
        if [ -f "$file" ]; then
            rm "$file"
            echo "  删除: $file"
            deleted_files=$((deleted_files + 1))
        fi
    done
fi

echo ""
echo "================================================================"
echo -e "${GREEN}✅ 清理完成${NC}"
echo "================================================================"
echo ""
echo "已删除 $total_files 个文件"
echo ""

# 验证
remaining=$(find . \( -name ".DS_Store" -o -name "Thumbs.db" -o -name "*.swp" \) -type f | grep -v ".git/" || true)

if [ -z "$remaining" ]; then
    echo -e "${GREEN}验证通过: 所有系统文件已清理${NC}"
else
    echo -e "${YELLOW}警告: 仍有部分文件未清理${NC}"
    echo "$remaining"
fi

echo ""
echo "建议: 运行 'git status' 检查 Git 状态"
echo ""
