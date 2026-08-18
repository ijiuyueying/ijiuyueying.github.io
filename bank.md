---
layout: page
title: 银行监管报送
permalink: /bank/
---

这里主要整理银行监管报送、1104 报表体系以及监管数据开发相关内容。

## 核心内容

- 1104 监管报送体系
- G01 资产负债项目统计表
- G11 资产质量五级分类情况表
- G12 贷款质量迁徙情况表
- 监管指标口径与 Mapping
- 数据清洗、数据治理与数据校验
- 监管报送开发完整链路

## 相关文章

{% assign category_posts = site.categories["bank"] %}
{% if category_posts.size > 0 %}
{% for post in category_posts %}
- [{{ post.title }}]({{ post.url | relative_url }}) · {{ post.date | date: "%Y-%m-%d" }}
{% endfor %}
{% else %}
暂无文章。以后文章的 `categories` 设置为 `[bank]` 后，会自动出现在这里。
{% endif %}
