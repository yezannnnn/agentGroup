# 📋 功能开发通知 - 贾维斯 (Jarvis)

**来自**: Max (PM)  
**日期**: 2026-03-05  
**优先级**: P1  
**类型**: 功能优化

---

## 🎯 任务概述

为AI消息模块的好友列表添加**下拉刷新**功能。

参考：饿了么商家版/微信的聊天列表下拉刷新交互

---

## 📱 交互设计

### 手势触发
```
用户下拉好友列表
    ↓
下拉距离 > 50px
    ↓
显示"释放刷新"或"下拉同步"
    ↓
释放手指
    ↓
触发同步功能（调用 handleSyncFriends）
    ↓
显示刷新中状态（旋转loading）
    ↓
同步完成 → 刷新好友列表
```

### 状态展示
| 状态 | 显示内容 |
|------|----------|
| 下拉中 | "↓ 下拉同步微信好友" |
| 可释放 | "↑ 释放立即同步" |
| 刷新中 | "🔄 正在同步..." + loading动画 |
| 完成 | "✓ 同步完成"（1秒后消失） |

---

## 📦 开发内容

### 1. 下拉手势检测
- **touchstart**: 记录起始位置
- **touchmove**: 计算下拉距离，实时更新提示文字
- **touchend**: 判断下拉距离是否超过阈值（50px）

### 2. 触发同步
- 下拉释放后调用 `handleSyncFriends()`
- 复用现有的同步逻辑
- 同步完成后刷新列表

### 3. UI状态
- 下拉时顶部显示提示区域（高度根据下拉距离变化）
- 刷新中显示loading动画
- 完成后显示成功提示

---

## 📁 相关文件

- 文件: `vue-frontend/src/views/messages/index.vue`
- 已有函数: `handleSyncFriends()` - 直接复用
- 已有变量: `syncLoading`, `syncMessage`

---

## 💡 实现参考

### 下拉刷新区域结构
```html
<!-- 好友列表顶部 -->
<div class="friend-list-pull-refresh">
  <div v-if="pullState === 'pulling'">↓ 下拉同步微信好友</div>
  <div v-if="pullState === 'release'">↑ 释放立即同步</div>
  <div v-if="pullState === 'refreshing'">
    <el-icon class="is-loading"><Loading /></el-icon>
    正在同步...
  </div>
  <div v-if="pullState === 'done'">✓ 同步完成</div>
</div>

<!-- 好友列表 -->
<div class="friend-list" @touchstart @touchmove @touchend>
  ...
</div>
```

### 手势逻辑
```javascript
const pullState = ref('') // '' | 'pulling' | 'release' | 'refreshing' | 'done'
const startY = ref(0)
const pullDistance = ref(0)
const PULL_THRESHOLD = 50

function handleTouchStart(e) {
  startY.value = e.touches[0].clientY
}

function handleTouchMove(e) {
  const currentY = e.touches[0].clientY
  const diff = currentY - startY.value
  
  // 只在列表顶部下拉时触发
  if (friendListRef.value.scrollTop === 0 && diff > 0) {
    pullDistance.value = Math.min(diff, 100) // 最大100px
    
    if (pullDistance.value > PULL_THRESHOLD) {
      pullState.value = 'release'
    } else {
      pullState.value = 'pulling'
    }
  }
}

function handleTouchEnd() {
  if (pullState.value === 'release') {
    pullState.value = 'refreshing'
    handleSyncFriends() // 调用现有同步函数
  }
  
  // 重置
  pullDistance.value = 0
  setTimeout(() => {
    if (pullState.value !== 'refreshing') {
      pullState.value = ''
    }
  }, 300)
}
```

---

## ✅ 验收标准

- [ ] 好友列表顶部可以下拉
- [ ] 下拉超过50px显示"释放立即同步"
- [ ] 释放后触发同步功能
- [ ] 同步中显示loading动画
- [ ] 同步完成后刷新列表
- [ ] 不影响现有的滚动加载更多功能
- [ ] 在桌面端也能正常使用（鼠标拖拽或隐藏）

---

## ⚠️ 注意事项

1. **只在列表顶部触发**：滚动到中间/底部下拉不应触发刷新
2. **阈值控制**：下拉50px才触发，避免误触
3. **复用逻辑**：调用现有的 `handleSyncFriends()` 函数
4. **不要修坏**：保持分页加载、搜索、AI开关等功能正常

---

**完成后通知Max验收！**
