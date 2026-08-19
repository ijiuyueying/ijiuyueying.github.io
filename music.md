---
layout: default
title: 歌曲分类
permalink: /music/
nav_key: music
---

<div class="xm-home-grid xm-module-grid" data-module="music">
  <aside class="xm-left-menu">
    {% include collapsible-menu.html menu=site.data.module_menus.music %}
  </aside>

  <main class="xm-center">
    <section class="xm-page" style="width:100%">
      <header class="xm-page-head"><h1>歌曲分类</h1><p>点击二级分类后，再展开对应三级分类；支持正版链接与本地音频。</p></header>
      <div class="xm-page-body"><div class="xm-music-list">
        {% for item in site.data.music %}
        <div class="xm-music-row xm-filter-item" data-group="{{ item.group }}" data-subgroup="{{ item.subgroup }}" data-search="{{ item.title }} {{ item.artist }} {{ item.category }}">
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
