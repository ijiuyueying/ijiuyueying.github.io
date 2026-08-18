---
layout: page
title: 文章归档
permalink: /articles/
---

<div class="classic-blog-layout archive-page-layout">
  <main class="classic-main">
    <section class="classic-page-head">
      <h1>文章归档</h1>
      <p>共 {{ site.posts | size }} 篇文章，按发布时间倒序整理。</p>
    </section>

    {% if site.posts.size > 0 %}
      {% assign current_year = '' %}
      <div class="archive-list-simple">
        {% for post in site.posts %}
          {% assign post_year = post.date | date: "%Y" %}
          {% if post_year != current_year %}
            <div class="archive-year-simple">{{ post_year }}</div>
            {% assign current_year = post_year %}
          {% endif %}

          <article class="archive-row-simple">
            <time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%m-%d" }}</time>
            <div>
              <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
              <p>{% if post.excerpt %}{{ post.excerpt | strip_html | strip_newlines | truncate: 120 }}{% else %}点击查看文章内容。{% endif %}</p>
              {% if post.categories and post.categories.size > 0 %}
                <div class="archive-row-meta">{{ post.categories | join: " / " }}</div>
              {% endif %}
            </div>
          </article>
        {% endfor %}
      </div>
    {% else %}
      <div class="empty-state">暂无文章。</div>
    {% endif %}
  </main>

  {% include blog-sidebar.html %}
</div>
