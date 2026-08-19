---
layout: default
title: 图片收藏
permalink: /gallery/
---

<section class="xm-page">
  <header class="xm-page-head">
    <h1>图片收藏</h1>
    <p>用于保存学习图、项目截图、思维导图和个人灵感图片。</p>
  </header>
  <div class="xm-page-body">
    <div class="xm-media-grid">
      {% for item in site.data.gallery %}
      <article class="xm-media-item">
        {% if item.image and item.image != '' %}<img src="{{ item.image | relative_url }}" alt="{{ item.title }}">{% endif %}
        <h3>{{ item.title }}</h3>
        <p>{{ item.description }}</p>
      </article>
      {% endfor %}
    </div>
  </div>
</section>
