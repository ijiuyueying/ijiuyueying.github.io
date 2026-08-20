"""
九月影知识库系统数据模型

第一版：定义核心实体
- Category 分类
- Article 文章
- Asset 图片资产
- OperationLog 操作日志
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class Category:
    """知识分类"""
    id: Optional[int]
    key: str
    name: str
    parent_id: Optional[int]
    status: str = "ACTIVE"
    created_time: datetime = datetime.now()
    updated_time: datetime = datetime.now()


@dataclass
class Article:
    """文章索引"""
    id: Optional[int]
    title: str
    path: str
    category_key: str
    status: str = "PUBLISHED"


@dataclass
class Asset:
    """图片及资源资产"""
    id: Optional[int]
    file_path: str
    category_key: str
    tags: str = ""


@dataclass
class OperationLog:
    """后台操作记录"""
    id: Optional[int]
    action: str
    target: str
    result: str
    created_time: datetime = datetime.now()
