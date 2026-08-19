---
layout: default
title: 图片收藏
permalink: /gallery/
module_key: gallery
---

<div class="xm-home-grid xm-module-grid" data-module="gallery">
  <aside class="xm-left-menu">
    {% for item in site.data.module_menus.gallery %}
    <button class="xm-filter-btn{% if forloop.first %} active{% endif %}" data-group="{{ item.key }}">{{ item.label }}</button>
    {% if item.children %}{% for child in item.children %}<button class="xm-filter-btn xm-filter-child" data-group="{{ item.key }}" data-subgroup="{{ child.key }}">└ {{ child.label }}</button>{% endfor %}{% endif %}
    {% endfor %}
  </aside>

  <main class="xm-center">
    <section class="xm-page" style="width:100%">
      <header class="xm-page-head"><h1>图片收藏</h1><p>游戏壁纸、截图、思维导图和灵感图片。</p></header>
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
</div>

<script>
(function(){var root=document.querySelector('[data-module="gallery"]');if(!root)return;var bs=[].slice.call(root.querySelectorAll('.xm-filter-btn')),items=[].slice.call(root.querySelectorAll('.xm-filter-item')),search=document.getElementById('xm-search-input'),g='all',s='';function apply(){var q=(search&&search.value||'').toLowerCase();items.forEach(function(x){x.style.display=((g==='all'||x.dataset.group===g)&&(!s||x.dataset.subgroup===s)&&(!q||(x.dataset.search||'').toLowerCase().indexOf(q)>-1))?'':'none';});}bs.forEach(function(b){b.onclick=function(){bs.forEach(function(x){x.classList.remove('active');});b.classList.add('active');g=b.dataset.group;s=b.dataset.subgroup||'';apply();};});if(search)search.oninput=apply;apply();})();
</script>
