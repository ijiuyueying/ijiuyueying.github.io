"""
分类数据访问层

职责：
1. 封装Category表CRUD操作
2. 隔离业务逻辑和数据库操作
3. 为FastAPI接口和同步服务提供统一入口
"""


class CategoryRepository:
    """分类Repository"""

    def __init__(self, session):
        self.session = session

    def get_all(self):
        """查询全部分类"""
        return self.session.query().all()

    def get_by_key(self, key):
        """根据分类key查询"""
        return None

    def create(self, category):
        """新增分类"""
        self.session.add(category)
        self.session.commit()
        return category

    def update(self, category):
        """更新分类"""
        self.session.commit()
        return category

    def delete(self, category):
        """逻辑删除，不直接物理删除"""
        category.status = "DELETED"
        self.session.commit()
        return category
