# UI设计交付 - AI债务助手

## 设计信息
- **设计师**: 艾拉
- **日期**: 2026-02-09
- **交付对象**: 贾维斯（开发）

---

## 一、按钮图标规范

### 1. 返回按钮（导航栏左侧）

**位置**: 导航栏左侧
**触发区域**: 44x44px
**图标尺寸**: 24x24px

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M19 12H5M12 19l-7-7 7-7" stroke="#333333" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

**样式**:
- 图标颜色: `#333333`
- 无背景

---

### 2. 设置按钮（导航栏右侧）

**位置**: 导航栏右侧
**触发区域**: 44x44px
**图标尺寸**: 24x24px

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="3" stroke="#333333" stroke-width="2"/>
  <path d="M12 1v3M12 20v3M4.22 4.22l2.12 2.12M17.66 17.66l2.12 2.12M1 12h3M20 12h3M4.22 19.78l2.12-2.12M17.66 6.34l2.12-2.12" stroke="#333333" stroke-width="2" stroke-linecap="round"/>
</svg>
```

**样式**:
- 图标颜色: `#333333`
- 无背景

---

### 3. 麦克风按钮（底部输入栏左侧）

**位置**: 底部输入栏左侧
**按钮尺寸**: 48x48px（圆形）
**图标尺寸**: 24x24px

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M19 10v2a7 7 0 0 1-14 0v-2" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M12 19v4M8 23h8" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

**常态样式**:
```css
.mic-btn {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: #F3F4F6;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 150ms ease;
}
.mic-btn svg {
  color: #667eea;
}
.mic-btn:hover {
  background: #E5E7EB;
}
.mic-btn:active {
  transform: scale(0.95);
}
```

**录音中状态**:
```css
.mic-btn.recording {
  background: #EF4444;
  animation: pulse 1.5s ease-in-out infinite;
}
.mic-btn.recording svg {
  color: #FFFFFF;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); box-shadow: 0 0 0 0 rgba(239, 68, 68, 0.4); }
  50% { transform: scale(1.05); box-shadow: 0 0 0 12px rgba(239, 68, 68, 0); }
}
```

---

### 4. 发送按钮（底部输入栏右侧）

**位置**: 底部输入栏右侧
**按钮尺寸**: 48x48px（圆形）
**图标尺寸**: 24x24px
**选定图标**: 箭头向上

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 19V5M5 12l7-7 7 7" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

**常态样式**:
```css
.send-btn {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: #F3F4F6;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 150ms ease;
}
.send-btn svg {
  color: #667eea;
}
.send-btn:hover {
  background: #E5E7EB;
}
.send-btn:active {
  transform: scale(0.95);
}
```

**禁用状态**（输入框为空时）:
```css
.send-btn:disabled {
  background: #F3F4F6;
  cursor: not-allowed;
}
.send-btn:disabled svg {
  color: #CBD5E1;
}
```

---

### 5. 语音播放按钮（AI消息气泡内）

**位置**: AI消息气泡右下角
**按钮尺寸**: 32x32px（圆形）
**图标尺寸**: 16x16px

```svg
<!-- 播放状态 -->
<svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <polygon points="8 5 8 19 20 12" fill="currentColor"/>
</svg>

<!-- 暂停状态（播放中显示） -->
<svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="6" y="4" width="4" height="16" rx="1" fill="currentColor"/>
  <rect x="14" y="4" width="4" height="16" rx="1" fill="currentColor"/>
</svg>
```

**样式**:
```css
.audio-btn {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: rgba(102, 126, 234, 0.1);
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 150ms ease;
}
.audio-btn svg {
  color: #667eea;
}
.audio-btn:hover {
  background: rgba(102, 126, 234, 0.2);
}
```

---

## 二、颜色规范

| 变量名 | 色值 | 用途 |
|--------|------|------|
| `--color-primary` | `#667eea` | 主题色、图标、用户消息起始色 |
| `--color-primary-end` | `#764ba2` | 渐变终止色 |
| `--color-text-dark` | `#333333` | 导航栏图标、深色文字 |
| `--color-text-body` | `#1E293B` | 正文文字 |
| `--color-text-secondary` | `#64748B` | 次要文字 |
| `--color-text-placeholder` | `#94A3B8` | 占位符文字 |
| `--color-bg-button` | `#F3F4F6` | 按钮背景 |
| `--color-bg-button-hover` | `#E5E7EB` | 按钮hover背景 |
| `--color-disabled` | `#CBD5E1` | 禁用状态 |
| `--color-recording` | `#EF4444` | 录音状态红色 |
| `--color-white` | `#FFFFFF` | 白色 |

---

## 三、按钮状态汇总

| 按钮 | 常态背景 | 常态图标 | Hover背景 | 特殊状态 |
|------|----------|----------|-----------|----------|
| 返回 | 透明 | #333333 | - | - |
| 设置 | 透明 | #333333 | - | - |
| 麦克风 | #F3F4F6 | #667eea | #E5E7EB | 录音中: 背景#EF4444, 图标白色 |
| 发送 | #F3F4F6 | #667eea | #E5E7EB | 禁用: 图标#CBD5E1 |
| 语音播放 | rgba(102,126,234,0.1) | #667eea | rgba(102,126,234,0.2) | 播放中: 显示暂停图标 |

---

## 四、录音状态UI

当用户点击麦克风按钮进入录音状态时：

### 视觉变化
1. 麦克风按钮变红 + 脉冲动画
2. 可选：显示录音时长计时器
3. 可选：显示声波动画

### 录音时长显示（可选）
```html
<div class="recording-indicator">
  <span class="recording-dot"></span>
  <span class="recording-time">0:03</span>
</div>
```

```css
.recording-indicator {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background: rgba(239, 68, 68, 0.1);
  border-radius: 20px;
}
.recording-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #EF4444;
  animation: blink 1s ease-in-out infinite;
}
.recording-time {
  font-size: 14px;
  font-weight: 500;
  color: #EF4444;
}
@keyframes blink {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}
```

---

## 五、交互说明

### 发送消息
1. 输入框为空时，发送按钮禁用（图标变灰）
2. 输入内容后，发送按钮可用（图标变紫）
3. 点击发送或按回车键发送消息

### 语音输入
1. 点击麦克风 → 请求麦克风权限（首次）
2. 开始录音 → 按钮变红 + 脉冲动画
3. 再次点击 → 停止录音 → 语音识别 → 自动发送
4. 或长按录音，松开发送（可选方案）

### 语音播放
1. AI消息生成后，后台异步生成语音
2. 语音就绪后显示播放按钮
3. 点击播放 → 图标变为暂停 → 播放语音
4. 播放完成或点击暂停 → 恢复播放图标

---

## 六、图标资源

所有图标来自 **Heroicons** / **Lucide**，可通过以下方式引入：

### 方式1: NPM包
```bash
npm install @heroicons/vue
# 或
npm install lucide-vue-next
```

### 方式2: 直接使用SVG
将上述SVG代码封装为Vue组件或直接inline使用。

### 方式3: Iconify
```bash
npm install @iconify/vue
```
```vue
<Icon icon="heroicons:arrow-up" />
```

---

## 七、文件清单

```
shared/designs/
├── ui-handoff-jarvis.md      # 本文档
└── button-icons-preview.svg  # 图标预览图
```

---

**如有疑问请联系艾拉确认。**
