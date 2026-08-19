---
layout: default
title: 网址导航
permalink: /nav/
nav_key: nav
---

<div class="xm-home-grid xm-module-grid" data-module="nav">
  <aside class="xm-left-menu">
    {% for item in site.data.module_menus.nav %}
    <button class="xm-filter-btn{% if forloop.first %} active{% endif %}" data-group="{{ item.key }}">{{ item.label }}</button>
    {% if item.children %}{% for child in item.children %}<button class="xm-filter-btn xm-filter-child" data-group="{{ item.key }}" data-subgroup="{{ child.key }}">└ {{ child.label }}</button>{% endfor %}{% endif %}
    {% endfor %}
  </aside>

  <main class="xm-center">
    <section class="xm-page" style="width:100%">
      <header class="xm-page-head"><h1>网址导航</h1><p>按二级、三级分类整理常用网站与工具。</p></header>
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
</div>

<script>
(function(){var root=document.querySelector('[data-module="nav"]');if(!root)return;var bs=[].slice.call(root.querySelectorAll('.xm-filter-btn')),items=[].slice.call(root.querySelectorAll('.xm-filter-item')),search=document.getElementById('xm-search-input'),g='all',s='';function apply(){var q=(search&&search.value||'').toLowerCase();items.forEach(function(x){var ok=(g==='all'||x.dataset.group===g)&&(!s||x.dataset.subgroup===s)&&(!q||(x.dataset.search||'').toLowerCase().indexOf(q)>-1);x.style.display=ok?'':'none';});}bs.forEach(function(b){b.onclick=function(){bs.forEach(function(x){x.classList.remove('active');});b.classList.add('active');g=b.dataset.group;s=b.dataset.subgroup||'';apply();};});if(search)search.oninput=apply;apply();})();
</script>
