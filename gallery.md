---
layout: default
title: 图片收藏
permalink: /gallery/
---

<section class="xm-page">
  <header class="xm-page-head">
    <h1>图片收藏</h1>
    <p>收藏喜欢的游戏壁纸、项目截图、思维导图和灵感图片。</p>
  </header>
  <div class="xm-page-body">
    <div class="xm-media-grid">
      {% for item in site.data.gallery %}
      <article class="xm-media-item">
        {% if item.image and item.image != '' %}<a href="{{ item.image }}" target="_blank" rel="noopener"><img src="{{ item.image }}" alt="{{ item.title }}"></a>{% endif %}
        <h3>{{ item.title }}</h3>
        <p>{{ item.description }}</p>
        {% if item.source %}<p style="margin-top:8px"><a href="{{ item.source }}" target="_blank" rel="noopener" style="color:#2990df">查看来源 →</a></p>{% endif %}
      </article>
      {% endfor %}
    </div>
  </div>
</section>
