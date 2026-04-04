# 子计划 10：启动脚本与全局说明文档更新

> 完成所有的架构文件迁移后，对基础执行命令以及团队的大本营知识图谱说明文档进行适配。

## 目标

为新拆离的前后端专属开发重新配置命令行进入挂载口。同时更新项目的入口级文档（README 和 Skills 分布结构）。

## 前置条件

- 已完成之前 [子计划01 到 09] 所有的核心架构与角色的配置及分布落位。

## 执行清单

### 10.1 翻新顶层启动脚本 (.sh / .bat 等批处理工具)

创建供 Claude Code/终端 操作直接接入 v2 的新环境快捷方式脚本。

- [ ] 10.1.1 复制原有的基础并修改 Max 启动配置（`agent-group-v2/start-max.sh`）：
  指明新的模型读取路劲，和新的 `.claude/settings.local.json` 规则映射环境。
- [ ] 10.1.2 修改 Ella (`start-ella.sh`)
- [ ] 10.1.3 修改 Kyle (`start-kyle.sh`)
- [ ] 10.1.4 新建前端启动脚 `start-jarvis-fe.sh`：
  挂载点明确指向 `agent-group-v2/jarvis-fe`。
- [ ] 10.1.5 新建后端启动脚 `start-jarvis-be.sh`：
  挂载点明确指向 `agent-group-v2/jarvis-be`。
- [ ] 10.1.6 移除或者在原本的 `start-jarvis.sh` 内抛出 echo 阻断运行以示废除。

*(注：此处可提供一个配套在实际前后端项目端(`cloud-frontend` / `cloud-backend`)里的 `.claude/project.md` 的引用建议。建议可以在真实的前后端项目里的 project 描述里写入关联此处的引导。)*

### 10.2 重编项目门面 README.md 与面板

全面修改向导性质文件，抹除原大一统时期的叙事逻辑和演示配置架构。

- [ ] 10.2.1 更新 `README.md`，列示出 V2 版的架构：
  - 更新项目简介，写明 "4+1" 体系（Max/Ella/Kyle + Jarvis[FE/BE]双端分离）。
  - 更新使用指引，明确使用 `start-jarvis-xxx` 取代之前的启动方式。
  - 说明 `openspec` 这个新驱动心脏的概念。
- [ ] 10.2.2 如有 `panel.sh` 或终端 GUI 面板管理界面的文件，亦需更新挂载项。

### 10.3 重新梳理 Skills 边界地图

原有的 `skills-distribution.md` 记载了各大角色与超能力库的区别和运用场合，如今发生重大拆借，必须重写。

- [ ] 10.3.1 更新 `skills-distribution.md` 的版图分布概念。
  将后端独立为 `java-backend`, `tdd-guide(主)` ；前端独立出 `react-frontend`, `senior-frontend` 等。

## 验证清单

- [ ] 所有 `start-*.sh` 启动脚本都可以无错误抛异常地正常启动终端加载到对应角色的 `CLAUDE.md` 信息。
- [ ] `README.md` 中已经移除了关于大一统全栈 Jarvis 描述的冗余字段，并且展现了最新协作的图表。
- [ ] Skills 的归属对照表没有任何的错位或者未更新的旧路经依赖。

## 注意事项

脚本修改一定要和 CLI 的命令特征兼容。务必实测在工作目下输入对应调用拉起指令能否不串台、不报错。
