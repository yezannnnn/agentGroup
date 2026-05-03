#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
AI Agent Skill示例 - Windows代理管理
作者: Max (项目经理)
功能: 演示如何在skill中调用Windows代理管理器
"""

import sys
import os

# 添加scripts目录到路径
sys.path.append(os.path.dirname(__file__))

from windows_proxy_manager import AgentProxyInterface


def proxy_management_skill(action: str, target_config: dict) -> dict:
    """
    代理管理技能函数

    Args:
        action: 'setup' 或 'cleanup'
        target_config: {
            'host': '192.168.31.22',
            'user': 'administrator',
            'password': '123123',
            'tunnel_port': 1090,  # 可选
            'ssh_port': 22        # 可选
        }

    Returns:
        dict: 操作结果
    """

    # 提取配置
    host = target_config['host']
    user = target_config['user']
    password = target_config['password']
    tunnel_port = target_config.get('tunnel_port', 1090)
    ssh_port = target_config.get('ssh_port', 22)

    try:
        if action == 'setup':
            result = AgentProxyInterface.setup_windows_proxy(
                host, user, password, tunnel_port, ssh_port
            )
        elif action == 'cleanup':
            result = AgentProxyInterface.cleanup_windows_proxy(
                host, user, password, tunnel_port, ssh_port
            )
        else:
            return {
                'success': False,
                'message': f'不支持的操作: {action}',
                'details': []
            }

        return result

    except Exception as e:
        return {
            'success': False,
            'message': f'代理管理失败: {str(e)}',
            'details': [str(e)]
        }


# 使用示例
if __name__ == "__main__":
    # 示例1: 开启代理
    print("🚀 示例1: 开启Windows设备代理")
    print("=" * 50)

    config = {
        'host': '192.168.31.22',
        'user': 'administrator',
        'password': '123123'
    }

    setup_result = proxy_management_skill('setup', config)

    if setup_result['success']:
        print("✅ 代理开启成功!")
        print(f"📝 详情: {setup_result['message']}")
    else:
        print("❌ 代理开启失败!")
        print(f"📝 错误: {setup_result['message']}")

    print("\n" + "=" * 50)

    # 询问用户是否要关闭代理
    user_input = input("是否要关闭代理? (y/N): ").strip().lower()

    if user_input == 'y':
        print("\n🧹 示例2: 关闭Windows设备代理")
        print("=" * 50)

        cleanup_result = proxy_management_skill('cleanup', config)

        if cleanup_result['success']:
            print("✅ 代理关闭成功!")
            print(f"📝 详情: {cleanup_result['message']}")
        else:
            print("❌ 代理关闭失败!")
            print(f"📝 错误: {cleanup_result['message']}")
    else:
        print("🔄 代理保持开启状态")


# Agent调用示例函数
def demo_agent_calls():
    """演示Agent如何调用代理管理"""

    print("\n🤖 Agent调用演示")
    print("=" * 30)

    # 配置多台设备
    devices = [
        {
            'name': 'Windows设备1',
            'host': '192.168.31.22',
            'user': 'administrator',
            'password': '123123',
            'tunnel_port': 1090
        },
        {
            'name': 'Windows设备2',
            'host': '192.168.31.23',
            'user': 'admin',
            'password': 'pass456',
            'tunnel_port': 1091
        }
    ]

    # 为所有设备开启代理
    print("🔧 为所有设备开启代理...")
    for device in devices:
        print(f"   配置 {device['name']} ({device['host']})...")

        result = AgentProxyInterface.setup_windows_proxy(
            device['host'],
            device['user'],
            device['password'],
            device['tunnel_port']
        )

        status = "✅" if result['success'] else "❌"
        print(f"   {status} {device['name']}: {result['message']}")

    print("\n🧹 清理所有设备代理...")
    for device in devices:
        print(f"   清理 {device['name']} ({device['host']})...")

        result = AgentProxyInterface.cleanup_windows_proxy(
            device['host'],
            device['user'],
            device['password'],
            device['tunnel_port']
        )

        status = "✅" if result['success'] else "❌"
        print(f"   {status} {device['name']}: {result['message']}")


if __name__ == "__main__" and len(sys.argv) > 1 and sys.argv[1] == '--demo':
    demo_agent_calls()