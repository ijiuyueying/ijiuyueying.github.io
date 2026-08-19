---
layout: default
title: 歌曲分类
permalink: /music/
nav_key: music
---

{% assign menu_doc = site.menu_defs | where: 'module_key', 'music' | first %}
<div class="xm-home-grid xm-module-grid" data-module="music">
  <aside class="xm-left-menu">
    {% include collapsible-menu.html menu=menu_doc.items %}
  </aside>

  <main class="xm-center">
    {% include module-filter.html placeholder='筛选当前歌曲' %}
    <section class="xm-page" style="width:100%">
      <header class="xm-page-head"><h1>歌曲分类</h1><p>左侧负责歌曲分类，下面的筛选框只筛歌曲；顶部搜索用于全文搜索文章。</p></header>
      <div class="xm-page-body"><div class="xm-music-list">
        {% for item in site.data.music %}
        <div class="xm-music-row xm-filter-item" data-group="{{ item.group }}" data-subgroup="{{ item.subgroup }}" data-search="{{ item.title }} {{ item.artist }} {{ item.category }} {{ item.description }}">
          <span>♫</span>
          <div><b>{{ item.title }}</b><span>{{ item.artist }} · {{ item.category }}{% if item.platform %} · {{ item.platform }}{% endif %}</span>{% if item.description %}<span style="display:block;margin-top:3px">{{ item.description }}</span>{% endif %}{% if item.file and item.file != '' %}<audio controls preload="none" style="width:min(520px,100%);margin-top:10px"><source src="{{ item.file | relative_url }}"></audio>{% endif %}</div>
          {% if item.url and item.url != '' %}<a href="{{ item.url }}" target="_blank" rel="noopener" style="color:#2990df">正版入口</a>{% endif %}
        </div>
        {% endfor %}
      </div></div>
    </section>
  </main>

  {% include global-rightbar.html %}
  {% include tree-filter-script.html %}
</div>
