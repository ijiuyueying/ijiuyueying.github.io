---
layout: page
title: Git / GitHub
permalink: /git/
---

整理 Typora、Git、GitHub 与 GitHub Pages 的使用记录。

## 日常博客流程

1. 在 Typora 中打开本地博客仓库文件夹。
2. 在 `_posts` 中新增或修改 Markdown 文章。
3. 保存文章和图片。
4. 双击仓库根目录的 `发布博客.bat`。
5. Git 自动提交、同步并推送到 GitHub。
6. GitHub Pages 自动重新发布网站。

## 相关文章

{% assign category_posts = site.categories["git"] %}
{% if category_posts.size > 0 %}
{% for post in category_posts %}
- [{{ post.title }}]({{ post.url | relative_url }}) · {{ post.date | date: "%Y-%m-%d" }}
{% endfor %}
{% else %}
暂无文章。以后文章的 `categories` 设置为 `[git]` 后，会自动出现在这里。
{% endif %}
