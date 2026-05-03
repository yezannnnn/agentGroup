"""
SSE管理器 - 管理Server-Sent Events连接
"""
import asyncio
from typing import Dict, Set
from fastapi.responses import StreamingResponse
import json


class SSEManager:
    """SSE连接管理器"""
    
    def __init__(self):
        # tenant_id -> 连接队列集合
        self.connections: Dict[int, Set[asyncio.Queue]] = {}
    
    async def connect(self, tenant_id: int):
        """建立SSE连接"""
        queue = asyncio.Queue()
        
        if tenant_id not in self.connections:
            self.connections[tenant_id] = set()
        self.connections[tenant_id].add(queue)
        
        async def event_generator():
            try:
                while True:
                    data = await queue.get()
                    if data is None:  # 断开信号
                        break
                    yield f"data: {json.dumps(data)}\n\n"
            except asyncio.CancelledError:
                pass
            finally:
                self.connections[tenant_id].discard(queue)
        
        return StreamingResponse(
            event_generator(),
            media_type="text/event-stream",
            headers={
                "Cache-Control": "no-cache",
                "Connection": "keep-alive",
                "X-Accel-Buffering": "no",
            }
        )
    
    async def push_message(self, tenant_id: int, data: dict):
        """推送消息给指定租户的所有连接"""
        if tenant_id not in self.connections:
            return
        
        # 推送消息给该租户的所有连接
        for queue in list(self.connections[tenant_id]):
            try:
                await queue.put(data)
            except Exception as e:
                print(f"[SSE] Push error: {e}")
                self.connections[tenant_id].discard(queue)
    
    def disconnect(self, tenant_id: int, queue: asyncio.Queue):
        """断开连接"""
        if tenant_id in self.connections:
            self.connections[tenant_id].discard(queue)


# 全局SSE管理器实例
sse_manager = SSEManager()
