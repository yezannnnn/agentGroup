# PRD: Aegis Prompt Hook — AI 命令安全分析

**日期**: 2026-05-12  
**状态**: 待实施  
**作者**: Max (PM)  
**开发**: 贾维斯  

---

## 一、背景与问题

Aegis 当前的拦截机制是纯规则引擎（YAML 规则匹配 AST），能覆盖已知危险模式，但有两个盲区：

1. **规则匹配不到的命令**：规则库是有限的，新型危险命令写法可能漏网
2. **没有意图对比**：规则引擎只看命令本身，不知道用户本来想做什么

Claude Code 提供了 `type: "prompt"` 的 PreToolUse Hook，可以让 Claude Code **调用自己的模型**对工具调用做分析。这个功能：
- 零配置：用 Claude Code 本身的认证，用户不需要另配 API key
- 可并行：与现有 command hook 同时运行，任何一个说 deny 就拦截

---

## 二、方案设计

### Hook 类型

```json
{
  "matcher": "Bash",
  "hooks": [{
    "type": "prompt",
    "prompt": "<见下方模板>",
    "model": "claude-haiku-4-5-20251001",
    "timeout": 8,
    "statusMessage": "🛡️ Aegis AI analyzing..."
  }]
}
```

### Prompt 模板设计原则

Claude 收到的输入是 `$ARGUMENTS`，即完整的 hook 输入 JSON，包含：
- `tool_input.command` — 被执行的 bash 命令
- `cwd` — 当前工作目录
- `transcript_path` — 会话记录文件路径（含用户原始意图）
- `session_id` — 会话 ID

Claude 必须返回合法 JSON（无 markdown 包裹）：
```json
{
  "permissionDecision": "allow" | "deny" | "ask",
  "reason": "<100字以内>"
}
```

三个决策含义：
- `allow` — 放行（Claude Code 继续执行）
- `deny` — 拦截，显示 reason（Claude Code 终止执行）
- `ask` — 升级给用户确认

### Prompt 模板（贾维斯可调整措辞，但结构保持）

```
You are Aegis, a shell command safety monitor. Analyze the bash command below and decide if it's safe to run.

Hook input JSON:
$ARGUMENTS

STEP 1 — Extract the command from tool_input.command.

STEP 2 — Is this command CLEARLY SAFE? (ls, cat, git status, npm install, echo, pwd, grep, find -name, cd, mkdir, cp, touch, etc.)
  → If yes: immediately respond {"permissionDecision":"allow","reason":"safe"}

STEP 3 — Is this command DESTRUCTIVE and IRREVERSIBLE?
  Examples: rm -rf, rmdir with content, DROP TABLE, git push --force to main/master, truncate, shred, dd if=/dev/zero
  → If yes: respond {"permissionDecision":"deny","reason":"<one sentence why>"}

STEP 4 — Is this RISKY but intent is AMBIGUOUS? (could be an accident, affects files outside the project, etc.)
  → respond {"permissionDecision":"ask","reason":"<one sentence why>"}

Rules:
- Respond ONLY with valid JSON, no markdown, no extra text.
- Keep reason under 100 characters.
- When in doubt between deny and ask, choose ask.
- Do NOT block build tools, package managers, test runners, or git read operations.
```

---

## 三、实现要求

### 3.1 写入位置

`bin/setup-utils.js` → `setupClaudeCodeHook()` 方法内，在 command hook push 之后追加：

```javascript
// 清理旧的 prompt hook（防止重复）
settings.hooks.PreToolUse = settings.hooks.PreToolUse.filter(
  h => !JSON.stringify(h).includes('"type":"prompt"') || 
       !JSON.stringify(h).includes('Aegis')
);

// 写入新的 prompt hook
settings.hooks.PreToolUse.push({
  matcher: 'Bash',
  hooks: [{
    type: 'prompt',
    prompt: AEGIS_PROMPT_HOOK,   // 顶部常量
    model: 'claude-haiku-4-5-20251001',
    timeout: 8,
    statusMessage: '🛡️ Aegis AI analyzing...',
  }]
});
```

### 3.2 Prompt 常量位置

在 `bin/setup-utils.js` 文件顶部（`class AegisSetupUtils` 之前）定义常量 `AEGIS_PROMPT_HOOK`。

### 3.3 去重逻辑

`setup-utils.js` 现有对 command hook 的去重是检查 `.aegis` 字符串：
```javascript
settings.hooks.PreToolUse = settings.hooks.PreToolUse.filter(
  h => !JSON.stringify(h).includes('.aegis')
);
```

Prompt hook 没有 `.aegis` 路径，需要单独的去重逻辑（检查 `type: prompt` + Aegis 关键词）。

---

## 四、不在本期范围内

| 项目 | 原因 |
|------|------|
| 把 AI 分析结果显示在 ApprovalModal | Prompt Hook 与 command hook 并行，结果无法传到 modal |
| 支持其他 AI 提供商（OpenAI / DeepSeek） | Prompt Hook 只用 Claude Code 自己的模型 |
| 修改 backend 规则引擎 | 两个 hook 各自独立运行 |
| transcript_path 意图对比 | Phase 2 功能，需要更复杂的 prompt 工程 |

---

## 五、运行时行为示意

```
用户在 Claude Code 里让 AI 执行 bash 命令
    ↓
PreToolUse 同时触发
    ├── [command hook] universal-hook.js
    │       → 规则引擎匹配
    │       → allow / block / review
    │
    └── [prompt hook] Claude Code 调 Haiku
            → 状态栏显示 "🛡️ Aegis AI analyzing..."
            → Haiku 分析 $ARGUMENTS
            → {"permissionDecision": "deny", "reason": "rm -rf is irreversible"}
            → Claude Code 直接拦截，显示 reason

两个 hook 任意一个 deny → 命令不执行
```

---

## 六、给贾维斯的开发备注

1. **先在本地验证 prompt 效果**：可以把 prompt 直接发给 Claude 测几条命令（ls、rm -rf、git push --force），确认返回的 JSON 格式正确后再写进代码

2. **timeout 设为 8 秒**：Haiku 很快，正常 2-3 秒内响应；超时的话 Claude Code 会自动 allow，不会卡住用户

3. **不要改 command hook 的任何逻辑**：两个 hook 完全独立，prompt hook 是新增的附加层

4. **model 字段**：用 `claude-haiku-4-5-20251001`（最新 Haiku）。如果 Claude Code 版本不支持这个 model ID，fallback 到 `claude-haiku-4-5`
