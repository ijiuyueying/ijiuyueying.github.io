---
layout: default
title: 九月影的技术博客
---

<section class="home-intro">
  <div class="home-intro-copy">
    <div class="hero-eyebrow">DATA · ENGINEERING · ANALYTICS</div>
    <h1>九月影的技术博客</h1>
    <p>记录数据开发、数据分析、项目实操和面试知识梳理，把学习过程沉淀成长期可复用的个人知识库。</p>
    <div class="hero-tags">
      <span>持续更新</span>
      <span>{{ site.posts | size }} 篇文章</span>
      <span>数据开发 / 数据分析</span>
    </div>
  </div>
</section>

<div class="home-blog-layout">
  <aside class="home-sidebar">
    <div class="home-side-block">
      <div class="home-side-title">学习方向</div>
      <a class="home-category-link" href="{{ '/bank/' | relative_url }}"><span>🏦 银行监管报送</span><strong>{{ site.categories['bank'] | size }}</strong></a>
      <a class="home-category-link" href="{{ '/manufacturing/' | relative_url }}"><span>🏭 制造业数仓</span><strong>{{ site.categories['manufacturing'] | size }}</strong></a>
      <a class="home-category-link" href="{{ '/ecommerce/' | relative_url }}"><span>🛒 电商数据分析</span><strong>{{ site.categories['ecommerce'] | size }}</strong></a>
      <a class="home-category-link" href="{{ '/sql-hive/' | relative_url }}"><span>🗄️ SQL / Hive</span><strong>{{ site.categories['sql-hive'] | size }}</strong></a>
      <a class="home-category-link" href="{{ '/python/' | relative_url }}"><span>🐍 Python</span><strong>{{ site.categories['python'] | size }}</strong></a>
      <a class="home-category-link" href="{{ '/git/' | relative_url }}"><span>🔧 Git / GitHub</span><strong>{{ site.categories['git'] | size }}</strong></a>
    </div>

    <div class="home-side-block home-side-note">
      <div class="home-side-title">关于这个博客</div>
      <p>以项目、问题和面试场景为主线整理技术知识，不追求堆砌术语。</p>
      <a href="{{ '/about/' | relative_url }}">了解更多 →</a>
    </div>
  </aside>

  <main class="home-feed">
    <div class="feed-heading">
      <div>
        <span class="feed-kicker">LATEST</span>
        <h2>最近文章</h2>
      </div>
      <a href="{{ '/articles/' | relative_url }}">查看全部 →</a>
    </div>

    {% if site.posts.size > 0 %}
      {% for post in site.posts limit:10 %}
      <article class="feed-post">
        <div class="feed-post-meta">
          <time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%Y-%m-%d" }}</time>
          {% if post.categories and post.categories.size > 0 %}
            <span>·</span>
            <span>{{ post.categories | join: " / " }}</span>
          {% endif %}
        </div>
        <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
        <p>{% if post.excerpt %}{{ post.excerpt | strip_html | strip_newlines | truncate: 150 }}{% else %}点击查看文章内容。{% endif %}</p>
        <a class="read-more" href="{{ post.url | relative_url }}">阅读全文 <span>→</span></a>
      </article>
      {% endfor %}
    {% else %}
      <div class="empty-state">暂无文章。以后通过 Typora 发布文章后，会自动显示在这里。</div>
    {% endif %}
  </main>
</div>
