---
layout: default
title: 文章归档
permalink: /articles/
---

<section class="archive-head-new">
  <span class="eyebrow-new">ARCHIVE</span>
  <h1>文章归档</h1>
  <p>按时间浏览全部公开文章，共 {{ site.posts | size }} 篇。</p>
</section>

<div class="content-grid-new archive-grid-new">
  <main class="archive-list-new">
    {% if site.posts.size > 0 %}
      {% assign current_year = '' %}
      {% for post in site.posts %}
        {% assign year = post.date | date: "%Y" %}
        {% if year != current_year %}
          <div class="year-label-new">{{ year }}</div>
          {% assign current_year = year %}
        {% endif %}
        <article class="archive-row-new">
          <time>{{ post.date | date: "%m.%d" }}</time>
          <div>
            <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
            <div class="archive-meta-new">
              {% if post.categories and post.categories.size > 0 %}<span>{{ post.categories | join: " / " }}</span>{% endif %}
              {% if post.tags and post.tags.size > 0 %}<span>{{ post.tags | join: " · " }}</span>{% endif %}
            </div>
          </div>
        </article>
      {% endfor %}
    {% else %}
      <div class="empty-new">还没有公开文章。</div>
    {% endif %}
  </main>

  {% include blog-sidebar.html %}
</div>
