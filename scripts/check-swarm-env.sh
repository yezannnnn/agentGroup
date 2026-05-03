#!/bin/bash
# 全局 Agent Swarm 环境检查脚本
# 可以从 aiGroup 根目录或任意子目录运行

# 查找 aiGroup 根目录
find_root() {
    local dir="$(pwd)"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/shared" && -d "$dir/max" && -d "$dir/jarvis" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

ROOT_DIR=$(find_root)

if [[ -z "$ROOT_DIR" ]]; then
    echo "❌ 错误: 未找到 aiGroup 根目录"
    echo "   请在 aiGroup 项目目录内运行此脚本"
    exit 1
fi

echo "📁 找到 aiGroup 根目录: $ROOT_DIR"
echo ""

# 为每个 Agent 运行检查
AGENTS=("max" "ella" "jarvis" "kyle")

for agent in "${AGENTS[@]}"; do
    if [[ -f "$ROOT_DIR/$agent/check-swarm.sh" ]]; then
        echo "=========================================="
        echo "  🤖 检查 $agent Agent 环境"
        echo "=========================================="
        cd "$ROOT_DIR/$agent" && bash check-swarm.sh
        echo ""
    else
        echo "⚠️  $agent 目录缺少 check-swarm.sh 脚本"
        echo ""
    fi
done

echo "=========================================="
echo "  📊 全局检查完成"
echo "=========================================="
echo ""
echo "💡 提示:"
echo "   以上只是基础环境检查，"
echo "   真正的 Agent Swarm 支持还需要 AI 工具支持。"
echo ""
echo "   请在 AI 对话中确认："
echo "   1. 当前是否为 Kimi K2.5 模型？"
echo "   2. 是否支持 Task 工具 spawn 子代理？"
echo "   3. 可用工具列表中是否包含 MultiAgent 相关工具？"
echo ""
