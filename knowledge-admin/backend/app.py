"""
九月影知识库管理系统 API 服务

第一阶段：
- 后端服务骨架
- 健康检查接口
- 为分类管理、GitHub同步预留接口
"""

from fastapi import FastAPI

app = FastAPI(
    title="九月影知识库管理系统",
    version="0.1.0"
)


@app.get("/")
def index():
    return {
        "system": "knowledge-admin",
        "status": "running"
    }


@app.get("/health")
def health():
    return {
        "status": "ok"
    }
