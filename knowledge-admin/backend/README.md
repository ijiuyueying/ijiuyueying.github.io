# 九月影知识库管理系统 Backend

技术方案：

- FastAPI
- SQLite
- GitHub API

目录规划：

```text
backend
├── app.py              # 服务入口
├── database.py         # 数据库连接
├── models.py           # 数据模型
├── api
│   ├── category.py     # 分类管理
│   ├── article.py      # 文章管理
│   ├── gallery.py      # 图片管理
│   └── github_sync.py  # GitHub同步
```

目标：

1. 读取Jekyll博客数据
2. 建立本地索引
3. 提供管理API
4. 安全同步GitHub
