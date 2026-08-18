---
layout: default
title: 九月影的技术博客
---

<div class="hero">
  <div class="hero-eyebrow">DATA · ENGINEERING · ANALYTICS</div>
  <h1>九月影的技术博客</h1>
  <p>记录数据开发、数据分析、项目实操和面试知识梳理。把零散学习内容沉淀成可检索、可复用的个人知识库。</p>
  <div class="hero-actions">
    <a class="btn-primary" href="{{ '/articles/' | relative_url }}">浏览文章目录</a>
    <a class="btn-secondary" href="{{ '/bank/' | relative_url }}">查看银行监管报送</a>
  </div>
</div>

<div class="section-heading">
  <div>
    <h2>学习方向</h2>
    <p>按主题进入对应知识模块</p>
  </div>
</div>

<div class="topic-grid">
  <a class="topic-card" href="{{ '/bank/' | relative_url }}">
    <span class="topic-icon">🏦</span>
    <h3>银行监管报送</h3>
    <p>1104、G01 / G11 / G12、监管指标口径、Mapping、数据治理与报送开发。</p>
    <span class="card-link">进入栏目 →</span>
  </a>

  <a class="topic-card" href="{{ '/manufacturing/' | relative_url }}">
    <span class="topic-icon">🏭</span>
    <h3>制造业数仓</h3>
    <p>ERP / SRM / WMS、数仓分层、DataX、Hive、DolphinScheduler 与项目实操。</p>
    <span class="card-link">进入栏目 →</span>
  </a>

  <a class="topic-card" href="{{ '/ecommerce/' | relative_url }}">
    <span class="topic-icon">🛒</span>
    <h3>电商数据分析</h3>
    <p>GMV、转化漏斗、RFM、商品库存、营销活动与经营分析。</p>
    <span class="card-link">进入栏目 →</span>
  </a>

  <a class="topic-card" href="{{ '/sql-hive/' | relative_url }}">
    <span class="topic-icon">🗄️</span>
    <h3>SQL / Hive</h3>
    <p>SQL、Hive SQL、窗口函数、数据清洗、质量校验与性能优化。</p>
    <span class="card-link">进入栏目 →</span>
  </a>

  <a class="topic-card" href="{{ '/python/' | relative_url }}">
    <span class="topic-icon">🐍</span>
    <h3>Python</h3>
    <p>Python、Pandas、数据处理、数据分析与日常自动化。</p>
    <span class="card-link">进入栏目 →</span>
  </a>

  <a class="topic-card" href="{{ '/git/' | relative_url }}">
    <span class="topic-icon">🔧</span>
    <h3>Git / GitHub</h3>
    <p>Typora、Git、GitHub Pages 与个人博客维护流程。</p>
    <span class="card-link">进入栏目 →</span>
  </a>
</div>

<div class="section-heading">
  <div>
    <h2>最近更新</h2>
    <p>最近发布的学习笔记</p>
  </div>
  <a href="{{ '/articles/' | relative_url }}">查看全部文章 →</a>
</div>

{% if site.posts.size > 0 %}
<div class="latest-grid">
  {% for post in site.posts limit:8 %}
  <div class="post-card">
    <div class="post-card-date">{{ post.date | date: "%Y-%m-%d" }}</div>
    <h3><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h3>
    <p>{% if post.excerpt %}{{ post.excerpt | strip_html | truncate: 80 }}{% else %}点击查看文章内容。{% endif %}</p>
  </div>
  {% endfor %}
</div>
{% else %}
<div class="post-card">
  <p>暂无文章。以后通过 Typora 在 `_posts` 目录中新建文章并发布后，会自动显示在这里。</p>
</div>
{% endif %}
