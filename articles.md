---
layout: page
title: 文章目录
permalink: /articles/
---

这里汇总博客中的全部文章。以后只要在 `_posts` 新增文章并填写 `categories`，对应栏目会自动更新。

**文章总数：{{ site.posts | size }}**

## 🏦 银行监管报送

{% assign bank_posts = site.categories["bank"] %}
{% if bank_posts.size > 0 %}
{% for post in bank_posts %}
- [{{ post.title }}]({{ post.url | relative_url }}) · {{ post.date | date: "%Y-%m-%d" }}
{% endfor %}
{% else %}
暂无文章。
{% endif %}

## 🏭 制造业数仓

{% assign manufacturing_posts = site.categories["manufacturing"] %}
{% if manufacturing_posts.size > 0 %}
{% for post in manufacturing_posts %}
- [{{ post.title }}]({{ post.url | relative_url }}) · {{ post.date | date: "%Y-%m-%d" }}
{% endfor %}
{% else %}
暂无文章。
{% endif %}

## 🛒 电商数据分析

{% assign ecommerce_posts = site.categories["ecommerce"] %}
{% if ecommerce_posts.size > 0 %}
{% for post in ecommerce_posts %}
- [{{ post.title }}]({{ post.url | relative_url }}) · {{ post.date | date: "%Y-%m-%d" }}
{% endfor %}
{% else %}
暂无文章。
{% endif %}

## 🗄️ SQL / Hive

{% assign sql_posts = site.categories["sql-hive"] %}
{% if sql_posts.size > 0 %}
{% for post in sql_posts %}
- [{{ post.title }}]({{ post.url | relative_url }}) · {{ post.date | date: "%Y-%m-%d" }}
{% endfor %}
{% else %}
暂无文章。
{% endif %}

## 🐍 Python

{% assign python_posts = site.categories["python"] %}
{% if python_posts.size > 0 %}
{% for post in python_posts %}
- [{{ post.title }}]({{ post.url | relative_url }}) · {{ post.date | date: "%Y-%m-%d" }}
{% endfor %}
{% else %}
暂无文章。
{% endif %}

## 🔧 Git / GitHub

{% assign git_posts = site.categories["git"] %}
{% if git_posts.size > 0 %}
{% for post in git_posts %}
- [{{ post.title }}]({{ post.url | relative_url }}) · {{ post.date | date: "%Y-%m-%d" }}
{% endfor %}
{% else %}
暂无文章。
{% endif %}

---

### 全部文章（按时间倒序）

{% for post in site.posts %}
- {{ post.date | date: "%Y-%m-%d" }} · [{{ post.title }}]({{ post.url | relative_url }})
{% endfor %}
