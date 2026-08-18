---
layout: default
title: 首页
---

<section class="home-masthead-new">
  <div class="home-masthead-copy-new">
    <span class="eyebrow-new">JIUYUEYING · TECH NOTES</span>
    <h1>把项目经验，整理成能随时翻回来的技术笔记。</h1>
    <p>银行监管报送、制造业数仓、电商数据分析、SQL、Python，以及真实项目和面试问题的持续整理。</p>
  </div>
  <div class="home-masthead-stat-new">
    <strong>{{ site.posts | size }}</strong>
    <span>篇公开笔记</span>
  </div>
</section>

<div class="content-grid-new">
  <main class="feed-new">
    <div class="section-title-new">
      <div>
        <span>RECENT POSTS</span>
        <h2>最新文章</h2>
      </div>
      <a href="{{ '/articles/' | relative_url }}">查看归档</a>
    </div>

    {% if site.posts.size > 0 %}
      {% for post in site.posts limit:10 %}
      <article class="post-row-new">
        <div class="post-row-meta-new">
          <time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%Y.%m.%d" }}</time>
          {% if post.categories and post.categories.size > 0 %}<span>{{ post.categories | first }}</span>{% endif %}
        </div>
        <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
        <p>{% if post.excerpt %}{{ post.excerpt | strip_html | strip_newlines | truncate: 150 }}{% else %}点击进入文章查看完整内容。{% endif %}</p>
        <a class="text-link-new" href="{{ post.url | relative_url }}">阅读全文 <span>→</span></a>
      </article>
      {% endfor %}
    {% else %}
      <div class="empty-new">还没有公开文章。</div>
    {% endif %}
  </main>

  {% include blog-sidebar.html %}
</div>
