# Flowable 7 工作流实践指南

> ⚠️ 本文档为骨架，请根据你们团队实际情况填写。

---

## 使用场景说明

> ⚠️ **待填写**：描述你们使用 Flowable 的主要业务场景（如：请假审批/合同审批/物料申请/业务流转等）

---

## 依赖配置

```xml
<!-- pom.xml -->
<dependency>
    <groupId>org.flowable</groupId>
    <artifactId>flowable-spring-boot-starter</artifactId>
    <version>7.0.1</version>
</dependency>
```

```yaml
# application.yml
flowable:
  database-schema-update: true        # 自动更新表结构（生产建议 false，手动管理）
  async-executor-activate: true       # 启用异步执行器
  # TODO: 填写其他 Flowable 配置项
```

---

## BPMN 文件规范

> ⚠️ **待填写**：填写你们 BPMN 文件的存放位置、命名规范

```
存放位置：src/main/resources/processes/
命名规范：{业务模块}_{流程名}.bpmn20.xml
示例：
  leave_apply.bpmn20.xml     # 请假审批
  contract_review.bpmn20.xml # 合同审核
```

---

## 核心 Service 封装

```java
@Service
@Slf4j
public class FlowableProcessService {

    @Autowired
    private RepositoryService repositoryService;  // 流程定义管理
    @Autowired
    private RuntimeService runtimeService;         // 流程实例管理
    @Autowired
    private TaskService taskService;               // 任务管理
    @Autowired
    private HistoryService historyService;         // 历史数据查询
    @Autowired
    private FormService formService;               // 表单服务

    /**
     * 部署流程定义
     */
    public String deployProcess(String bpmnResourcePath, String processName) {
        Deployment deployment = repositoryService.createDeployment()
            .addClasspathResource(bpmnResourcePath)
            .name(processName)
            .deploy();
        log.info("流程部署成功, deploymentId={}, name={}", deployment.getId(), processName);
        return deployment.getId();
    }

    /**
     * 启动流程实例
     * @param processKey   流程定义 Key（BPMN 中 process id）
     * @param businessKey  业务主键（关联业务数据，如申请单ID）
     * @param variables    流程变量（审批人、申请内容等）
     */
    public String startProcess(String processKey, String businessKey, Map<String, Object> variables) {
        ProcessInstance instance = runtimeService.startProcessInstanceByKey(
            processKey, businessKey, variables
        );
        log.info("流程启动成功, instanceId={}, processKey={}, businessKey={}",
            instance.getId(), processKey, businessKey);
        return instance.getId();
    }

    /**
     * 查询我的待办任务
     */
    public List<Task> getMyPendingTasks(String assignee, int firstResult, int maxResults) {
        return taskService.createTaskQuery()
            .taskAssignee(assignee)
            .active()
            .orderByTaskCreateTime().desc()
            .listPage(firstResult, maxResults);
    }

    /**
     * 查询候选组的待办任务（抢单场景）
     */
    public List<Task> getGroupPendingTasks(String groupName) {
        return taskService.createTaskQuery()
            .taskCandidateGroup(groupName)
            .active()
            .orderByTaskCreateTime().desc()
            .list();
    }

    /**
     * 认领任务（候选任务 → 指定给自己）
     */
    public void claimTask(String taskId, String userId) {
        taskService.claim(taskId, userId);
        log.info("任务已认领, taskId={}, userId={}", taskId, userId);
    }

    /**
     * 完成任务（审批通过 / 拒绝）
     * @param variables 包含审批结果的变量（如：approved=true/false, comment=审批意见）
     */
    public void completeTask(String taskId, Map<String, Object> variables) {
        // 添加审批意见（可选）
        if (variables.containsKey("comment")) {
            taskService.addComment(taskId, null, (String) variables.get("comment"));
        }
        taskService.complete(taskId, variables);
        log.info("任务已完成, taskId={}", taskId);
    }

    /**
     * 查询流程实例当前状态
     */
    public ProcessInstance getProcessInstance(String processInstanceId) {
        return runtimeService.createProcessInstanceQuery()
            .processInstanceId(processInstanceId)
            .singleResult();
    }

    /**
     * 查询流程历史（已结束的流程）
     */
    public HistoricProcessInstance getHistoricProcess(String processInstanceId) {
        return historyService.createHistoricProcessInstanceQuery()
            .processInstanceId(processInstanceId)
            .singleResult();
    }
}
```

---

## 流程变量设计规范

> ⚠️ **待填写**：填写你们的流程变量命名约定和类型规范

```java
// 流程变量命名约定示例（待填写你们的实际规范）
Map<String, Object> variables = new HashMap<>();

// 申请人信息
variables.put("applyUserId", "user123");       // 申请人 ID
variables.put("applyUserName", "张三");          // 申请人姓名
variables.put("applyDeptId", "dept001");        // 申请部门

// 审批相关
variables.put("approved", true);               // 审批结果：true=通过，false=拒绝
variables.put("comment", "同意申请");            // 审批意见
variables.put("nextAssignee", "manager001");   // 下一节点审批人（动态分配时使用）
```

---

## 任务分配方式

### 方式一：固定分配（BPMN 中指定）
```xml
<userTask id="task1" name="部门经理审批" flowable:assignee="manager001"/>
```

### 方式二：流程变量动态分配
```xml
<userTask id="task1" name="审批" flowable:assignee="${nextAssignee}"/>
```
```java
// 启动流程时传入审批人
variables.put("nextAssignee", "manager001");
runtimeService.startProcessInstanceByKey("leave", businessKey, variables);
```

### 方式三：候选组（部门/角色审批）
```xml
<userTask id="task1" name="审批" flowable:candidateGroups="dept_manager,hr_admin"/>
```
```java
// 查询候选组任务
taskService.createTaskQuery().taskCandidateGroup("dept_manager").list();
// 认领后再完成
taskService.claim(taskId, userId);
taskService.complete(taskId, variables);
```

### 方式四：监听器动态分配
```java
// TaskListener 实现动态分配审批人
@Component
public class AssigneeListener implements TaskListener {
    @Override
    public void notify(DelegateTask delegateTask) {
        // 根据业务逻辑动态设置审批人
        String businessKey = delegateTask.getProcessInstanceBusinessKey();
        String manager = queryManagerByBusinessKey(businessKey);
        delegateTask.setAssignee(manager);
    }
}
```

---

## 审批流典型 BPMN 示例

```xml
<?xml version="1.0" encoding="UTF-8"?>
<definitions xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL"
             xmlns:flowable="http://flowable.org/bpmn"
             targetNamespace="http://www.flowable.org/processdef">

  <process id="leave_apply" name="请假申请" isExecutable="true">

    <!-- 开始事件 -->
    <startEvent id="start" name="发起申请"/>

    <!-- 部门经理审批 -->
    <userTask id="dept_manager_review" name="部门经理审批"
              flowable:assignee="${deptManagerId}">
      <documentation>请假申请需要部门经理审批</documentation>
    </userTask>

    <!-- 审批结论网关 -->
    <exclusiveGateway id="gateway1" name="审批结论"/>

    <!-- 审批通过：通知申请人 -->
    <serviceTask id="notify_approved" name="通知审批通过"
                 flowable:class="com.yourcompany.listener.NotifyApprovedListener"/>

    <!-- 审批拒绝：通知申请人 -->
    <serviceTask id="notify_rejected" name="通知审批拒绝"
                 flowable:class="com.yourcompany.listener.NotifyRejectedListener"/>

    <!-- 结束事件 -->
    <endEvent id="end" name="结束"/>

    <!-- 连线 -->
    <sequenceFlow id="flow1" sourceRef="start" targetRef="dept_manager_review"/>
    <sequenceFlow id="flow2" sourceRef="dept_manager_review" targetRef="gateway1"/>
    <sequenceFlow id="flow3" sourceRef="gateway1" targetRef="notify_approved">
      <conditionExpression>${approved == true}</conditionExpression>
    </sequenceFlow>
    <sequenceFlow id="flow4" sourceRef="gateway1" targetRef="notify_rejected">
      <conditionExpression>${approved == false}</conditionExpression>
    </sequenceFlow>
    <sequenceFlow id="flow5" sourceRef="notify_approved" targetRef="end"/>
    <sequenceFlow id="flow6" sourceRef="notify_rejected" targetRef="end"/>

  </process>
</definitions>
```

---

## 常见 Flowable 坑

> ⚠️ **待填写**：填写你们遇到的实际问题

### 坑 1：（待填写）
**现象**：  
**原因**：  
**解决**：

### 坑 2：（待填写）
**现象**：  
**原因**：  
**解决**：

---

## TODO 待补充内容

- [ ] 你们实际使用的流程定义列表（流程 Key / 名称 / 用途）
- [ ] 流程监听器（ExecutionListener / TaskListener）的使用规范
- [ ] 与业务系统的集成方式（如何关联业务单据）
- [ ] 流程图可视化方案
- [ ] 流程撤回/驳回/转办的实现方式
- [ ] 历史数据查询常用场景
- [ ] 实际踩坑记录
