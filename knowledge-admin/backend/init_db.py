"""
九月影知识库
数据库初始化脚本

作用：
1. 创建SQLite数据库
2. 初始化Category、Article、Asset、OperationLog表

运行：
python init_db.py
"""

from database import engine
from db_models import Base


# 根据SQLAlchemy模型自动创建数据表
Base.metadata.create_all(bind=engine)

print("知识库数据库初始化完成")
