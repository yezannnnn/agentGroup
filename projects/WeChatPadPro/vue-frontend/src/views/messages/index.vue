<template>
  <div class="messages-container">
    <div class="message-list" ref="messageList">
      <div 
        v-for="msg in messages" 
        :key="msg.id" 
        class="message-item"
        :class="{ 'from-me': msg.is_from_me }"
      >
        <div class="message-content">{{ msg.content }}</div>
        <div class="message-time">{{ formatTime(msg.created_at) }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const messages = ref([])
const messageList = ref(null)
let eventSource = null

// 用于追踪已接收的消息ID（防止前端重复）
const receivedMsgIds = new Set()

// 格式化时间
const formatTime = (timeStr) => {
  if (!timeStr) return ''
  const date = new Date(timeStr)
  return date.toLocaleTimeString()
}

// 生成消息唯一键
const getMessageKey = (msgData) => {
  return `${msgData.msg_id}:${msgData.is_from_me}`
}

// 处理新消息
function handleNewMessage(msgData) {
  const msgKey = getMessageKey(msgData)
  
  console.log('[DEBUG] 收到新消息:', {
    msg_id: msgData.msg_id,
    content: msgData.content,
    is_from_me: msgData.is_from_me,
    key: msgKey
  })
  
  // 检查是否已存在相同msg_id的消息（前端层面去重）
  if (receivedMsgIds.has(msgKey)) {
    console.log('[DEBUG] ⚠️ 消息已存在，跳过:', msgKey)
    return
  }
  
  // 记录已接收的消息ID
  receivedMsgIds.add(msgKey)
  
  // 限制Set大小，防止内存泄漏
  if (receivedMsgIds.size > 1000) {
    const iterator = receivedMsgIds.values()
    receivedMsgIds.delete(iterator.next().value)
  }
  
  messages.value.push(msgData)
  
  console.log('[DEBUG] ✅ 消息已添加到列表:', msgKey)
  
  // 滚动到底部
  setTimeout(() => {
    if (messageList.value) {
      messageList.value.scrollTop = messageList.value.scrollHeight
    }
  }, 100)
}

// 初始化SSE连接
const initSSE = () => {
  const tenantId = localStorage.getItem('tenant_id')
  if (!tenantId) {
    console.log('[DEBUG] 未找到tenant_id，跳过SSE连接')
    return
  }
  
  console.log('[DEBUG] 初始化SSE连接, tenant_id:', tenantId)
  
  eventSource = new EventSource(`/api/v1/sse/connect?tenant_id=${tenantId}`)
  
  eventSource.onopen = () => {
    console.log('[DEBUG] ✅ SSE连接已建立')
  }
  
  eventSource.onmessage = (event) => {
    try {
      const data = JSON.parse(event.data)
      console.log('[DEBUG] SSE收到数据:', data)
      
      if (data.type === 'new_message') {
        handleNewMessage(data.data)
      }
    } catch (e) {
      console.error('[DEBUG] 解析SSE数据失败:', e)
    }
  }
  
  eventSource.onerror = (error) => {
    console.error('[DEBUG] SSE连接错误:', error)
    // 5秒后重连
    setTimeout(() => {
      console.log('[DEBUG] 尝试重新连接SSE...')
      initSSE()
    }, 5000)
  }
}

onMounted(() => {
  initSSE()
})

onUnmounted(() => {
  if (eventSource) {
    console.log('[DEBUG] 关闭SSE连接')
    eventSource.close()
  }
})
</script>

<style scoped>
.messages-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
}

.message-list {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
}

.message-item {
  margin-bottom: 15px;
  max-width: 70%;
}

.message-item.from-me {
  margin-left: auto;
  text-align: right;
}

.message-content {
  background: #f0f0f0;
  padding: 10px 15px;
  border-radius: 10px;
  display: inline-block;
}

.message-item.from-me .message-content {
  background: #007bff;
  color: white;
}

.message-time {
  font-size: 12px;
  color: #999;
  margin-top: 5px;
}
</style>
