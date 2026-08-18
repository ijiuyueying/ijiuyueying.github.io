---
layout: default
title: 九月影的技术博客
---

<div class="classic-blog-layout">
  <main class="classic-main">
    <section class="classic-welcome">
      <div class="classic-welcome-kicker">JIUYUEYING · TECH BLOG</div>
      <h1>九月影的技术博客</h1>
      <p>记录数据开发、数据分析、银行监管报送、制造业数仓、项目实操与面试知识，把学习过程持续沉淀成可检索、可复用的个人知识库。</p>
    </section>

    <section class="classic-section-head">
      <div>
        <h2>最新文章</h2>
        <p>按发布时间倒序</p>
      </div>
      <a href="{{ '/articles/' | relative_url }}">全部文章 →</a>
    </section>

    {% if site.posts.size > 0 %}
      <div class="classic-post-list">
        {% for post in site.posts limit:10 %}
        <article class="classic-post-item">
          <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
          <div class="classic-post-meta">
            <time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%Y-%m-%d" }}</time>
            {% if post.categories and post.categories.size > 0 %}
              <span> · {{ post.categories | join: " / " }}</span>
            {% endif %}
          </div>
          <p>{% if post.excerpt %}{{ post.excerpt | strip_html | strip_newlines | truncate: 180 }}{% else %}点击查看文章内容。{% endif %}</p>
          <a class="classic-read-more" href="{{ post.url | relative_url }}">阅读全文 »</a>
        </article>
        {% endfor %}
      </div>
    {% else %}
      <div class="empty-state">暂无文章。以后通过 Typora 发布文章后，会自动显示在这里。</div>
    {% endif %}
  </main>

  {% include blog-sidebar.html %}
</div>
