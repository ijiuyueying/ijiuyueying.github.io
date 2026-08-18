---
layout: page
title: 文章目录
permalink: /articles/
---

<div class="catalog-intro">
  <div>
    <strong>个人知识库</strong><br>
    <span style="color:#667085;font-size:14px">按主题浏览全部文章；新增 `_posts` 文章后会自动更新。</span>
  </div>
  <div class="catalog-count">{{ site.posts | size }} 篇文章</div>
</div>

<div class="catalog-grid">
  <section class="catalog-card">
    <h2>🏦 银行监管报送</h2>
    {% assign bank_posts = site.categories["bank"] %}
    {% if bank_posts.size > 0 %}
    <ul>
      {% for post in bank_posts %}
      <li><a href="{{ post.url | relative_url }}">{{ post.title }}</a> · {{ post.date | date: "%Y-%m-%d" }}</li>
      {% endfor %}
    </ul>
    {% else %}<p>暂无文章。</p>{% endif %}
  </section>

  <section class="catalog-card">
    <h2>🏭 制造业数仓</h2>
    {% assign manufacturing_posts = site.categories["manufacturing"] %}
    {% if manufacturing_posts.size > 0 %}
    <ul>
      {% for post in manufacturing_posts %}
      <li><a href="{{ post.url | relative_url }}">{{ post.title }}</a> · {{ post.date | date: "%Y-%m-%d" }}</li>
      {% endfor %}
    </ul>
    {% else %}<p>暂无文章。</p>{% endif %}
  </section>

  <section class="catalog-card">
    <h2>🛒 电商数据分析</h2>
    {% assign ecommerce_posts = site.categories["ecommerce"] %}
    {% if ecommerce_posts.size > 0 %}
    <ul>
      {% for post in ecommerce_posts %}
      <li><a href="{{ post.url | relative_url }}">{{ post.title }}</a> · {{ post.date | date: "%Y-%m-%d" }}</li>
      {% endfor %}
    </ul>
    {% else %}<p>暂无文章。</p>{% endif %}
  </section>

  <section class="catalog-card">
    <h2>🗄️ SQL / Hive</h2>
    {% assign sql_posts = site.categories["sql-hive"] %}
    {% if sql_posts.size > 0 %}
    <ul>
      {% for post in sql_posts %}
      <li><a href="{{ post.url | relative_url }}">{{ post.title }}</a> · {{ post.date | date: "%Y-%m-%d" }}</li>
      {% endfor %}
    </ul>
    {% else %}<p>暂无文章。</p>{% endif %}
  </section>

  <section class="catalog-card">
    <h2>🐍 Python</h2>
    {% assign python_posts = site.categories["python"] %}
    {% if python_posts.size > 0 %}
    <ul>
      {% for post in python_posts %}
      <li><a href="{{ post.url | relative_url }}">{{ post.title }}</a> · {{ post.date | date: "%Y-%m-%d" }}</li>
      {% endfor %}
    </ul>
    {% else %}<p>暂无文章。</p>{% endif %}
  </section>

  <section class="catalog-card">
    <h2>🔧 Git / GitHub</h2>
    {% assign git_posts = site.categories["git"] %}
    {% if git_posts.size > 0 %}
    <ul>
      {% for post in git_posts %}
      <li><a href="{{ post.url | relative_url }}">{{ post.title }}</a> · {{ post.date | date: "%Y-%m-%d" }}</li>
      {% endfor %}
    </ul>
    {% else %}<p>暂无文章。</p>{% endif %}
  </section>
</div>

<div class="section-heading">
  <div>
    <h2>全部文章</h2>
    <p>按发布时间倒序</p>
  </div>
</div>

<div class="latest-grid">
{% for post in site.posts %}
  <div class="post-card">
    <div class="post-card-date">{{ post.date | date: "%Y-%m-%d" }}</div>
    <h3><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h3>
    <p>{% if post.categories %}{{ post.categories | join: " · " }}{% endif %}</p>
  </div>
{% endfor %}
</div>
