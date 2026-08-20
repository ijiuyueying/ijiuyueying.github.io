"""
GitHub数据同步服务

作用：
读取当前博客源码：
- _menu_defs
- _posts
- _data/gallery.yml

同步到知识库数据库。

后续扩展：
- 增量同步
- 文件变化检测
- GitHub webhook
"""

from pathlib import Path


BLOG_ROOT = Path("../../")


def sync_categories():
    """
    同步菜单分类
    当前为框架，后续接入YAML解析
    """
    menu_path = BLOG_ROOT / "_menu_defs"
    return {
        "source": str(menu_path),
        "status": "ready"
    }


def sync_articles():
    """
    同步Markdown文章索引
    """
    post_path = BLOG_ROOT / "_posts"
    return {
        "source": str(post_path),
        "status": "ready"
    }


if __name__ == "__main__":
    print(sync_categories())
    print(sync_articles())
