# Python Windows代理管理器 - AI Agent Skill版本

作者: Max (项目经理)
版本: 3.0
更新: 2026-03-07

## 🎯 功能特性

为AI Agent Skill系统提供的Windows远程设备代理管理解决方案。

### ✨ 核心功能
- ✅ **开启代理** - 一键配置Git + NPM + 终端全局代理
- ✅ **关闭代理** - 一键清理所有代理配置
- ✅ **编程调用** - 面向对象设计，便于Agent集成
- ✅ **命令行调用** - 支持shell调用
- ✅ **JSON输出** - 结构化返回结果
- ✅ **错误处理** - 完善的异常捕获和处理

### 🔧 技术架构
```
┌─ windows_proxy_manager.py    # 核心管理器
├─ proxy_skill_example.py      # Skill调用示例
└─ README_PYTHON_PROXY.md      # 本文档
```

## 🚀 快速使用

### 方法1: 命令行调用

```bash
# 开启代理
python3 ./skills/scripts/windows_proxy_manager.py setup --host 192.168.31.22 --user administrator --password 123123

# 关闭代理
python3 ./skills/scripts/windows_proxy_manager.py cleanup --host 192.168.31.22 --user administrator --password 123123

# 检查状态
python3 ./skills/scripts/windows_proxy_manager.py status --host 192.168.31.22 --user administrator --password 123123

# JSON格式输出
python3 ./skills/scripts/windows_proxy_manager.py setup --host 192.168.31.22 --user administrator --password 123123 --output-format json
```

### 方法2: Agent编程调用

```python
from skills.scripts.windows_proxy_manager import AgentProxyInterface

# 开启代理
result = AgentProxyInterface.setup_windows_proxy(
    host="192.168.31.22",
    user="administrator",
    password="123123",
    tunnel_port=1090,
    ssh_port=22
)

if result['success']:
    print("✅ 代理配置成功")
else:
    print(f"❌ 配置失败: {result['message']}")

# 关闭代理
result = AgentProxyInterface.cleanup_windows_proxy(
    host="192.168.31.22",
    user="administrator",
    password="123123"
)
```

### 方法3: Skill函数调用

```python
from skills.scripts.proxy_skill_example import proxy_management_skill

# 配置信息
config = {
    'host': '192.168.31.22',
    'user': 'administrator',
    'password': '123123',
    'tunnel_port': 1090,  # 可选
    'ssh_port': 22        # 可选
}

# 开启代理
result = proxy_management_skill('setup', config)

# 关闭代理
result = proxy_management_skill('cleanup', config)
```

## 📊 返回格式

所有方法返回统一的字典格式：

```python
{
    "success": True/False,           # 操作是否成功
    "message": "描述信息",            # 结果描述
    "details": ["详细步骤..."],       # 执行详情
    "proxy_status": {                # 代理状态(仅status命令)
        "ssh_tunnel": {...},
        "remote_configs": {...}
    }
}
```

## 🔧 参数说明

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| host | str | 192.168.0.142 | 目标Windows设备IP |
| user | str | administrator | SSH用户名 |
| password | str | 123123 | SSH密码 |
| tunnel_port | int | 1090 | 代理隧道端口 |
| ssh_port | int | 22 | SSH连接端口 |

## 💡 使用场景

### 场景1: Agent自动化部署
```python
# Agent可以批量为多台设备配置代理
devices = [
    {'host': '192.168.31.22', 'user': 'admin', 'password': 'pass1'},
    {'host': '192.168.31.23', 'user': 'admin', 'password': 'pass2'},
]

for device in devices:
    result = AgentProxyInterface.setup_windows_proxy(**device)
    print(f"设备 {device['host']}: {'✅成功' if result['success'] else '❌失败'}")
```

### 场景2: openClaw一键部署
```python
# 1. 配置代理
proxy_result = AgentProxyInterface.setup_windows_proxy("192.168.31.22", "admin", "pass")

# 2. 安装openClaw (通过SSH执行)
if proxy_result['success']:
    # 远程执行: npm install -g openclaw
    print("代理配置完成，可以安装openClaw了")
```

### 场景3: 临时代理任务
```python
# 开启代理 → 执行网络任务 → 关闭代理
config = {'host': '192.168.31.22', 'user': 'admin', 'password': 'pass'}

# 开启
setup_result = proxy_management_skill('setup', config)
if setup_result['success']:
    # 执行需要代理的任务...
    print("执行网络任务中...")

    # 关闭
    cleanup_result = proxy_management_skill('cleanup', config)
```

## 🧪 测试验证

### 运行示例
```bash
# 交互式示例
python3 ./skills/scripts/proxy_skill_example.py

# Agent批量演示
python3 ./skills/scripts/proxy_skill_example.py --demo
```

### 验证代理工作
```bash
# 在Windows设备上验证
ssh administrator@192.168.31.22

# Git代理
git config --get http.proxy
git ls-remote https://github.com/microsoft/vscode.git HEAD

# NPM代理
npm config get proxy
npm ping
npm install -g openclaw

# 终端代理
set_proxy.bat
echo %HTTP_PROXY%
```

## ⚠️ 前置要求

- ✅ 本地安装`sshpass`
- ✅ 本地Shadowsocks运行在127.0.0.1:1086
- ✅ 目标Windows设备安装Git、NPM、OpenSSH
- ✅ Python 3.7+
- ✅ 网络连通性正常

## 🔄 与Bash版本对比

| 特性 | Bash版本 | Python版本 |
|------|----------|------------|
| 功能完整性 | ✅ 完整 | ✅ 完整 |
| Agent调用 | ❌ 困难 | ✅ 简单 |
| 错误处理 | ⚠️ 基础 | ✅ 完善 |
| 返回格式 | ❌ 文本 | ✅ 结构化 |
| 批量操作 | ❌ 手动 | ✅ 编程化 |
| Skill集成 | ❌ 不支持 | ✅ 原生支持 |

## 📁 文件说明

- `windows_proxy_manager.py` - 核心代理管理器类
- `proxy_skill_example.py` - Skill调用示例和演示
- `README_PYTHON_PROXY.md` - 本说明文档

---

🚀 **推荐**: 在AI Agent Skill系统中使用Python版本，获得更好的集成体验！