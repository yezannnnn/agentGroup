# 🗜️ 记忆压缩提示词模板

## 使用场景

在任务完成后，AI Agent 必须使用此模板压缩任务记录，然后保存到记忆系统。

---

## 压缩等级定义

### L1 - 轻度压缩 (50%)
**适用**: 简单问答、查询类任务
```json
{
  "compressed_input": "用户原始输入的前50字...",
  "keywords": ["关键词1", "关键词2"],
  "actions": ["回答用户问题"],
  "outcome": "已回答"
}
```

### L2 - 标准压缩 (20%) ⭐ 默认
**适用**: 常规任务协调、状态更新
```json
{
  "compressed_input": "核心意图摘要（不超过50字）",
  "keywords": ["关键词1", "关键词2", "关键词3"],
  "actions": ["行动1", "行动2", "行动3"],
  "outcome": "结果状态 + 关键交付物"
}
```

### L3 - 深度压缩 (10%)
**适用**: 复杂多步骤任务
```json
{
  "compressed_input": "极度精简的意图（20字内）",
  "keywords": ["关键词1", "关键词2"],
  "actions": ["关键行动1", "关键行动2"],
  "outcome": "成功/失败 + 核心结果"
}
```

### L4 - 极致压缩 (5%)
**适用**: 超长任务、需要极大上下文节省
```json
{
  "compressed_input": "主题标签",
  "keywords": ["标签1", "标签2"],
  "actions": ["完成多步骤任务"],
  "outcome": "完成"
}
```

---

## 压缩执行模板

### 步骤 1: 确定压缩等级

```
任务类型判断:
├─ 简单问答 (1-2轮对话) → L1
├─ 常规协调 (spawn, 状态更新) → L2 ⭐
├─ 复杂任务 (3+步骤, 多文件) → L3
└─ 超长任务 (>5000 tokens) → L4
```

### 步骤 2: 提取关键信息

**用户输入压缩**:
- 去除礼貌用语、语气词
- 保留核心动词和对象
- 示例: "请问你能帮我检查一下登录页面的设计进度怎么样了嘛？" → "检查登录页设计进度"

**关键词提取** (3-5个):
- 实体名词: "登录页", "艾拉", "status.json"
- 动作关键词: "检查", "spawn", "交付"
- 状态关键词: "完成", "阻塞", "待处理"

**行动摘要** (动词 + 名词格式):
- ❌ "我首先读取了 shared/status.json 文件来查看当前状态"
- ✅ "读取 status.json"
- ❌ "然后我发现艾拉的状态是正在设计中"
- ✅ "发现艾拉状态: designing"
- ❌ "于是我 spawn 了艾拉来询问进度"
- ✅ "spawn 艾拉查询进度"

**结果压缩**:
- 保留: 成功/失败状态、关键交付物、下一步
- 去除: 详细过程、中间状态、思考过程

### 步骤 3: 生成记忆条目

```markdown
## 记忆压缩任务

**原始记录**:
- 用户输入: {完整用户输入}
- 处理过程: {详细处理步骤}
- 输出结果: {完整输出}
- Token消耗: {input}/{output}
- 涉及文件: {files}
- Spawn记录: {agents}

**压缩要求**:
等级: {L1/L2/L3/L4}
目标压缩率: {50%/20%/10%/5%}

**请输出** (JSON格式):
{
  "compressed_input": "核心意图摘要（严格字数限制）",
  "keywords": ["关键词1", "关键词2", "关键词3", "关键词4", "关键词5"],
  "actions": ["行动1", "行动2", "行动3"],
  "outcome": "结果摘要",
  "entities": {
    "agents_involved": ["agent1", "agent2"],
    "files_accessed": ["file1", "file2"],
    "deliverables": ["deliverable1"]
  },
  "compression_ratio": 0.15
}
```

---

## 压缩质量检查

压缩完成后必须自检：

```
✅ 压缩输入是否保留了核心意图？
✅ 关键词是否覆盖了用户关心的重点？
✅ 行动摘要是否可追溯任务流程？
✅ 结果是否记录了关键状态？
✅ 压缩率是否达标？
```

---

## 示例

### 示例 1: 进度查询任务 (L2)

**原始记录**:
```
用户: "麦克斯，帮我看看登录页面的设计进度怎么样了？艾拉是不是还在做？"
处理: 1. 读取 shared/status.json
      2. 发现艾拉状态为 "designing_login_page"
      3. 读取 shared/designs/login.fig
      4. 发现设计完成度 90%
      5. spawn 艾拉询问具体进度
      6. 艾拉回复: 今天可以完成
输出: "艾拉的设计进度 90%，今天可以完成交付。我会继续跟进。"
Tokens: 输入 450, 输出 320
```

**压缩后**:
```json
{
  "compressed_input": "查询登录页设计进度",
  "keywords": ["登录页", "设计进度", "艾拉", "交付"],
  "actions": ["读取 status.json", "检查设计文件", "spawn 艾拉", "收到进度回复"],
  "outcome": "设计进度90%，今日可交付",
  "entities": {
    "agents_involved": ["ella"],
    "files_accessed": ["shared/status.json", "shared/designs/login.fig"],
    "deliverables": ["进度确认"]
  },
  "compression_ratio": 0.18
}
```

### 示例 2: Bug 修复协调 (L3)

**原始记录** (多轮 spawn):
```
用户: "登录按钮点击没反应，让凯尔看看"
处理: Kyle 发现 Bug → spawn Jarvis 修复 → Jarvis 修复完成 → Kyle 验证通过
涉及: 3 个 agent 协作，5 个文件修改
Tokens: 3500+
```

**压缩后**:
```json
{
  "compressed_input": "修复登录按钮无响应Bug",
  "keywords": ["登录按钮", "Bug修复", "凯尔", "贾维斯"],
  "actions": ["Kyle发现Bug", "spawn Jarvis修复", "验证通过"],
  "outcome": "Bug已修复，验证通过",
  "entities": {
    "agents_involved": ["kyle", "jarvis"],
    "files_accessed": ["login.js", "auth.service.ts"],
    "deliverables": ["Bug修复"]
  },
  "compression_ratio": 0.08
}
```

---

## 存储格式

压缩后的数据写入 `memory/{agent}/{YYYY-MM-DD}.json`:

```json
{
  "id": "max_20260302_a1b2",
  "timestamp": "2026-03-02T14:30:00+08:00",
  "compressed_input": {
    "compressed": "查询登录页设计进度",
    "keywords": ["登录页", "设计进度", "艾拉", "交付"],
    "intent": "进度查询"
  },
  "compressed_process": {
    "actions": ["读取 status.json", "spawn 艾拉"],
    "spawned_agents": ["ella"],
    "files_accessed": ["shared/status.json"]
  },
  "outcome": {
    "status": "success",
    "result_summary": "设计进度90%，今日可交付"
  },
  "resources": {
    "input_tokens": 450,
    "output_tokens": 320
  },
  "compression_ratio": 0.18
}
```
