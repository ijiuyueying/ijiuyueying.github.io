---
layout: default
title: 视频收藏
permalink: /videos/
---

<section class="xm-page">
  <header class="xm-page-head">
    <h1>视频收藏</h1>
    <p>用于保存教程、项目演示、学习视频和个人收藏。</p>
  </header>
  <div class="xm-page-body">
    <div class="xm-media-grid">
      {% for item in site.data.videos %}
      <article class="xm-media-item">
        {% if item.video and item.video != '' %}
        <video controls{% if item.poster and item.poster != '' %} poster="{{ item.poster | relative_url }}"{% endif %}>
          <source src="{{ item.video | relative_url }}">
        </video>
        {% endif %}
        <h3>{{ item.title }}</h3>
        <p>{{ item.description }}</p>
      </article>
      {% endfor %}
    </div>
  </div>
</section>
