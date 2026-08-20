"""
分类管理 API

提供：
1. 查询分类
2. 分类状态管理
3. 后续接入 GitHub 同步
"""

from fastapi import APIRouter

router = APIRouter(prefix="/categories", tags=["分类管理"])


@router.get("")
def list_categories():
    """返回当前分类列表

    后续从 SQLite 查询，
    当前预留接口结构。
    """
    return {
        "status": "success",
        "data": []
    }


@router.get("/{category_key}")
def get_category(category_key: str):
    """查询单个分类详情"""
    return {
        "status": "success",
        "category": category_key
    }
