---
layout: default
title: 九月影的技术博客
---

<section class="hero decorative-surface">
  <span class="glow-dot glow-one"></span>
  <span class="glow-dot glow-two"></span>
  <div class="hero-eyebrow">DATA · ENGINEERING · ANALYTICS</div>
  <h1>九月影的技术博客</h1>
  <p>记录数据开发、数据分析、项目实操和面试知识梳理，把零散学习内容沉淀成可检索、可复用的个人知识库。</p>

  <div class="hero-tags">
    <span>持续更新</span>
    <span>{{ site.posts | size }} 篇文章</span>
    <span>数据开发 / 数据分析</span>
  </div>

  <div class="hero-actions">
    <a class="btn-primary" href="{{ '/articles/' | relative_url }}">浏览文章目录</a>
    <a class="btn-secondary" href="{{ '/about/' | relative_url }}">关于博客</a>
  </div>
</section>

<div class="section-heading">
  <div>
    <h2>学习方向</h2>
    <p>首页只保留主要方向，完整内容统一进入文章目录。</p>
  </div>
</div>

<div class="topic-grid">
  <a class="topic-card" href="{{ '/bank/' | relative_url }}">
    <span class="topic-icon">🏦</span>
    <div>
      <h3>银行监管报送</h3>
      <p>1104、G01 / G11 / G12、Mapping、数据治理。</p>
    </div>
  </a>
  <a class="topic-card" href="{{ '/manufacturing/' | relative_url }}">
    <span class="topic-icon">🏭</span>
    <div>
      <h3>制造业数仓</h3>
      <p>ERP / SRM / WMS、Hive、DataX、调度与数仓分层。</p>
    </div>
  </a>
  <a class="topic-card" href="{{ '/ecommerce/' | relative_url }}">
    <span class="topic-icon">🛒</span>
    <div>
      <h3>电商数据分析</h3>
      <p>GMV、漏斗、RFM、商品库存与经营分析。</p>
    </div>
  </a>
  <a class="topic-card" href="{{ '/sql-hive/' | relative_url }}">
    <span class="topic-icon">🗄️</span>
    <div>
      <h3>SQL / Hive</h3>
      <p>SQL、Hive SQL、清洗、质量校验与性能优化。</p>
    </div>
  </a>
  <a class="topic-card" href="{{ '/python/' | relative_url }}">
    <span class="topic-icon">🐍</span>
    <div>
      <h3>Python</h3>
      <p>Python、Pandas、数据处理与分析自动化。</p>
    </div>
  </a>
  <a class="topic-card" href="{{ '/git/' | relative_url }}">
    <span class="topic-icon">🔧</span>
    <div>
      <h3>Git / GitHub</h3>
      <p>Typora、Git、GitHub Pages 与博客维护。</p>
    </div>
  </a>
</div>

<div class="section-heading recent-heading">
  <div>
    <h2>最近更新</h2>
    <p>标题、摘要和日期分层展示，优先提高阅读效率。</p>
  </div>
  <a class="section-link" href="{{ '/articles/' | relative_url }}">查看全部 →</a>
</div>

{% if site.posts.size > 0 %}
<div class="home-post-list">
  {% for post in site.posts limit:8 %}
  <article class="home-post-item">
    <div class="home-post-body">
      <h3><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h3>
      <p>{% if post.excerpt %}{{ post.excerpt | strip_html | strip_newlines | truncate: 92 }}{% else %}点击查看文章内容。{% endif %}</p>
      {% if post.categories and post.categories.size > 0 %}
      <div class="home-post-tags">
        {% for category in post.categories %}<span>{{ category }}</span>{% endfor %}
      </div>
      {% endif %}
    </div>
    <time class="home-post-date" datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%Y-%m-%d" }}</time>
  </article>
  {% endfor %}
</div>
{% else %}
<div class="empty-state">暂无文章。以后通过 Typora 新建并发布文章后，会自动显示在这里。</div>
{% endif %}
