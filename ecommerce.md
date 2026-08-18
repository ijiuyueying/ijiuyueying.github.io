---
layout: page
title: 电商数据分析
permalink: /ecommerce/
---

记录多平台电商经营分析、指标体系与专题分析内容。

## 核心内容

- GMV、订单量、支付买家数、UV
- 支付转化率、客单价、新客占比、复购率
- 退款率、动销率、售罄率、库存周转率
- 转化漏斗与异常归因
- RFM 用户分层
- 商品与库存分析
- 活动分析与 A/B Test
- FineReport 经营看板

## 相关文章

{% assign category_posts = site.categories["ecommerce"] %}
{% if category_posts.size > 0 %}
{% for post in category_posts %}
- [{{ post.title }}]({{ post.url | relative_url }}) · {{ post.date | date: "%Y-%m-%d" }}
{% endfor %}
{% else %}
暂无文章。以后文章的 `categories` 设置为 `[ecommerce]` 后，会自动出现在这里。
{% endif %}
