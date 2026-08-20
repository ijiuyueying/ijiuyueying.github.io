"""
图片资产数据访问层
管理 gallery 和图片索引数据
"""


class AssetRepository:
    def __init__(self, db):
        self.db = db

    def get_all(self):
        return []

    def get_by_category(self, category_key):
        return []

    def save(self, asset):
        pass

    def update(self, asset):
        pass

    def soft_delete(self, asset_id):
        pass
