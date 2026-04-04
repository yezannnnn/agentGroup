# project-management 项目管理

## ADDED Requirements

### Requirement: 项目列表查询
用户可查询项目列表，支持分页和筛选。

#### Scenario: 分页查询项目
- **WHEN** 调用 `GET /api/project/page`
- **THEN** 返回分页后的项目列表

#### Scenario: 按地区筛选项目
- **WHEN** 调用 `GET /api/project/page?areaCode=xxx`
- **THEN** 返回符合筛选条件的项目列表

### Requirement: 项目详情查看
用户可查看单个项目详情。

#### Scenario: 查看项目详情
- **WHEN** 调用 `GET /api/project/{projectId}`
- **THEN** 返回项目完整信息

#### Scenario: 项目不存在
- **WHEN** 调用 `GET /api/project/{不存在ID}`
- **THEN** 返回错误码，项目不存在

### Requirement: 新增项目
用户可新增项目，支持手动输入编号或自动获取。

#### Scenario: 手动输入项目编号
- **WHEN** 提交新项目时 project_num 不为空
- **THEN** 使用用户输入的编号保存

#### Scenario: 自动获取项目编号
- **WHEN** 提交新项目时 project_num 为空
- **THEN** 调用 M7 流水号服务获取编号，格式 `PROJ-YYYYMMDD-NNNNNN`

#### Scenario: 项目编号唯一性校验
- **WHEN** 提交新项目或编辑项目时 project_num 与其他项目重复
- **THEN** 返回错误，项目编号已存在

### Requirement: 编辑项目
用户可编辑项目信息。

#### Scenario: 编辑项目
- **WHEN** 调用 `PUT /api/project/{projectId}`
- **THEN** 更新项目信息，返回更新后的详情

#### Scenario: 编辑时修改编号
- **WHEN** 编辑时同时修改 project_num
- **THEN** 系统校验新编号的唯一性

### Requirement: 删除项目
用户可删除项目。

#### Scenario: 删除项目
- **WHEN** 调用 `DELETE /api/project/{projectId}`
- **THEN** 物理删除项目记录

### Requirement: 启用/禁用项目
用户可切换项目的启用状态。

#### Scenario: 禁用项目
- **WHEN** 调用 `PUT /api/project/{projectId}/disable`
- **THEN** 项目的 enabled 字段设为 0

#### Scenario: 启用项目
- **WHEN** 调用 `PUT /api/project/{projectId}/enable`
- **THEN** 项目的 enabled 字段设为 1
