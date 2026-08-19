---
layout: default
title: 视频收藏
permalink: /videos/
module_key: videos
---

{% assign menu_doc = site.menu_defs | where: 'module_key', 'videos' | first %}
<div class="xm-home-grid xm-module-grid" data-module="videos">
  <aside class="xm-left-menu">
    {% include collapsible-menu.html menu=menu_doc.items %}
  </aside>

  <main class="xm-center">
    <section class="xm-page" style="width:100%">
      <header class="xm-page-head"><h1>视频收藏</h1><p>点击二级分类后，再展开对应三级分类。</p></header>
      <div class="xm-page-body"><div class="xm-media-grid">
        {% for item in site.data.videos %}
        <article class="xm-media-item xm-filter-item" data-group="{{ item.group }}" data-subgroup="{{ item.subgroup }}" data-search="{{ item.title }} {{ item.description }}">
          {% if item.platform == 'bilibili' and item.bvid %}
          <div style="position:relative;width:100%;padding-top:56.25%;margin-bottom:10px;background:#111;overflow:hidden;"><iframe src="https://player.bilibili.com/player.html?bvid={{ item.bvid }}&page=1&high_quality=1&danmaku=0" style="position:absolute;inset:0;width:100%;height:100%;border:0;" allowfullscreen scrolling="no"></iframe></div>
          {% elsif item.video and item.video != '' %}
          <video controls{% if item.poster and item.poster != '' %} poster="{{ item.poster }}"{% endif %}><source src="{{ item.video }}"></video>
          {% endif %}
          <h3>{{ item.title }}</h3><p>{{ item.description }}</p>
          {% if item.url %}<p style="margin-top:8px"><a href="{{ item.url }}" target="_blank" rel="noopener" style="color:#2990df">在原网站打开 →</a></p>{% endif %}
        </article>
        {% endfor %}
      </div></div>
    </section>
  </main>

  {% include global-rightbar.html %}
  {% include tree-filter-script.html %}
</div>
