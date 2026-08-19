---
layout: default
title: 歌曲分类
permalink: /music/
nav_key: music
---

<section class="xm-page">
  <header class="xm-page-head">
    <h1>歌曲分类</h1>
    <p>支持正版平台链接，也支持你自己放到仓库里的本地 MP3 / M4A / OGG 文件。</p>
  </header>
  <div class="xm-page-body">
    <div class="xm-music-list">
      {% for item in site.data.music %}
      <div class="xm-music-row" style="grid-template-columns:36px 1fr auto">
        <span>♫</span>
        <div>
          <b>{{ item.title }}</b>
          <span>{{ item.artist }} · {{ item.category }}{% if item.platform %} · {{ item.platform }}{% endif %}</span>
          {% if item.description %}<span style="display:block;margin-top:3px">{{ item.description }}</span>{% endif %}
          {% if item.file and item.file != '' %}
          <audio controls preload="none" style="width:min(520px,100%);margin-top:10px">
            <source src="{{ item.file | relative_url }}">
          </audio>
          {% endif %}
        </div>
        {% if item.url and item.url != '' %}<a href="{{ item.url }}" target="_blank" rel="noopener" style="color:#2990df">正版入口</a>{% endif %}
      </div>
      {% endfor %}
    </div>
  </div>
</section>
