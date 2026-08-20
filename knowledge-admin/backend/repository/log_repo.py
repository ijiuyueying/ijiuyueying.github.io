"""
操作日志数据访问层
记录后台所有变更行为
"""


class LogRepository:
    def __init__(self, db):
        self.db = db

    def add_log(self, operation):
        """新增操作记录"""
        pass

    def get_latest(self, limit=20):
        """查询最近操作"""
        return []
