"""
文章数据访问层
负责 Article 表的查询、创建、更新、删除
"""


class ArticleRepository:
    def __init__(self, db):
        self.db = db

    def get_all(self):
        """查询全部文章"""
        return []

    def get_by_category(self, category_key):
        """根据分类查询文章"""
        return []

    def save(self, article):
        """保存文章索引"""
        pass

    def update(self, article):
        """更新文章信息"""
        pass

    def soft_delete(self, article_id):
        """软删除文章，不直接物理删除"""
        pass
