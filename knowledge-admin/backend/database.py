"""
SQLite数据库连接模块

后续用于保存：
- 分类索引
- 文章索引
- 图片资产
- 操作日志
"""

import sqlite3

DATABASE = "knowledge.db"


def get_connection():
    return sqlite3.connect(DATABASE)


if __name__ == "__main__":
    conn = get_connection()
    print("SQLite connection success")
    conn.close()
