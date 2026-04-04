# Phase 0: 准备期 (基建搭建与配置准备)

## 0.1 阶段目标
本阶段致力于**“前置铺路”**，重点是在不打断当前 Agent 开发团队正在进行的项目任务及协作流的前提下，把需要用到的目录架构、模板文件以及共享底层协议创建好。

## 0.2 执行动作详情

### 动作 1：创建全套新目录架构
需要在原工程目录 `agent-group/` 内补全以下目录树（如果不存在则新建）：
```text
agent-group/
├── jarvis-fe/                  # 新增：前端开发 Agent 入口
├── jarvis-be/                  # 新增：后端开发 Agent 入口
├── openspec/archive/           # 新增：用于存放归档的需求记录
└── shared/
    ├── handoff/
    │   ├── fe-to-be/           # 新增：前端找后端的协商池
    │   ├── be-to-fe/           # 新增：后端找前端的协商池
    │   ├── max-inbox/          # 新增：专门存放要求 Max 处理的正式固化请求
    │   └── archive/            # 新增：Handoff 协商记录池归档管理
    └── protocols/              # 新增：存放硬性通用协议
```

### 动作 2：提炼和创建强约束共享协议
目前各角色的 `CLAUDE.md` 内充斥着重复的基础设定和规范（容易导致 Token 膨胀）。建立公共的第一性原则。

**1. 创建通用协议文件**
在 `shared/protocols/mandatory-flow.md` 写入以下核心指令作为团队基底强制要求：
```markdown
# 第一性约束
1. 只根据实际读取到的代码、文件、命令结果回答。
2. 不编造接口、路径、配置、错误信息。
3. 信息不足时先说明缺口，再说明如何获取，不做推测性结论。
4. 涉及结论必须可验证。
```

**2. 精简现存所有角色 `CLAUDE.md`**
规划在现有的 Max, Ella, Kyle 以及即将新建的 jarvis-fe, jarvis-be 的 `CLAUDE.md` 最顶部加入对该文件的强引用，从而缩减其配置提及：
```markdown
读取并遵循 `../shared/protocols/mandatory-flow.md`
```
除此之外各角色仅保留与自己身份高度绑定的：任务入口规则、技能使用规则、读写契约与下层目录获取方式。

## 0.3 阶段验收基准 (Definition of Done)
1. 在运行以上变更动作期间，现有的开发流程（如老 Jarvis 和 Max 持续交互）不受任何中断。
2. 上述目录和新协议文件真实可见。
3. `.claude/` 中的 `settings.local.json` 配置并未被破坏。

## 0.4 回退策略 (Rollback)
由于本阶段全部为纯增量的目录搭建不涉及逻辑流转改变。如果发现异常或项目空间加载卡顿：
1. 删除 `mandatory-flow.md`。
2. 移除空的新建 `jarvis-fe/`, `jarvis-be/` 及 `handoff/` 子目录，不影响原有主线。
