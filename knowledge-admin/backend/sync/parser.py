"""
九月影知识库
博客源码解析模块

负责：
1. 解析Jekyll菜单配置
2. 后续解析Markdown文章
3. 转换为知识库内部对象
"""

import yaml


def parse_menu(file_path):
    """解析_menu_defs中的分类配置"""

    with open(file_path, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f)

    return data


def parse_article_frontmatter(content):
    """
    解析Markdown文章头部信息

    示例：
    ---
    title: xxx
    category: xxx
    ---
    """

    if not content.startswith("---"):
        return {}

    parts = content.split("---")

    if len(parts) < 3:
        return {}

    return yaml.safe_load(parts[1])
