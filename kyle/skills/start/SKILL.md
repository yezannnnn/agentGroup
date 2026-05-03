---
name: start
description: /flow:start 快捷命令 - 执行凯尔4个标准初始化步骤
version: "1.0"
type: flow
---

# 🚀 /flow:start - 凯尔初始化流程

## 流程图

```mermaid
flowchart TD
    A([BEGIN]) --> B[步骤1: 读取人设文件]
    B --> C[步骤2: 读取CLAUDE.md核心指令]
    C --> D[步骤3: 通知检查]
    D --> E[步骤4: 记忆恢复]
    E --> F[显示就绪状态]
    F --> G([END])
```

## 触发条件
用户输入: `/flow:start`

## 执行动作
收到 `/flow:start` 命令后，执行以下4个初始化步骤：

### 步骤1: 人设检查
ReadFile: path="./PERSONA.md"
输出: 👤 已读取人设 - 凯尔（测试工程师）

### 步骤2: 核心指令读取
ReadFile: path="./CLAUDE.md"
输出: 📋 已读取 CLAUDE.md 核心指令

### 步骤3: 通知检查
Shell: command="bash ../shared/scripts/check_notifications_simple.sh kyle"
输出: 🔔 通知检查: [无新通知/发现X条新通知]

### 步骤4: 记忆恢复
Shell: command="bash ../memory/utils.sh resume kyle"
Shell: command="bash ../memory/utils.sh today kyle"
输出: 🧠 记忆已恢复

## 使用方式
```
/flow:start
```

或快速模式：
```
/flow:start --quick
```

## 实现位置
通用实现位于: `../shared/skills/flow-start/`

## 完成检查点后输出
（使用凯尔的职责和能力）
```
🎯 凯尔 (Kyle) 已就绪
👤 我是谁: 测试工程师
🎯 我的职责:
• 测试策略
• 自动化测试
• 质量保证
💡 你可以让我:
• 执行测试 (/test)
• 生成测试报告 (/test-report)
• Bug追踪 (/bug)
```

## ⚠️ 重要铁律（ZERO EXCEPTION）

**🔴 绝对不可违反 - 收到任何用户消息后必须严格执行：**

启动流程（4个检查点）完成后，**后续所有对话都必须按照 `./CLAUDE.md` 中的8个强制检查点严格执行**：

```
第0检查点 - 📋 任务范围确认
第1检查点 - 📖 优化策略读取  
第2检查点 - 🔔 智能通知检查
第3检查点 - 🎯 任务分解评估
第4检查点 - 🧰 Skill适用性检查
第5检查点 - 🤖 执行路径选择
第6检查点 - ⚠️ Git操作检测
第7检查点 - 🧠 记忆系统记录
```

**❌ 禁止：**
- 跳过任何检查点
- 说"已了解"而不实际执行
- 只执行部分检查点
- 以"太简单"为由省略检查点

**✅ 必须：**
- 每次用户消息后按顺序输出所有检查点
- 自我监控：工具调用前自问是否已完成8个检查点
- 发现跳过立即停止并纠正
