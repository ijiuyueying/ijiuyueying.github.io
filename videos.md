---
layout: default
title: 视频收藏
permalink: /videos/
---

<section class="xm-page">
  <header class="xm-page-head">
    <h1>视频收藏</h1>
    <p>收藏动画剪辑、教程、项目演示与个人喜欢的视频。</p>
  </header>
  <div class="xm-page-body">
    <div class="xm-media-grid">
      {% for item in site.data.videos %}
      <article class="xm-media-item">
        {% if item.platform == 'bilibili' and item.bvid %}
        <div style="position:relative;width:100%;padding-top:56.25%;margin-bottom:10px;background:#111;overflow:hidden;">
          <iframe src="https://player.bilibili.com/player.html?bvid={{ item.bvid }}&page=1&high_quality=1&danmaku=0" style="position:absolute;inset:0;width:100%;height:100%;border:0;" allowfullscreen scrolling="no"></iframe>
        </div>
        {% elsif item.video and item.video != '' %}
        <video controls{% if item.poster and item.poster != '' %} poster="{{ item.poster }}"{% endif %}>
          <source src="{{ item.video }}">
        </video>
        {% endif %}
        <h3>{{ item.title }}</h3>
        <p>{{ item.description }}</p>
        {% if item.url %}<p style="margin-top:8px"><a href="{{ item.url }}" target="_blank" rel="noopener" style="color:#2990df">在原网站打开 →</a></p>{% endif %}
      </article>
      {% endfor %}
    </div>
  </div>
</section>
