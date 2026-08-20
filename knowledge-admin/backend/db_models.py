"""
九月影知识库系统
SQLAlchemy 数据库模型

负责映射：
1. 分类
2. 文章
3. 图片资产
4. 操作日志
"""

from sqlalchemy import Column, Integer, String, DateTime, Text
from datetime import datetime
from database import Base


class Category(Base):
    """知识分类"""
    __tablename__ = "category"

    id = Column(Integer, primary_key=True)
    key = Column(String(100), unique=True)
    name = Column(String(200))
    parent_id = Column(Integer, default=0)
    status = Column(String(20), default="ACTIVE")
    created_time = Column(DateTime, default=datetime.now)
    updated_time = Column(DateTime, default=datetime.now)


class Article(Base):
    """Markdown文章索引"""
    __tablename__ = "article"

    id = Column(Integer, primary_key=True)
    title = Column(String(300))
    path = Column(String(500))
    category_key = Column(String(100))
    tags = Column(Text)
    status = Column(String(20), default="PUBLISHED")
    updated_time = Column(DateTime, default=datetime.now)


class Asset(Base):
    """图片资源"""
    __tablename__ = "asset"

    id = Column(Integer, primary_key=True)
    file_path = Column(String(500))
    category_key = Column(String(100))
    tags = Column(Text)
    created_time = Column(DateTime, default=datetime.now)


class OperationLog(Base):
    """后台操作日志"""
    __tablename__ = "operation_log"

    id = Column(Integer, primary_key=True)
    action = Column(String(100))
    target = Column(String(200))
    before_data = Column(Text)
    after_data = Column(Text)
    result = Column(String(50))
    created_time = Column(DateTime, default=datetime.now)
