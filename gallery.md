---
layout: default
title: 图片收藏
permalink: /gallery/
module_key: gallery
---

{% assign menu_doc = site.menu_defs | where: 'module_key', 'gallery' | first %}
<div class="xm-home-grid xm-module-grid" data-module="gallery">
  <aside class="xm-left-menu">
    {% include collapsible-menu.html menu=menu_doc.items %}
  </aside>

  <main class="xm-center">
    {% include module-filter.html placeholder='筛选当前图片' %}
    <section class="xm-page" style="width:100%">
      <header class="xm-page-head"><h1>图片收藏</h1><p>左侧负责图片分类，下面的筛选框只筛图片；顶部搜索用于全文搜索文章。</p></header>
      <div class="xm-page-body"><div class="xm-media-grid">
        {% for item in site.data.gallery %}
        <article class="xm-media-item xm-filter-item" data-group="{{ item.group }}" data-subgroup="{{ item.subgroup }}" data-search="{{ item.title }} {{ item.description }}">
          {% if item.image and item.image != '' %}<a href="{{ item.image }}" target="_blank" rel="noopener"><img src="{{ item.image }}" alt="{{ item.title }}"></a>{% endif %}
          <h3>{{ item.title }}</h3><p>{{ item.description }}</p>
          {% if item.source %}<p style="margin-top:8px"><a href="{{ item.source }}" target="_blank" rel="noopener" style="color:#2990df">查看来源 →</a></p>{% endif %}
        </article>
        {% endfor %}
      </div></div>
    </section>
  </main>

  {% include global-rightbar.html %}
  {% include tree-filter-script.html %}
</div>
