---
layout: default
title: 网址导航
permalink: /nav/
nav_key: nav
---

{% assign menu_doc = site.menu_defs | where: 'module_key', 'nav' | first %}
<div class="xm-home-grid xm-module-grid" data-module="nav">
  <aside class="xm-left-menu">
    {% include collapsible-menu.html menu=menu_doc.items %}
  </aside>

  <main class="xm-center">
    <section class="xm-page" style="width:100%">
      <header class="xm-page-head"><h1>网址导航</h1><p>点击左侧二级分类后，再展开对应三级分类。</p></header>
      <div class="xm-page-body">
        <div class="xm-nav-grid xm-filter-content">
          {% for item in site.data.site_links %}
          <a class="xm-nav-item xm-filter-item" data-group="{{ item.group }}" data-subgroup="{{ item.subgroup }}" data-search="{{ item.title }} {{ item.description }}" href="{{ item.url }}" target="_blank" rel="noopener">
            <h3>{{ item.title }}</h3><p>{{ item.description }}</p>
          </a>
          {% endfor %}
        </div>
      </div>
    </section>
  </main>

  {% include global-rightbar.html %}
  {% include tree-filter-script.html %}
</div>
