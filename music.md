---
layout: default
title: 歌曲分类
permalink: /music/
nav_key: music
---

<div class="xm-home-grid xm-module-grid" data-module="music">
  <aside class="xm-left-menu">
    {% for item in site.data.module_menus.music %}
    <button class="xm-filter-btn{% if forloop.first %} active{% endif %}" data-group="{{ item.key }}">{{ item.label }}</button>
    {% if item.children %}{% for child in item.children %}<button class="xm-filter-btn xm-filter-child" data-group="{{ item.key }}" data-subgroup="{{ child.key }}">└ {{ child.label }}</button>{% endfor %}{% endif %}
    {% endfor %}
  </aside>

  <main class="xm-center">
    <section class="xm-page" style="width:100%">
      <header class="xm-page-head"><h1>歌曲分类</h1><p>支持正版平台链接，也支持本地音频文件。</p></header>
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
</div>

<script>
(function(){var root=document.querySelector('[data-module="music"]');if(!root)return;var bs=[].slice.call(root.querySelectorAll('.xm-filter-btn')),items=[].slice.call(root.querySelectorAll('.xm-filter-item')),search=document.getElementById('xm-search-input'),g='all',s='';function apply(){var q=(search&&search.value||'').toLowerCase();items.forEach(function(x){x.style.display=((g==='all'||x.dataset.group===g)&&(!s||x.dataset.subgroup===s)&&(!q||(x.dataset.search||'').toLowerCase().indexOf(q)>-1))?'':'none';});}bs.forEach(function(b){b.onclick=function(){bs.forEach(function(x){x.classList.remove('active');});b.classList.add('active');g=b.dataset.group;s=b.dataset.subgroup||'';apply();};});if(search)search.oninput=apply;apply();})();
</script>
