# Task: 实施-规则任务文件小程序支持

## 基本信息
- **任务名称**: 规则任务文件/小程序支持实施
- **发起者**: Max
- **当前负责人**: Jarvis
- **创建时间**: 2026-04-03
- **最后更新**: 2026-04-03

## 任务层级
- **当前层级**: Layer 2
- **父任务**: 用户需求
- **子任务**: 无

## 实施范围
1. 数据库迁移 - messages 表新增 appmsg_type
2. GeWeService - 新增 postFile/postMiniApp
3. MessageParserService - 解析小程序消息
4. MessageQueueService - 处理文件/小程序发送
5. RuleTaskExecutor - 传递小程序参数

## 完成标准
- [x] Phase 1: 数据库迁移完成 - `sql/migration_add_appmsg_type_20260403.sql`
- [x] Phase 2: GeWeService postFile/postMiniApp 完成
- [x] Phase 3: MessageParserService 小程序解析完成
- [x] Phase 4: MessageQueueService 文件/小程序处理完成
- [x] Phase 5: RuleTaskExecutor 小程序参数传递完成
- [ ] Phase 6: 前端开发待执行

## 阻塞点
- ⚠️ 数据库迁移 SQL 需手动执行

## 完成标准
- [x] Phase 1-5: 后端开发完成
- [x] Phase 6.1: MiniAppCard.vue 创建完成
- [x] Phase 6.2: RuleTaskEditor.vue 修改完成
- [x] Phase 6.3: ChatPanel.vue 修改完成

## 完成标准
- [x] Phase 1-5: 后端开发完成
- [x] Phase 6.1: MiniAppCard.vue 创建完成
- [x] Phase 6.2: RuleTaskEditor.vue 修改完成
- [x] Phase 6.3: ChatPanel.vue 修改完成
- [x] 数据库迁移验证通过
- [x] 后端编译通过
- [x] 前端编译通过
- [x] 集成测试通过

## 阻塞点
- 无

## 下一步行动
- 全部完成，等待部署
