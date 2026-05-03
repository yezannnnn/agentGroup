#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Windows代理管理器 - Python版本
作者: Max (项目经理)
版本: 3.0
功能: 为Windows远程设备配置和管理完整代理环境
适用: AI Agent Skill系统

支持功能:
✅ SSH反向隧道管理
✅ Git代理配置 (开启/关闭)
✅ NPM代理配置 (开启/关闭)
✅ 终端全局代理 (开启/关闭)
✅ 编程调用和命令行调用
"""

import subprocess
import sys
import argparse
import time
import json
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass
from enum import Enum


class ProxyAction(Enum):
    """代理操作枚举"""
    SETUP = "setup"
    CLEANUP = "cleanup"
    STATUS = "status"
    TEST = "test"


@dataclass
class ProxyConfig:
    """代理配置类"""
    target_host: str = "192.168.0.142"
    target_user: str = "administrator"
    target_pass: str = "123123"
    tunnel_port: int = 1090
    ssh_port: int = 22
    local_proxy_port: int = 1086  # 本地Shadowsocks端口


class WindowsProxyManager:
    """Windows代理管理器主类"""

    def __init__(self, config: ProxyConfig):
        self.config = config
        self.results = {
            "success": False,
            "message": "",
            "details": [],
            "proxy_status": {}
        }

    def setup_proxy(self) -> Dict:
        """
        建立完整代理环境
        包括: SSH隧道 + Git代理 + NPM代理 + 终端代理
        """
        print("🔧 建立SSH反向隧道和完整代理配置...")
        print("=" * 50)
        print(f"🎯 目标: {self.config.target_user}@{self.config.target_host}:{self.config.ssh_port}")
        print(f"🔌 隧道端口: {self.config.tunnel_port}")
        print("=" * 50)

        try:
            # 1. 建立SSH反向隧道
            self._setup_ssh_tunnel()

            # 2. 配置Git代理
            self._setup_git_proxy()

            # 3. 配置NPM代理
            self._setup_npm_proxy()

            # 4. 配置终端全局代理
            self._setup_terminal_proxy()

            # 5. 测试所有代理
            self._test_all_proxies()

            self.results["success"] = True
            self.results["message"] = "所有代理配置成功"

        except Exception as e:
            self.results["success"] = False
            self.results["message"] = f"代理配置失败: {str(e)}"
            self.results["details"].append(f"错误: {str(e)}")

        return self.results

    def cleanup_proxy(self) -> Dict:
        """
        清理完整代理环境
        包括: Git代理 + NPM代理 + 终端代理 + SSH隧道
        """
        print("🧹 清理所有代理配置...")
        print("=" * 50)

        try:
            # 1. 清理Git代理
            self._cleanup_git_proxy()

            # 2. 清理NPM代理
            self._cleanup_npm_proxy()

            # 3. 清理终端代理
            self._cleanup_terminal_proxy()

            # 4. 关闭SSH隧道
            self._cleanup_ssh_tunnel()

            self.results["success"] = True
            self.results["message"] = "所有代理配置已清理完成"

        except Exception as e:
            self.results["success"] = False
            self.results["message"] = f"代理清理失败: {str(e)}"
            self.results["details"].append(f"错误: {str(e)}")

        return self.results

    def check_status(self) -> Dict:
        """检查代理状态"""
        print("📊 检查代理状态...")
        print("=" * 50)

        try:
            # 检查SSH隧道
            ssh_status = self._check_ssh_tunnel()

            # 检查远程代理配置
            proxy_configs = self._check_remote_proxy_configs()

            self.results["success"] = True
            self.results["proxy_status"] = {
                "ssh_tunnel": ssh_status,
                "remote_configs": proxy_configs
            }

        except Exception as e:
            self.results["success"] = False
            self.results["message"] = f"状态检查失败: {str(e)}"

        return self.results

    def _setup_ssh_tunnel(self):
        """建立SSH反向隧道"""
        print("1️⃣ 建立SSH反向隧道...")

        tunnel_cmd = [
            "sshpass", "-p", self.config.target_pass,
            "ssh", "-p", str(self.config.ssh_port),
            "-R", f"{self.config.tunnel_port}:127.0.0.1:{self.config.local_proxy_port}",
            "-N", "-f",
            f"{self.config.target_user}@{self.config.target_host}"
        ]

        result = subprocess.run(tunnel_cmd, capture_output=True, text=True)

        if result.returncode == 0:
            print(f"✅ SSH反向隧道已建立 (本地{self.config.local_proxy_port} → 远程{self.config.tunnel_port})")
            print(f"   SSH连接: {self.config.target_host}:{self.config.ssh_port}")
            self.results["details"].append("SSH隧道建立成功")
            time.sleep(2)  # 等待隧道稳定
        else:
            error_msg = f"SSH隧道建立失败: {result.stderr}"
            self.results["details"].append(error_msg)
            raise Exception(error_msg)

    def _setup_git_proxy(self):
        """配置Git代理"""
        print("2️⃣ 配置Git代理...")

        git_commands = [
            f"git config --global http.proxy socks5://127.0.0.1:{self.config.tunnel_port}",
            f"git config --global https.proxy socks5://127.0.0.1:{self.config.tunnel_port}",
            f"echo Git代理已配置为: socks5://127.0.0.1:{self.config.tunnel_port}"
        ]

        self._execute_remote_commands(git_commands, "Git代理配置")
        print("✅ Git代理配置完成")

    def _setup_npm_proxy(self):
        """配置NPM代理"""
        print("3️⃣ 配置NPM代理...")

        npm_commands = [
            f"npm config set proxy socks5://127.0.0.1:{self.config.tunnel_port}",
            f"npm config set https-proxy socks5://127.0.0.1:{self.config.tunnel_port}",
            f"echo NPM代理已配置为: socks5://127.0.0.1:{self.config.tunnel_port}"
        ]

        self._execute_remote_commands(npm_commands, "NPM代理配置")
        print("✅ NPM代理配置完成")

    def _setup_terminal_proxy(self):
        """配置终端全局代理"""
        print("4️⃣ 配置终端全局代理...")

        terminal_commands = [
            "echo @echo off > set_proxy.bat",
            f"echo set HTTP_PROXY=socks5://127.0.0.1:{self.config.tunnel_port} >> set_proxy.bat",
            f"echo set HTTPS_PROXY=socks5://127.0.0.1:{self.config.tunnel_port} >> set_proxy.bat",
            f"echo set ALL_PROXY=socks5://127.0.0.1:{self.config.tunnel_port} >> set_proxy.bat",
            "echo echo 终端代理已配置！ >> set_proxy.bat",
            "echo 永久代理脚本已创建: set_proxy.bat",
            "echo 使用方法: 运行 set_proxy.bat 激活终端代理"
        ]

        self._execute_remote_commands(terminal_commands, "终端代理配置")
        print("✅ 终端代理配置完成")

    def _cleanup_git_proxy(self):
        """清理Git代理"""
        print("1️⃣ 清理Git代理配置...")

        git_cleanup_commands = [
            "git config --global --unset http.proxy 2>nul",
            "git config --global --unset https.proxy 2>nul",
            "echo Git代理配置已清除"
        ]

        self._execute_remote_commands(git_cleanup_commands, "Git代理清理")

    def _cleanup_npm_proxy(self):
        """清理NPM代理"""
        print("2️⃣ 清理NPM代理配置...")

        npm_cleanup_commands = [
            "npm config delete proxy 2>nul",
            "npm config delete https-proxy 2>nul",
            "echo NPM代理配置已清除"
        ]

        self._execute_remote_commands(npm_cleanup_commands, "NPM代理清理")

    def _cleanup_terminal_proxy(self):
        """清理终端代理"""
        print("3️⃣ 清理终端代理脚本...")

        terminal_cleanup_commands = [
            "if exist set_proxy.bat (",
            "    del set_proxy.bat",
            "    echo 终端代理脚本已删除",
            ") else (",
            "    echo 终端代理脚本不存在，跳过",
            ")"
        ]

        self._execute_remote_commands(terminal_cleanup_commands, "终端代理清理")

    def _cleanup_ssh_tunnel(self):
        """关闭SSH隧道"""
        print("4️⃣ 关闭SSH隧道...")

        # 查找并终止SSH隧道进程
        kill_cmd = [
            "pkill", "-f",
            f"ssh.*-p {self.config.ssh_port}.*-R.*{self.config.tunnel_port}.*{self.config.target_host}"
        ]

        subprocess.run(kill_cmd, capture_output=True)
        print("✅ SSH隧道已关闭")

    def _test_all_proxies(self):
        """测试所有代理"""
        print("5️⃣ 测试所有代理连接...")

        test_commands = [
            "echo 1. Git代理配置检查:",
            "git config --get http.proxy",
            "git config --get https.proxy",
            "echo.",
            "echo 2. NPM代理配置检查:",
            "npm config get proxy",
            "npm config get https-proxy",
            "echo.",
            "echo 3. 测试Git代理访问GitHub:",
            "git ls-remote https://github.com/microsoft/vscode.git HEAD",
            "echo.",
            "echo 4. 测试NPM代理访问registry:",
            "npm ping",
            "echo.",
            "echo 5. 终端代理脚本状态:",
            "if exist set_proxy.bat (",
            "    echo ✅ set_proxy.bat 脚本存在",
            "    type set_proxy.bat",
            ") else (",
            "    echo ❌ set_proxy.bat 脚本不存在",
            ")"
        ]

        self._execute_remote_commands(test_commands, "代理测试")
        print("✅ 代理测试完成")

    def _execute_remote_commands(self, commands: List[str], operation: str):
        """执行远程命令"""
        cmd_string = " && ".join(commands)

        ssh_cmd = [
            "sshpass", "-p", self.config.target_pass,
            "ssh", "-p", str(self.config.ssh_port),
            f"{self.config.target_user}@{self.config.target_host}",
            cmd_string
        ]

        result = subprocess.run(ssh_cmd, capture_output=True, text=True)

        if result.returncode != 0:
            error_msg = f"{operation}失败: {result.stderr}"
            self.results["details"].append(error_msg)
            raise Exception(error_msg)

        self.results["details"].append(f"{operation}成功")

    def _check_ssh_tunnel(self) -> Dict:
        """检查SSH隧道状态"""
        check_cmd = [
            "ps", "aux"
        ]

        result = subprocess.run(check_cmd, capture_output=True, text=True)

        tunnel_pattern = f"ssh.*-p {self.config.ssh_port}.*-R.*{self.config.tunnel_port}.*{self.config.target_host}"

        for line in result.stdout.split('\n'):
            if self.config.target_host in line and str(self.config.tunnel_port) in line:
                return {
                    "status": "running",
                    "details": line.strip()
                }

        return {
            "status": "not_running",
            "details": "SSH隧道未运行"
        }

    def _check_remote_proxy_configs(self) -> Dict:
        """检查远程代理配置"""
        check_commands = [
            "echo Git配置:",
            "git config --get http.proxy",
            "git config --get https.proxy",
            "echo NPM配置:",
            "npm config get proxy",
            "npm config get https-proxy"
        ]

        try:
            self._execute_remote_commands(check_commands, "代理配置检查")
            return {"status": "configured"}
        except:
            return {"status": "not_configured"}


def main():
    """命令行入口点"""
    parser = argparse.ArgumentParser(description='Windows代理管理器 - Python版本')
    parser.add_argument('action', choices=['setup', 'cleanup', 'status', 'test'],
                       help='操作类型')
    parser.add_argument('--host', default='192.168.0.142',
                       help='目标主机IP')
    parser.add_argument('--user', default='administrator',
                       help='SSH用户名')
    parser.add_argument('--password', default='123123',
                       help='SSH密码')
    parser.add_argument('--tunnel-port', type=int, default=1090,
                       help='隧道端口')
    parser.add_argument('--ssh-port', type=int, default=22,
                       help='SSH端口')
    parser.add_argument('--output-format', choices=['text', 'json'], default='text',
                       help='输出格式')

    args = parser.parse_args()

    # 创建配置
    config = ProxyConfig(
        target_host=args.host,
        target_user=args.user,
        target_pass=args.password,
        tunnel_port=args.tunnel_port,
        ssh_port=args.ssh_port
    )

    # 创建管理器
    manager = WindowsProxyManager(config)

    # 执行操作
    if args.action == 'setup':
        result = manager.setup_proxy()
    elif args.action == 'cleanup':
        result = manager.cleanup_proxy()
    elif args.action == 'status':
        result = manager.check_status()
    else:
        result = manager._test_all_proxies()

    # 输出结果
    if args.output_format == 'json':
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        if result["success"]:
            print(f"✅ {result['message']}")
        else:
            print(f"❌ {result['message']}")
            sys.exit(1)


# Agent编程调用接口
class AgentProxyInterface:
    """AI Agent专用接口"""

    @staticmethod
    def setup_windows_proxy(host: str, user: str, password: str,
                           tunnel_port: int = 1090, ssh_port: int = 22) -> Dict:
        """
        为AI Agent提供的代理设置接口

        Args:
            host: Windows设备IP
            user: SSH用户名
            password: SSH密码
            tunnel_port: 隧道端口
            ssh_port: SSH端口

        Returns:
            Dict: 操作结果
        """
        config = ProxyConfig(host, user, password, tunnel_port, ssh_port)
        manager = WindowsProxyManager(config)
        return manager.setup_proxy()

    @staticmethod
    def cleanup_windows_proxy(host: str, user: str, password: str,
                             tunnel_port: int = 1090, ssh_port: int = 22) -> Dict:
        """
        为AI Agent提供的代理清理接口

        Args:
            host: Windows设备IP
            user: SSH用户名
            password: SSH密码
            tunnel_port: 隧道端口
            ssh_port: SSH端口

        Returns:
            Dict: 操作结果
        """
        config = ProxyConfig(host, user, password, tunnel_port, ssh_port)
        manager = WindowsProxyManager(config)
        return manager.cleanup_proxy()


if __name__ == "__main__":
    main()