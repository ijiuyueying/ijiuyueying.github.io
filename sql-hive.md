---
layout: page
title: SQL / Hive
permalink: /sql-hive/
---

整理 SQL、Hive SQL、数仓开发和性能优化相关知识。

## 核心内容

- SELECT / JOIN / GROUP BY
- CASE WHEN 与子查询
- CTE 公共表表达式
- 窗口函数
- Hive 分区与分桶
- 增量与全量处理
- 数据清洗 SQL
- 数据质量校验
- SQL 性能优化

## 相关文章

{% assign category_posts = site.categories["sql-hive"] %}
{% if category_posts.size > 0 %}
{% for post in category_posts %}
- [{{ post.title }}]({{ post.url | relative_url }}) · {{ post.date | date: "%Y-%m-%d" }}
{% endfor %}
{% else %}
暂无文章。以后文章的 `categories` 设置为 `[sql-hive]` 后，会自动出现在这里。
{% endif %}
