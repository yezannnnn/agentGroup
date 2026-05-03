# 🧠 aiGroup 记忆系统 - 快速参考

## 功能概述

aiGroup 记忆系统为每个 Agent 提供上下文压缩和持久化能力：
- ✅ 每次任务完成后自动记录压缩记忆
- ✅ 按日期存储，支持追加写入
- ✅ 关键词提取和上下文压缩（目标压缩率 10-20%）
- ✅ 启动时自动恢复上次会话上下文
- ✅ 跨会话记忆继承

---

## 文件结构

```
memory/
├── SKILL.md                    # 系统规范文档
├── utils.sh                    # 工具脚本（读写/查询/压缩）
├── compression-prompt.md       # AI 压缩提示词模板
├── README.md                   # 本文件
│
├── max/                        # 麦克斯的记忆
│   ├── index.json              # 索引和统计
│   ├── 2026-03-02.json         # 每日记忆
│   └── 2026-03-02-summary.json # 每日摘要（自动生成）
│
├── ella/                       # 艾拉的记忆
├── jarvis/                     # 贾维斯的记忆
└── kyle/                       # 凯尔的记忆
```

---

## 命令行工具

### 初始化记忆系统
```bash
./memory/utils.sh init max    # 为 max 初始化
```

### 记录记忆
```bash
./memory/utils.sh record <agent> <"压缩输入"> <"关键词"> <"行动"> <"结果"> [tokens] [类型]

# 示例
./memory/utils.sh record max "检查登录进度" "登录页,设计,艾拉" "读取status,spawn艾拉" "艾拉完成90%" 1200 project_mgmt
```

### 查询记忆
```bash
./memory/utils.sh query <agent> <关键词> [数量限制]

# 示例
./memory/utils.sh query max "登录页" 5
```

### 今日摘要
```bash
./memory/utils.sh today <agent>

# 示例
./memory/utils.sh today max
```

### 获取恢复上下文
```bash
./memory/utils.sh resume <agent>

# 示例（启动脚本自动调用）
./memory/utils.sh resume max
```

### 生成每日摘要
```bash
./memory/utils.sh summary <agent> [日期]

# 示例
./memory/utils.sh summary max 2026-03-02
```

### 查看统计
```bash
./memory/utils.sh stats
```

---

## 记忆文件格式

### 每日记忆: `{YYYY-MM-DD}.json`

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
      "id": "max_20260302_a1b2",
      "timestamp": "2026-03-02T14:30:00+08:00",
      "compressed_input": {
        "compressed": "检查登录页设计进度",
        "keywords": ["登录页", "设计", "艾拉", "进度"],
        "intent": "进度查询"
      },
      "compressed_process": {
        "actions": ["读取 status.json", "spawn 艾拉"],
        "spawned_agents": ["ella"],
        "files_accessed": ["shared/status.json"]
      },
      "outcome": {
        "status": "success",
        "result_summary": "艾拉已完成设计90%，今日可交付"
      },
      "resources": {
        "input_tokens": 450,
        "output_tokens": 320
      },
      "compression_ratio": 0.18
    }
  ]
}
```

---

## 压缩等级

| 等级 | 压缩率 | 适用场景 | 说明 |
|------|--------|----------|------|
| L1 | 50% | 简单问答 | 保留完整意图 |
| L2 | 20% | 常规任务 | 默认等级 |
| L3 | 10% | 复杂任务 | 高度压缩 |
| L4 | 5% | 超长任务 | 仅保留标签 |

---

## 强制流程集成

### 第8检查点 - 记忆系统记录

在 CLAUDE.md 中，每个 Agent 都必须在任务完成后执行：

```
✅ 输出格式: "🧠 记忆系统: [记录完成] 压缩率: XX%"
✅ 必须:
   1. 读取 memory/compression-prompt.md
   2. 提取关键词和实体
   3. 压缩用户输入（≤50字）
   4. 压缩处理过程（动词+名词）
   5. 记录结果状态
   6. 调用 utils.sh record 写入
```

---

## 启动时记忆恢复

启动脚本会自动：
1. 调用 `./memory/utils.sh resume <agent>` 获取上下文
2. 在问候语中显示：
   ```
   📊 记忆恢复:
   📅 上次活跃: 2026-03-02
   📝 最近记录: 检查登录页设计进度...
   ```

---

## 测试记忆系统

```bash
# 1. 记录一条测试记忆
./memory/utils.sh record max "测试记忆功能" "测试,记忆" "记录测试数据" "测试成功" 100 test

# 2. 查询记忆
./memory/utils.sh query max "测试"

# 3. 查看今日摘要
./memory/utils.sh today max

# 4. 查看统计
./memory/utils.sh stats
```

---

## 故障排除

### 记忆文件过大
```bash
# 归档旧记忆（手动清理）
mv memory/max/2026-02-*.json memory/archive/
```

### 重建索引
```bash
# 删除索引文件后重新初始化
rm memory/max/index.json
./memory/utils.sh init max
```

### 检查记忆记录
```bash
# 查看最新记忆文件
cat memory/max/$(date +%Y-%m-%d).json | head -50
```
