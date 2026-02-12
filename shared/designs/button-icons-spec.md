# 按钮图标规范 - AI债务助手

## 设计信息
- **设计师**: 艾拉
- **日期**: 2026-02-09
- **图标库**: Heroicons / Lucide（线性风格，stroke-width: 2）

---

## 图标规范

### 1. 返回按钮（导航左侧）

**推荐图标**: `arrow-left` 或 `chevron-left`

**Heroicons SVG**:
```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M19 12H5M12 19l-7-7 7-7"/>
</svg>
```

**颜色**: #333333（深灰）
**尺寸**: 24x24px

---

### 2. 设置按钮（导航右侧）

**推荐图标**: `settings` / `cog`

**Heroicons SVG**:
```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="12" r="3"/>
  <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/>
</svg>
```

**简化版本（推荐）**:
```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <circle cx="12" cy="12" r="3"/>
  <path d="M12 1v4M12 19v4M4.22 4.22l2.83 2.83M16.95 16.95l2.83 2.83M1 12h4M19 12h4M4.22 19.78l2.83-2.83M16.95 7.05l2.83-2.83"/>
</svg>
```

**颜色**: #333333
**尺寸**: 24x24px

---

### 3. 麦克风按钮（底部左侧）

**推荐图标**: `mic`

**Heroicons SVG**:
```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z"/>
  <path d="M19 10v2a7 7 0 0 1-14 0v-2"/>
  <line x1="12" y1="19" x2="12" y2="23"/>
  <line x1="8" y1="23" x2="16" y2="23"/>
</svg>
```

**颜色**: #667eea（主题紫）或 #64748B（灰色）
**尺寸**: 24x24px
**按钮背景**: 圆形，#F3F4F6

**录音中状态**:
- 图标颜色: #FFFFFF
- 背景颜色: #EF4444（红色）
- 添加脉冲动画

---

### 4. 发送按钮（底部右侧）

**按钮样式**: 渐变背景 + 白色图标

**背景渐变**:
```css
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```

**图标方案（4选1）**:

**方案A: 箭头向上（类似iMessage，推荐）**
```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none">
  <path d="M12 19V5M5 12l7-7 7 7" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

**方案B: 纸飞机**
```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none">
  <path d="M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

**方案C: 箭头向右**
```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none">
  <path d="M5 12h14M12 5l7 7-7 7" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

**方案D: 实心箭头**
```svg
<svg width="24" height="24" viewBox="0 0 24 24">
  <path d="M3 12l6-6v4h9v4h-9v4l-6-6z" fill="white"/>
</svg>
```

**颜色**: 白色 #FFFFFF
**尺寸**: 24x24px
**按钮背景**: 圆形，渐变紫（#667eea → #764ba2）

---

### 5. 语音播放按钮（AI消息内）

**推荐图标**: `volume-2` 或 `play`

**Lucide volume-2 SVG**:
```svg
<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/>
  <path d="M15.54 8.46a5 5 0 0 1 0 7.07"/>
  <path d="M19.07 4.93a10 10 0 0 1 0 14.14"/>
</svg>
```

**简化 play 图标**:
```svg
<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
  <path d="M8 5v14l11-7z"/>
</svg>
```

**颜色**: #667eea（主题紫）
**尺寸**: 20x20px
**按钮背景**: 圆形，rgba(102,126,234,0.1)

**播放中状态**:
- 显示暂停图标或音波动画

---

## 图标统一规范

| 属性 | 值 |
|------|-----|
| 线宽 | 2px |
| 端点 | round (stroke-linecap) |
| 连接 | round (stroke-linejoin) |
| 尺寸 | 24x24px（导航栏）/ 20x20px（消息内） |
| 风格 | 线性 outline |

---

## 颜色对照

| 状态 | 图标颜色 | 背景颜色 |
|------|----------|----------|
| 常态 | #64748B | #F3F4F6 |
| 主题 | #667eea | rgba(102,126,234,0.1) |
| 录音中 | #FFFFFF | #EF4444 |
| 导航栏 | #333333 | 透明 |

---

## 给贾维斯的开发建议

1. **图标库选择**: 推荐使用 [Heroicons](https://heroicons.com/) 或 [Lucide](https://lucide.dev/)
2. **引入方式**:
   - Vue: `npm install @heroicons/vue`
   - 或直接使用 SVG inline
3. **hover 状态**: 添加 `opacity: 0.8` 或 `transform: scale(1.05)`
4. **过渡动画**: `transition: all 150ms ease`
