---
layout: page
title: 制造业数仓
permalink: /manufacturing/
---

记录制造业数据仓库、数据开发与项目实操内容。

## 数仓建设

- ODS 原始数据层
- DIM 维度层
- DWD 明细数据层
- DWS 汇总数据层
- ADS 应用数据层

## 项目链路

- ERP / SRM / WMS 数据来源
- DataX 数据同步
- Hive SQL 数据开发
- 数据清洗与质量校验
- 增量、全量与历史数据处理
- DolphinScheduler 调度
- 采购执行、库存与供应商分析

## 相关文章

{% assign category_posts = site.categories["manufacturing"] %}
{% if category_posts.size > 0 %}
{% for post in category_posts %}
- [{{ post.title }}]({{ post.url | relative_url }}) · {{ post.date | date: "%Y-%m-%d" }}
{% endfor %}
{% else %}
暂无文章。以后文章的 `categories` 设置为 `[manufacturing]` 后，会自动出现在这里。
{% endif %}
