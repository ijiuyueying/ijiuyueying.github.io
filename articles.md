---
layout: page
title: 文章目录
permalink: /articles/
---

<div class="archive-head">
  <div>
    <p class="archive-kicker">ARCHIVE · KNOWLEDGE BASE</p>
    <h1>文章目录</h1>
    <p class="archive-subtitle">按分类浏览、按时间查找。共 {{ site.posts | size }} 篇文章，持续更新中。</p>
  </div>
</div>

<div class="archive-layout">
  <aside class="archive-sidebar">
    <div class="archive-side-title">分类</div>
    <a class="archive-filter active" href="{{ '/articles/' | relative_url }}"><span>全部文章</span><strong>{{ site.posts | size }}</strong></a>
    <a class="archive-filter" href="{{ '/bank/' | relative_url }}"><span>🏦 银行监管报送</span><strong>{{ site.categories["bank"] | size }}</strong></a>
    <a class="archive-filter" href="{{ '/manufacturing/' | relative_url }}"><span>🏭 制造业数仓</span><strong>{{ site.categories["manufacturing"] | size }}</strong></a>
    <a class="archive-filter" href="{{ '/ecommerce/' | relative_url }}"><span>🛒 电商数据分析</span><strong>{{ site.categories["ecommerce"] | size }}</strong></a>
    <a class="archive-filter" href="{{ '/sql-hive/' | relative_url }}"><span>🗄️ SQL / Hive</span><strong>{{ site.categories["sql-hive"] | size }}</strong></a>
    <a class="archive-filter" href="{{ '/python/' | relative_url }}"><span>🐍 Python</span><strong>{{ site.categories["python"] | size }}</strong></a>
    <a class="archive-filter" href="{{ '/git/' | relative_url }}"><span>🔧 Git / GitHub</span><strong>{{ site.categories["git"] | size }}</strong></a>
  </aside>

  <main class="archive-main">
    {% if site.posts.size > 0 %}
      {% assign current_year = '' %}
      {% for post in site.posts %}
        {% assign post_year = post.date | date: "%Y" %}
        {% if post_year != current_year %}
          {% unless forloop.first %}</div>{% endunless %}
          <div class="archive-year-group">
            <div class="archive-year">{{ post_year }}</div>
          {% assign current_year = post_year %}
        {% endif %}

        <article class="archive-post">
          <time class="archive-date" datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%m-%d" }}</time>
          <div class="archive-post-content">
            <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
            <p class="archive-excerpt">{% if post.excerpt %}{{ post.excerpt | strip_html | strip_newlines | truncate: 100 }}{% else %}点击查看文章内容。{% endif %}</p>
            {% if post.categories and post.categories.size > 0 %}
            <div class="archive-tags">{% for category in post.categories %}<span>{{ category }}</span>{% endfor %}</div>
            {% endif %}
          </div>
        </article>
      {% endfor %}
      </div>
    {% else %}
      <div class="empty-state">暂无文章。</div>
    {% endif %}
  </main>
</div>
