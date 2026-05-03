# 🧠 aiGroup 记忆系统 (Memory System)

## 概述

aiGroup 记忆系统是一个上下文压缩和持久化机制，确保每个 Agent 能够：
- 记录每次任务的关键信息
- 通过压缩摘要减少上下文消耗
- 支持跨会话的记忆恢复
- 提供高效的记忆查询接口

---

## 强制流程要求

### 记忆系统检查点（CLAUDE.md 第8检查点）

```
✅ 输出格式: "🧠 记忆系统: [记录完成/更新完成]"
✅ 强制触发时机:
   - 每次用户任务完成后
   - 每次 spawn 子代理任务完成后
   - 每次 /status /report 等技能执行后
✅ 必须执行:
   1. 提取关键实体和关键词
   2. 压缩用户输入（保留前100字符 + 关键词）
   3. 压缩处理过程（只保留行动摘要）
   4. 记录结果和状态
   5. 写入 memory/{agent}/{YYYY-MM-DD}.json
✅ 压缩率目标: 原始内容的 10-20%
❌ 不允许: 不记录或记录完整原始内容
```

---

## 目录结构

```
memory/
├── SKILL.md                    # 本规范文档
├── utils.sh                    # 记忆操作工具脚本
├── compression-prompt.md       # AI 压缩提示词模板
│
├── max/                        # 麦克斯的记忆
│   ├── index.json              # 索引文件
│   ├── 2026-03-02.json         # 每日记忆（原始条目）
│   ├── 2026-03-02-summary.json # 每日摘要（高度压缩）
│   └── topics/                 # 主题聚类
│       ├── project-alpha.json
│       └── bug-fixes.json
│
├── ella/                       # 艾拉的记忆
├── jarvis/                     # 贾维斯的记忆
└── kyle/                       # 凯尔的记忆
```

---

## 记忆文件格式

### 1. 每日记忆文件: `{YYYY-MM-DD}.json`

```json
{
  "metadata": {
    "date": "2026-03-02",
    "agent": "max",
    "created_at": "2026-03-02T09:00:00+08:00",
    "updated_at": "2026-03-02T18:30:00+08:00",
    "entry_count": 5,
    "total_tokens_consumed": 12500
  },
  "entries": [
    {
      "id": "max_20260302_001",
      "timestamp": "2026-03-02T14:30:00+08:00",
      "session_id": "sess_abc123",
      
      "task_info": {
        "type": "project_management",
        "classification": "spawn_coordination",
        "priority": "high"
      },
      
      "compressed_input": {
        "original_length": 256,
        "compressed": "检查登录页设计进度，催促艾拉交付",
        "keywords": ["登录页", "设计", "艾拉", "进度检查"],
        "intent": "进度查询与催促"
      },
      
      "compressed_process": {
        "actions": [
          "读取 shared/status.json",
          "发现艾拉状态为 'designing_login_page'",
          "spawn 艾拉查询进度",
          "收到完成通知"
        ],
        "spawned_agents": ["ella"],
        "files_accessed": ["shared/status.json", "shared/designs/login.fig"],
        "tools_used": ["ReadFile", "Task"]
      },
      
      "outcome": {
        "status": "success",
        "result_summary": "艾拉已完成登录页设计，交付给贾维斯开发",
        "deliverables": ["login-page-v2.fig"],
        "next_steps": ["贾维斯开始开发登录功能"]
      },
      
      "resources": {
        "input_tokens": 850,
        "output_tokens": 1200,
        "cost_usd": 0.023,
        "duration_seconds": 180
      },
      
      "compression_ratio": 0.15,
      "retrieval_score": 0.92
    }
  ]
}
```

### 2. 每日摘要文件: `{YYYY-MM-DD}-summary.json`

高度压缩的当天概况，用于快速恢复上下文：

```json
{
  "date": "2026-03-02",
  "agent": "max",
  "summary": "今日主要协调登录页设计交付，spawn 艾拉1次。项目整体进度正常。",
  "key_topics": ["登录页设计", "进度协调", "艾拉交付"],
  "active_projects": ["登录功能模块"],
  "pending_items": ["贾维斯开发登录功能"],
  "blockers": [],
  "team_status": {
    "ella": "已完成登录页，待新任务",
    "jarvis": "开发登录功能中",
    "kyle": "待命中"
  },
  "total_interactions": 5,
  "total_tokens": 12500,
  "compression_ratio": 0.08
}
```

### 3. 索引文件: `index.json`

```json
{
  "agent": "max",
  "last_updated": "2026-03-02T18:30:00+08:00",
  "total_entries": 150,
  "total_days": 30,
  "daily_files": [
    {"date": "2026-03-02", "entries": 5, "file": "2026-03-02.json"},
    {"date": "2026-03-01", "entries": 8, "file": "2026-03-01.json"}
  ],
  "topic_index": {
    "登录功能": ["max_20260302_001", "max_20260301_003"],
    "Bug修复": ["max_20260228_002"]
  },
  "hot_keywords": ["登录页", "艾拉", "进度", "交付"]
}
```

---

## 压缩策略

### 压缩等级

| 等级 | 目标压缩率 | 适用场景 | 保留内容 |
|------|-----------|---------|---------|
| L1 - 轻度 | 50% | 简单问答 | 完整输入 + 摘要输出 |
| L2 - 标准 | 20% | 常规任务 | 压缩输入 + 行动摘要 |
| L3 - 深度 | 10% | 复杂任务 | 关键词 + 关键结果 |
| L4 - 极致 | 5% | 超长任务 | 主题标签 + 结果状态 |

### 自动压缩提示词

AI 在记录记忆时必须使用以下压缩模板：

```markdown
## 记忆压缩任务

请将以下任务记录压缩到 {target_ratio}% 的信息密度：

**原始内容**:
- 用户输入: {user_input}
- 处理过程: {process_details}
- 输出结果: {output_result}

**压缩要求**:
1. 用户输入保留核心意图，不超过50字
2. 提取 3-5 个关键词
3. 处理过程只记录关键行动（使用动词+名词格式）
4. 结果只保留状态和核心交付物
5. 标注涉及的文件和 Agent

**输出格式** (JSON):
{
  "compressed_input": "...",
  "keywords": [...],
  "actions": [...],
  "outcome": "...",
  "entities": [...]
}
```

---

## 记忆操作流程

### 任务完成时（强制）

```
用户任务完成
    ↓
🧠 第8检查点 - 记忆记录
    ↓
1. 评估压缩等级 (L1-L4)
    ↓
2. 提取关键信息
   - 用户意图摘要
   - 关键词提取
   - 行动摘要
   - 结果状态
    ↓
3. 生成记忆条目
    ↓
4. 写入 memory/{agent}/{date}.json
    ↓
5. 更新 index.json
    ↓
6. (可选) 更新 topic 聚类
    ↓
✅ 输出: "🧠 记忆已记录: {entry_id} (压缩率: {ratio})"
```

### 会话启动时

```
Agent 启动
    ↓
1. 检查 memory/{agent}/index.json
    ↓
2. 读取最近的 {date}-summary.json
    ↓
3. 提取关键上下文:
   - 活跃项目
   - 待处理事项
   - 团队成员状态
    ↓
4. 在问候语中显示: "📋 接上次的进度: ..."
```

---

## 工具脚本使用

### memory/utils.sh

```bash
# 记录记忆
./memory/utils.sh record max "用户输入" "处理结果" "token消耗"

# 查询记忆
./memory/utils.sh query max "登录页" --limit 5

# 获取今日摘要
./memory/utils.sh today max

# 获取会话恢复上下文
./memory/utils.sh resume max
```

---

## 记忆检索策略

### 上下文恢复优先级

1. **当前会话** (100% 权重)
   - 当前对话历史

2. **今日记忆** (80% 权重)
   - 同一天的交互记录

3. **相关主题** (60% 权重)
   - topic_index 中相关条目

4. **关键词匹配** (40% 权重)
   - hot_keywords 匹配

5. **历史摘要** (20% 权重)
   - 过去7天的 summary

### RAG 风格检索

```
用户新查询: "登录页还有问题吗"
    ↓
1. 关键词提取: ["登录页", "问题"]
    ↓
2. 检索记忆:
   - 今日是否有登录页相关记录？
   - 历史记忆中登录页相关条目
   - 涉及"问题/Bug"的记录
    ↓
3. 组装上下文:
   "根据之前的记录，登录页设计已完成交付给贾维斯，
    目前没有发现 Bug 记录。"
```

---

## 实施检查清单

### 对每个 Agent 必须：

- [ ] 创建 memory/{agent}/ 目录
- [ ] 创建初始 index.json
- [ ] 在 CLAUDE.md 中添加第8检查点
- [ ] 修改启动脚本加载记忆
- [ ] 测试记忆记录和检索

### 记忆质量检查：

- [ ] 压缩率是否达到目标 (10-20%)
- [ ] 关键词是否准确提取
- [ ] 时间戳是否正确
- [ ] 文件引用是否完整
- [ ] 索引是否及时更新

---

## 故障排除

### 记忆文件过大

```bash
# 归档旧记忆
./memory/utils.sh archive max --before "2026-02-01"
```

### 索引损坏

```bash
# 重建索引
./memory/utils.sh rebuild-index max
```

### 压缩质量差

- 检查 compression-prompt.md 是否正确加载
- 调整压缩等级
- 人工审核并修正关键条目
