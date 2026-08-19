---
layout: default
title: 视频收藏
permalink: /videos/
module_key: videos
---

<div class="xm-home-grid xm-module-grid" data-module="videos">
  <aside class="xm-left-menu">
    {% for item in site.data.module_menus.videos %}
    <button class="xm-filter-btn{% if forloop.first %} active{% endif %}" data-group="{{ item.key }}">{{ item.label }}</button>
    {% if item.children %}{% for child in item.children %}<button class="xm-filter-btn xm-filter-child" data-group="{{ item.key }}" data-subgroup="{{ child.key }}">└ {{ child.label }}</button>{% endfor %}{% endif %}
    {% endfor %}
  </aside>

  <main class="xm-center">
    <section class="xm-page" style="width:100%">
      <header class="xm-page-head"><h1>视频收藏</h1><p>动画剪辑、教程、项目演示与个人收藏。</p></header>
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
</div>

<script>
(function(){var root=document.querySelector('[data-module="videos"]');if(!root)return;var bs=[].slice.call(root.querySelectorAll('.xm-filter-btn')),items=[].slice.call(root.querySelectorAll('.xm-filter-item')),search=document.getElementById('xm-search-input'),g='all',s='';function apply(){var q=(search&&search.value||'').toLowerCase();items.forEach(function(x){x.style.display=((g==='all'||x.dataset.group===g)&&(!s||x.dataset.subgroup===s)&&(!q||(x.dataset.search||'').toLowerCase().indexOf(q)>-1))?'':'none';});}bs.forEach(function(b){b.onclick=function(){bs.forEach(function(x){x.classList.remove('active');});b.classList.add('active');g=b.dataset.group;s=b.dataset.subgroup||'';apply();};});if(search)search.oninput=apply;apply();})();
</script>
