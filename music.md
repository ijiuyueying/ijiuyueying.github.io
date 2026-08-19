---
layout: default
title: 歌曲分类
permalink: /music/
nav_key: music
---

<section class="xm-page">
  <header class="xm-page-head">
    <h1>歌曲分类</h1>
    <p>个人音乐收藏，后续可按华语、欧美、轻音乐等继续扩展。</p>
  </header>
  <div class="xm-page-body">
    <div class="xm-music-list">
      {% for item in site.data.music %}
      <div class="xm-music-row">
        <span>♫</span>
        <div><b>{{ item.title }}</b><span>{{ item.artist }} · {{ item.category }}</span></div>
        {% if item.url and item.url != '' %}<a href="{{ item.url }}" target="_blank" rel="noopener">播放</a>{% else %}<span>待添加</span>{% endif %}
      </div>
      {% endfor %}
    </div>
  </div>
</section>
