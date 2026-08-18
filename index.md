---
layout: default
title: 九月影的技术博客
---

# 九月影的技术博客

记录数据开发、数据分析、项目实操和面试知识梳理。

## 学习方向

- [🏦 银行监管报送](/bank/)：1104、G01/G11/G12、Mapping、数据治理与报送开发
- [🏭 制造业数仓](/manufacturing/)：ERP/SRM/WMS、数仓分层、DataX、Hive、DolphinScheduler
- [🛒 电商数据分析](/ecommerce/)：GMV、漏斗、RFM、商品库存、活动分析
- [🗄️ SQL / Hive](/sql-hive/)：SQL、Hive SQL、窗口函数、性能优化、数据清洗
- [🐍 Python](/python/)：Python、Pandas、数据处理与分析
- [🔧 Git / GitHub](/git/)：Typora、Git、GitHub Pages 与博客维护

## 最近更新

{% if site.posts.size > 0 %}
{% for post in site.posts limit:8 %}
- [{{ post.title }}]({{ post.url | relative_url }}) · {{ post.date | date: "%Y-%m-%d" }}
{% endfor %}
{% else %}
暂无文章。以后通过 Typora 在 `_posts` 目录中新建文章并发布后，会自动显示在这里。
{% endif %}

---

持续整理中……
