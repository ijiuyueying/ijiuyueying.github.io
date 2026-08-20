"""
文章业务服务层
管理文章索引相关业务
"""


class ArticleService:
    def __init__(self, repository):
        self.repository = repository

    def list_articles(self, category=None):
        if category:
            return self.repository.find_by_category(category)
        return self.repository.get_all()

    def archive_article(self, article_id):
        return self.repository.update_status(article_id, "ARCHIVED")
