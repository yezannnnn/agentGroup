# .gitignore 快速操作指南

**立即执行**: 清理现有问题 | **5分钟完成**

---

## 🔴 立即行动：清理现有系统文件

### 步骤 1: 从 Git 中移除已追踪的系统文件

```bash
cd /Users/yuhao/Desktop/yezannnnn/aiGroup

# 移除被错误追踪的 .DS_Store 文件（保留本地文件）
git rm --cached shared/.DS_Store
git rm --cached shared/designs/.DS_Store
```

### 步骤 2: 验证规则生效

```bash
# 验证 .DS_Store 会被忽略
git check-ignore -v shared/.DS_Store
git check-ignore -v shared/designs/.DS_Store

# 应该输出类似：
# .gitignore:37:shared/**/.DS_Store
```

### 步骤 3: 提交更改

```bash
git add .gitignore

git commit -m "$(cat <<'EOF'
chore: optimize .gitignore and remove tracked system files

- Remove shared/.DS_Store and shared/designs/.DS_Store from version control
- Add comprehensive .gitignore rules (v2.0):
  * Enhanced system file filtering (macOS/Windows/Linux)
  * Editor and IDE configuration protection
  * Design file management (prevent .psd, .ai, .fig uploads)
  * Python and Node.js cache optimization
- Add gitignore-strategy.md for team reference

Co-Authored-By: Claude Sonnet 4 <noreply@anthropic.com>
EOF
)"
```

### 步骤 4: 验证结果

```bash
# 查看 Git 状态（应该干净）
git status

# 验证系统文件不再被追踪
git ls-files | grep ".DS_Store"
# 应该无输出
```

---

## 🧹 可选：清理本地所有 .DS_Store 文件

```bash
# 查找所有 .DS_Store 文件
find /Users/yuhao/Desktop/yezannnnn/aiGroup -name ".DS_Store" -type f

# 删除所有 .DS_Store 文件
find /Users/yuhao/Desktop/yezannnnn/aiGroup -name ".DS_Store" -type f -delete

# 验证已清理
find /Users/yuhao/Desktop/yezannnnn/aiGroup -name ".DS_Store" -type f
# 应该无输出
```

---

## ✅ 提交规范（日常使用）

### 应该提交的文件

```bash
# ✅ 文档和配置
git add *.md
git add *.json
git add *.yaml

# ✅ 设计规范和矢量图
git add shared/designs/*.md
git add shared/designs/*.svg

# ✅ 小型预览图（命名规范）
git add shared/designs/preview-*.png
git add shared/designs/icon-*.png
```

### 绝不提交的文件

```bash
# ❌ 这些会被 .gitignore 自动忽略
.DS_Store           # 系统文件
*.log               # 日志文件
.env                # 敏感配置
node_modules/       # 依赖目录
__pycache__/        # Python 缓存
*.psd               # 大型设计源文件
*.ai                # Adobe Illustrator 文件
*.fig               # Figma 文件
```

---

## 🎨 设计文件提交流程（Ella 专用）

### 场景 1: 提交图标设计

```bash
# 1. 导出 SVG 格式
# 2. 提交到 Git
git add shared/designs/icon-name.svg
git add shared/designs/icon-spec.md
git commit -m "design: add new icon for feature X"
```

### 场景 2: 提交 UI 设计规范

```bash
# 1. 编写设计规范 .md
# 2. 导出小型预览图（<200KB，命名为 preview-*.png）
git add shared/designs/ui-spec.md
git add shared/designs/preview-ui.png
git commit -m "design: add UI specification for dashboard"

# 3. 源文件保存在 Figma Cloud / Adobe CC
```

### 场景 3: 大型设计源文件

```markdown
**不要提交 .psd, .ai, .fig 文件！**

正确做法：
1. 保存源文件到云端（Figma / Adobe CC）
2. 在设计规范文档中添加链接：
   - Figma 链接: https://figma.com/file/...
   - 预览图: 见 preview-dashboard.png
3. 只提交文档和预览图
```

---

## 🔍 提交前检查清单

```bash
# 1. 查看将要提交的文件
git status

# 2. 检查文件大小（确保没有大文件）
git diff --cached --stat

# 3. 预览更改
git diff --cached

# 4. 确认无系统文件
git status | grep -E "\.(DS_Store|log|tmp)$"
# 应该无输出

# 5. 提交
git commit -m "your message"
```

---

## 🛠️ 常见问题快速修复

### 问题 1: "我不小心提交了 .DS_Store"

```bash
# 从 Git 中移除（保留本地）
git rm --cached .DS_Store
git commit -m "chore: remove .DS_Store"
```

### 问题 2: "规则不生效"

```bash
# 文件可能已被追踪，需要先移除
git rm --cached <file>

# 验证规则
git check-ignore -v <file>
```

### 问题 3: "我不确定是否应该提交某个文件"

```bash
# 检查文件是否会被忽略
git check-ignore -v <file>

# 如果输出规则，说明会被忽略 ✅
# 如果无输出，说明会被追踪 ⚠️（确认是否应该提交）
```

---

## 📚 完整文档

详细策略和说明见：
- **完整文档**: `shared/docs/gitignore-strategy.md`
- **.gitignore 文件**: `.gitignore`

---

**完成后**: 通知团队成员 .gitignore 规则已更新
