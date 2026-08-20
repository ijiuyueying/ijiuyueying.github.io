"""
分类业务服务层
负责分类相关业务逻辑，不直接处理数据库细节
"""


class CategoryService:
    def __init__(self, repository):
        self.repository = repository

    def list_categories(self):
        """查询全部分类"""
        return self.repository.get_all()

    def archive_category(self, category_key):
        """归档分类，保留历史数据"""
        return self.repository.update_status(category_key, "ARCHIVED")

    def delete_category(self, category_key):
        """软删除分类"""
        return self.repository.update_status(category_key, "DELETED")
