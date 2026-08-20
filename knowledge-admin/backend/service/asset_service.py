"""
图片资产业务服务层
管理图片资源索引
"""


class AssetService:
    def __init__(self, repository):
        self.repository = repository

    def list_assets(self, category=None):
        if category:
            return self.repository.find_by_category(category)
        return self.repository.get_all()

    def archive_asset(self, asset_id):
        return self.repository.update_status(asset_id, "ARCHIVED")
