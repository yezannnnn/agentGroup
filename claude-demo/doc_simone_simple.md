# Claude Simone 简明使用手册

Simone 是为 Claude Code 设计的项目管理框架，通过结构化任务和上下文管理，让 AI 始终以完整项目背景工作。

> 📖 详细说明见 [doc_simone.md](./doc_simone.md)

---

## 一、安装（只做一次）

```bash
npx hello-simone
```

在项目根目录运行，自动创建 `.simone/` 文件夹和命令文件。

---

## 二、快速入门（6 步）

```
# 1. 初始化项目（只做一次）
/simone:initialize

# 2. 手动在 .simone/02_REQUIREMENTS/ 创建里程碑文件夹
#    例如：M01_Backend_Setup/M01_PRD.md

# 3. 将里程碑拆分为 Sprint
/simone:create_sprints_from_milestone

# 4. 为当前 Sprint 创建任务（只为下一个Sprint创建，不要一次全建）
/simone:create_sprint_tasks

# 5. 开始干活
/simone:do_task
# 或指定任务：
/simone:do_task T01_S01

# 6. 提交
/simone:commit
```

---

## 三、目录结构

```
.simone/
├── 00_PROJECT_MANIFEST.md     ← 项目核心文档（最重要）
├── 01_PROJECT_DOCS/           ← 通用文档
├── 02_REQUIREMENTS/           ← 里程碑需求（M01_xxx/ 格式）
├── 03_SPRINTS/                ← Sprint 和任务文件
├── 04_GENERAL_TASKS/          ← 零散任务（T001_ / TX001_ 已完成）
├── 05_ARCHITECTURAL_DECISIONS/ ← 架构决策记录
└── 99_TEMPLATES/              ← 模板文件
```

---

## 四、常用命令速查

### 开始工作

| 命令 | 用途 |
|------|------|
| `/simone:prime` | 加载项目上下文，了解当前状态 |
| `/simone:do_task` | 自动选择并执行下一个任务 |
| `/simone:do_task T01_S01` | 执行指定任务 |

### 规划

| 命令 | 用途 |
|------|------|
| `/simone:create_sprints_from_milestone` | 里程碑 → Sprint |
| `/simone:create_sprint_tasks` | Sprint → 任务列表 |
| `/simone:create_general_task` | 创建独立任务（Bug/维护等） |

### 提交与审查

| 命令 | 用途 |
|------|------|
| `/simone:test` | 运行测试 |
| `/simone:commit` | 生成规范 git 提交 |
| `/simone:code_review` | 审查代码变更 |
| `/simone:project_review` | 项目整体健康检查 |

### 自动化

| 命令 | 用途 |
|------|------|
| `/simone:yolo` | 自主执行所有未完成任务（谨慎使用） |
| `/simone:yolo S02` | 自主执行指定 Sprint |

---

## 五、每日工作流

```
早上：/simone:prime          ← 了解今天要做什么

开发：/simone:do_task        ← 干活
      /simone:test           ← 跑测试
      /simone:commit         ← 提交

周期性：/simone:project_review  ← Sprint 结束或每周做一次
```

---

## 六、注意事项

- `00_PROJECT_MANIFEST.md` 文件名必须完全一致，不能改
- 里程碑文件夹命名必须用 `M##_` 前缀，如 `M01_Backend_Setup`
- **只为下一个 Sprint 创建任务**，完成后再创建下一个
- `/simone:initialize` 只在项目接入时运行**一次**
