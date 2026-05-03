#!/bin/bash
# 🧠 aiGroup 记忆系统工具脚本
# Usage: ./memory/utils.sh <command> [args...]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_DIR="$SCRIPT_DIR"

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# 获取当前日期和时间
get_current_date() {
    date '+%Y-%m-%d'
}

get_current_datetime() {
    date '+%Y-%m-%dT%H:%M:%S%z'
}

get_timestamp() {
    date +%s
}

# 确保目录存在
ensure_dir() {
    local agent="$1"
    if [ ! -d "$MEMORY_DIR/$agent" ]; then
        mkdir -p "$MEMORY_DIR/$agent/topics"
        echo -e "${YELLOW}📁 创建记忆目录: $agent${NC}"
    fi
}

# 初始化 Agent 记忆系统
init_agent() {
    local agent="$1"
    ensure_dir "$agent"
    
    # 创建初始索引
    local index_file="$MEMORY_DIR/$agent/index.json"
    if [ ! -f "$index_file" ]; then
        cat > "$index_file" << EOF
{
  "agent": "$agent",
  "created_at": "$(get_current_datetime)",
  "last_updated": "$(get_current_datetime)",
  "total_entries": 0,
  "total_days": 0,
  "daily_files": [],
  "topic_index": {},
  "hot_keywords": [],
  "session_count": 0
}
EOF
        echo -e "${GREEN}✅ 已初始化 $agent 的记忆索引${NC}"
    fi
}

# 生成条目ID
generate_entry_id() {
    local agent="$1"
    local date_str=$(get_current_date | tr -d '-')
    local random_str=$(openssl rand -hex 2 2>/dev/null || echo "$$")
    echo "${agent}_${date_str}_${random_str}"
}

# 记录记忆条目（兼容现有格式）
record_memory() {
    local agent="$1"
    local compressed_input="$2"
    local keywords="$3"
    local actions="$4"
    local outcome="$5"
    local tokens="${6:-0}"
    local task_type="${7:-general}"
    
    ensure_dir "$agent"
    
    local date_str=$(get_current_date)
    local memory_file="$MEMORY_DIR/$agent/${date_str}.json"
    local index_file="$MEMORY_DIR/$agent/index.json"
    local entry_id=$(generate_entry_id "$agent")
    local timestamp=$(get_current_datetime)
    
    # 创建新的记忆条目（简化的兼容格式）
    local new_entry=$(cat << EOF
    {
      "timestamp": "$timestamp",
      "type": "$task_type",
      "description": "$compressed_input",
      "keywords": [$(echo "$keywords" | awk '{split($0,a,","); for(i=1;i<=length(a);i++) printf "\"%s\"%s", a[i], (i<length(a)?", ":"")}')],
      "input": "$compressed_input",
      "output": "$outcome",
      "actions": [$(echo "$actions" | awk '{split($0,a,","); for(i=1;i<=length(a);i++) printf "\"%s\"%s", a[i], (i<length(a)?", ":"")}')],
      "status": "completed"
    }
EOF
)
    
    # 检查是否已有今日记忆文件
    if [ -f "$memory_file" ]; then
        # 使用 Python 处理 JSON（兼容现有格式）
        python3 << PYEOF
import json
import sys

try:
    with open('$memory_file', 'r') as f:
        data = json.load(f)
    
    # 兼容格式：确保 entries 存在
    if 'entries' not in data:
        data['entries'] = []
    
    # 添加新条目
    new_entry = $new_entry
    data['entries'].append(new_entry)
    
    # 更新元数据（兼容两种格式）
    if 'metadata' in data:
        data['metadata']['updated_at'] = '$timestamp'
        data['metadata']['entry_count'] = len(data['entries'])
        current_tokens = data['metadata'].get('total_tokens_consumed', 0)
        data['metadata']['total_tokens_consumed'] = current_tokens + $tokens
    else:
        data['date'] = '$date_str'
    
    with open('$memory_file', 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
    print("✅ 记忆条目已追加")
except Exception as e:
    print(f"❌ 错误: {e}")
    sys.exit(1)
PYEOF
    else
        # 创建新的记忆文件（使用兼容格式）
        cat > "$memory_file" << EOF
{
  "date": "$date_str",
  "entries": [
$new_entry
  ]
}
EOF
        echo -e "${GREEN}✅ 创建新的记忆文件: ${date_str}.json${NC}"
    fi
    
    # 更新索引
    update_index "$agent" "$date_str" "$entry_id" "$keywords"
    
    echo -e "${CYAN}🧠 记忆已记录: ${entry_id}${NC}"
    return 0
}

# 更新索引
update_index() {
    local agent="$1"
    local date_str="$2"
    local entry_id="$3"
    local keywords="$4"
    local index_file="$MEMORY_DIR/$agent/index.json"
    
    # 使用 Python 更新索引
    python3 << PYEOF 2>/dev/null || true
import json
import sys

try:
    with open('$index_file', 'r') as f:
        data = json.load(f)
    
    # 更新基本信息
    data['last_updated'] = '$(get_current_datetime)'
    data['total_entries'] = data.get('total_entries', 0) + 1
    
    # 检查是否已存在该日期的记录
    date_exists = False
    for day in data.get('daily_files', []):
        if day['date'] == '$date_str':
            day['entries'] = day.get('entries', 0) + 1
            date_exists = True
            break
    
    if not date_exists:
        data['daily_files'].insert(0, {
            'date': '$date_str',
            'entries': 1,
            'file': '${date_str}.json'
        })
        data['total_days'] = data.get('total_days', 0) + 1
    
    # 更新关键词
    if '$keywords':
        hot = data.get('hot_keywords', [])
        for kw in '$keywords'.split(','):
            kw = kw.strip()
            if kw and kw not in hot:
                hot.insert(0, kw)
                if len(hot) > 20:
                    hot.pop()
        data['hot_keywords'] = hot
    
    with open('$index_file', 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        
except Exception as e:
    print(f"索引更新警告: {e}")
PYEOF
}

# 查询记忆
query_memory() {
    local agent="$1"
    local keyword="$2"
    local limit="${3:-5}"
    
    if [ ! -d "$MEMORY_DIR/$agent" ]; then
        echo -e "${RED}❌ Agent $agent 没有记忆记录${NC}"
        return 1
    fi
    
    echo -e "${BLUE}🔍 查询 $agent 的记忆: '$keyword'${NC}"
    echo ""
    
    # 使用 grep 搜索记忆文件
    local found=0
    for file in $(ls -t "$MEMORY_DIR/$agent"/[0-9]*-[0-9]*-[0-9]*.json 2>/dev/null | head -10); do
        if [ -f "$file" ]; then
            local results=$(grep -i "$keyword" "$file" 2>/dev/null | head -$limit || true)
            if [ -n "$results" ]; then
                local date_str=$(basename "$file" .json)
                echo -e "${YELLOW}📅 $date_str:${NC}"
                echo "$results" | sed 's/^/  /'
                echo ""
                ((found++))
            fi
        fi
    done
    
    if [ $found -eq 0 ]; then
        echo -e "${YELLOW}⚠️  未找到相关记忆${NC}"
    fi
}

# 获取今日记忆摘要（兼容格式）
today_summary() {
    local agent="$1"
    local date_str=$(get_current_date)
    local memory_file="$MEMORY_DIR/$agent/${date_str}.json"
    
    if [ ! -f "$memory_file" ]; then
        echo -e "${YELLOW}📭 $agent 今日暂无记忆记录${NC}"
        return 0
    fi
    
    echo -e "${BLUE}📋 $agent 今日记忆摘要:${NC}"
    echo ""
    
    python3 << PYEOF 2>/dev/null || cat "$memory_file"
import json

try:
    with open('$memory_file', 'r') as f:
        data = json.load(f)
    
    # 兼容两种格式读取元数据
    if 'metadata' in data:
        print(f"📅 日期: {data['metadata'].get('date', 'N/A')}")
        print(f"📝 记录数: {data['metadata'].get('entry_count', len(data.get('entries', [])))}")
        print(f"🔢 Token消耗: {data['metadata'].get('total_tokens_consumed', 0)}")
    else:
        print(f"📅 日期: {data.get('date', 'N/A')}")
        print(f"📝 记录数: {len(data.get('entries', []))}")
        print(f"🔢 Token消耗: N/A")
    print("")
    
    # 显示最近5条记录
    entries = data.get('entries', [])
    for entry in entries[-5:]:
        ts = entry.get('timestamp', 'N/A')
        if ts != 'N/A' and len(ts) > 16:
            ts = ts[11:16]
        print(f"⏰ {ts}")
        
        # 兼容两种格式的描述
        desc = entry.get('description', '')
        if not desc and 'compressed_input' in entry:
            desc = entry['compressed_input'].get('compressed', 'N/A')
        print(f"   📝 {desc[:50]}...")
        
        # 兼容两种格式的输出
        out = entry.get('output', '')
        if not out and 'outcome' in entry:
            out = entry['outcome'].get('result_summary', 'N/A')
        print(f"   ✅ {out[:50]}...")
        print("")
except Exception as e:
    print(f"解析错误: {e}")
PYEOF
}

# 获取会话恢复上下文（兼容格式）
get_resume_context() {
    local agent="$1"
    local index_file="$MEMORY_DIR/$agent/index.json"
    
    if [ ! -f "$index_file" ]; then
        echo "无历史记录"
        return 0
    fi
    
    # 获取最近一天的摘要
    local latest_date=$(ls -t "$MEMORY_DIR/$agent"/[0-9]*-[0-9]*-[0-9]*.json 2>/dev/null | head -1 | xargs basename 2>/dev/null | sed 's/.json$//')
    
    if [ -z "$latest_date" ]; then
        echo "无历史记录"
        return 0
    fi
    
    local summary_file="$MEMORY_DIR/$agent/${latest_date}-summary.json"
    
    if [ -f "$summary_file" ]; then
        python3 << PYEOF 2>/dev/null
import json
try:
    with open('$summary_file', 'r') as f:
        data = json.load(f)
    print(f"📅 上次活跃: {data.get('date', 'N/A')}")
    print(f"📝 {data.get('summary', '无摘要')}")
    if data.get('pending_items'):
        print(f"⏳ 待处理: {', '.join(data.get('pending_items', []))}")
    if data.get('blockers'):
        print(f"🚧 阻塞: {', '.join(data.get('blockers', []))}")
except Exception as e:
    print("无法读取摘要")
PYEOF
    else
        # 从完整记忆文件生成简要摘要（兼容格式）
        local memory_file="$MEMORY_DIR/$agent/${latest_date}.json"
        if [ -f "$memory_file" ]; then
            python3 << PYEOF 2>/dev/null
import json
try:
    with open('$memory_file', 'r') as f:
        data = json.load(f)
    entries = data.get('entries', [])
    if entries:
        last_entry = entries[-1]
        ts = last_entry.get('timestamp', 'N/A')
        print(f"📅 上次活跃: {ts[:10] if len(ts) > 10 else ts}")
        
        # 兼容两种格式的描述
        desc = last_entry.get('description', '')
        if not desc and 'compressed_input' in last_entry:
            desc = last_entry['compressed_input'].get('compressed', 'N/A')
        print(f"📝 最近记录: {desc[:60]}...")
        print(f"📊 今日共 {len(entries)} 条记录")
except Exception as e:
    print("无法读取记忆")
PYEOF
        fi
    fi
}

# 生成每日摘要（应该在一天结束时调用）
generate_daily_summary() {
    local agent="$1"
    local date_str="${2:-$(get_current_date)}"
    local memory_file="$MEMORY_DIR/$agent/${date_str}.json"
    local summary_file="$MEMORY_DIR/$agent/${date_str}-summary.json"
    
    if [ ! -f "$memory_file" ]; then
        echo -e "${YELLOW}⚠️  $date_str 无记忆记录${NC}"
        return 1
    fi
    
    python3 << PYEOF
import json

try:
    with open('$memory_file', 'r') as f:
        data = json.load(f)
    
    entries = data.get('entries', [])
    if not entries:
        print("无记录")
        exit(1)
    
    # 提取关键信息（兼容两种格式）
    all_keywords = []
    all_actions = []
    
    for entry in entries:
        # 兼容 keywords 格式
        kw = entry.get('keywords', [])
        if not kw and 'compressed_input' in entry:
            kw = entry['compressed_input'].get('keywords', [])
        all_keywords.extend(kw)
        
        # 兼容 actions 格式
        act = entry.get('actions', [])
        if not act and 'compressed_process' in entry:
            act = entry['compressed_process'].get('actions', [])
        all_actions.extend(act)
    
    # 获取 token 消耗（兼容两种格式）
    total_tokens = 0
    if 'metadata' in data:
        total_tokens = data['metadata'].get('total_tokens_consumed', 0)
    
    # 生成摘要
    summary = {
        "date": "$date_str",
        "agent": "$agent",
        "summary": f"今日共处理 {len(entries)} 项任务。主要涉及: {', '.join(list(set(all_keywords))[:5])}",
        "key_topics": list(set(all_keywords))[:10],
        "key_actions": list(set(all_actions))[:10],
        "total_interactions": len(entries),
        "total_tokens": total_tokens,
        "generated_at": "$(get_current_datetime)"
    }
    
    with open('$summary_file', 'w') as f:
        json.dump(summary, f, indent=2, ensure_ascii=False)
    
    print(f"✅ 已生成 {date_str} 的每日摘要")
    
except Exception as e:
    print(f"❌ 生成摘要失败: {e}")
    exit(1)
PYEOF
}

# 列出所有 Agent 的记忆统计
list_stats() {
    echo -e "${BLUE}📊 aiGroup 记忆系统统计${NC}"
    echo ""
    
    for agent in max ella jarvis kyle; do
        local index_file="$MEMORY_DIR/$agent/index.json"
        if [ -f "$index_file" ]; then
            python3 << PYEOF
import json
try:
    with open('$index_file', 'r') as f:
        data = json.load(f)
    print(f"🤖 {data.get('agent', '$agent').upper()}")
    print(f"   总记录: {data.get('total_entries', 0)}")
    print(f"   天数: {data.get('total_days', 0)}")
    print(f"   关键词: {', '.join(data.get('hot_keywords', [])[:5])}")
    print("")
except:
    pass
PYEOF
        fi
    done
}

# 显示帮助信息
show_help() {
    cat << EOF
🧠 aiGroup 记忆系统工具

用法: ./memory/utils.sh <命令> [参数]

命令:
  init <agent>                    初始化 Agent 的记忆系统
  record <agent> <input> <keywords> <actions> <outcome> [tokens] [type]
                                  记录一条记忆
  query <agent> <keyword> [limit] 查询记忆
  today <agent>                   显示今日记忆摘要
  resume <agent>                  获取会话恢复上下文
  summary <agent> [date]          生成每日摘要
  stats                           显示所有 Agent 统计
  help                            显示帮助

示例:
  ./memory/utils.sh init max
  ./memory/utils.sh record max "检查登录进度" "登录页,进度" "读取status,spawn艾拉" "艾拉已完成设计" 1200 project_mgmt
  ./memory/utils.sh query max "登录页"
  ./memory/utils.sh today max
  ./memory/utils.sh resume max

EOF
}

# 主命令处理
case "${1:-help}" in
    init)
        init_agent "$2"
        ;;
    record)
        record_memory "$2" "$3" "$4" "$5" "$6" "${7:-0}" "${8:-general}"
        ;;
    query)
        query_memory "$2" "$3" "${4:-5}"
        ;;
    today)
        today_summary "$2"
        ;;
    resume)
        get_resume_context "$2"
        ;;
    summary)
        generate_daily_summary "$2" "${3:-}"
        ;;
    stats)
        list_stats
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}❌ 未知命令: $1${NC}"
        show_help
        exit 1
        ;;
esac
