---
layout: page
title: Python
permalink: /python/
---

整理 Python、Pandas 和数据分析实操内容。

## 核心内容

- Python 基础语法
- 列表、字典、集合、元组
- 函数与模块
- Pandas 数据读取与处理
- 缺失值、重复值与异常值处理
- 多表关联与指标计算
- 数据校验
- 用户分层与专题分析

## 相关文章

{% assign category_posts = site.categories["python"] %}
{% if category_posts.size > 0 %}
{% for post in category_posts %}
- [{{ post.title }}]({{ post.url | relative_url }}) · {{ post.date | date: "%Y-%m-%d" }}
{% endfor %}
{% else %}
暂无文章。以后文章的 `categories` 设置为 `[python]` 后，会自动出现在这里。
{% endif %}
