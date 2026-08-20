"""
九月影知识库同步服务

作用：
1. 读取博客源码
2. 调用解析模块
3. 同步分类、文章、图片索引
4. 记录同步结果

当前版本为同步框架，后续接入数据库写入。
"""

from datetime import datetime


class KnowledgeSyncService:
    """知识库同步服务"""

    def __init__(self, source_path):
        # GitHub博客源码目录
        self.source_path = source_path
        self.sync_time = datetime.now()

    def sync_categories(self):
        """同步分类配置

        数据来源：
        _menu_defs/*.md
        """
        return {
            "type": "category",
            "status": "ready",
            "time": str(self.sync_time)
        }

    def sync_articles(self):
        """同步文章数据

        数据来源：
        _posts/*.md
        """
        return {
            "type": "article",
            "status": "ready",
            "time": str(self.sync_time)
        }

    def sync_assets(self):
        """同步图片资产

        数据来源：
        _data/gallery.yml
        assets/images
        """
        return {
            "type": "asset",
            "status": "ready",
            "time": str(self.sync_time)
        }

    def full_sync(self):
        """执行完整同步"""
        return {
            "sync_time": str(self.sync_time),
            "results": [
                self.sync_categories(),
                self.sync_articles(),
                self.sync_assets()
            ]
        }


if __name__ == "__main__":
    service = KnowledgeSyncService("../../")
    print(service.full_sync())
