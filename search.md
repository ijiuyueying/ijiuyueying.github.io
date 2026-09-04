---
layout: default
title: 文章搜索
permalink: /search/
nav_key: project
---

{% assign project_menu_doc = site.menu_defs | where: 'module_key', 'project' | first %}

<style>
/* 搜索页：配色全部走 --xm-* 变量 */
.search-page{width:min(1120px,calc(100% - 40px));margin:0 auto}
.search-panel{
  background:var(--xm-surface);border:1px solid var(--xm-border);
  border-radius:var(--xm-radius);box-shadow:var(--xm-shadow-sm);overflow:hidden;
}
.search-head{
  padding:26px 30px;border-bottom:1px solid var(--xm-border);
  background:var(--xm-surface-soft);
}
.search-head h1{margin:0;font-size:26px;font-weight:800;color:var(--xm-ink)}
.search-head p{margin:6px 0 0;color:var(--xm-muted);font-size:13.5px}
.search-summary{
  padding:14px 30px;background:var(--xm-surface-alt);
  color:var(--xm-muted);font-size:13.5px;
}
.search-results{display:grid}
.search-result{
  padding:22px 30px;border-bottom:1px solid var(--xm-border-soft);
  transition:background-color .2s var(--xm-ease);
}
.search-result:last-child{border-bottom:0}
.search-result:hover{background:var(--xm-surface-soft)}
.search-result h2{margin:0 0 6px;font-size:19px;font-weight:700;color:var(--xm-ink)}
.search-result h2 a:hover{color:var(--xm-accent)}
.search-result-meta{display:flex;flex-wrap:wrap;gap:8px;color:var(--xm-faint);font-size:12px}
.search-result p{margin:10px 0 0;color:var(--xm-muted);font-size:14px;line-height:1.8}
.search-empty{display:none;padding:46px 28px;text-align:center;color:var(--xm-faint)}
.search-empty.show{display:block}
</style>

<div class="search-page">
  <section class="search-panel">
    <header class="search-head">
      <h1>文章全文搜索</h1>
      <p>搜索文章标题、正文内容、标签、二级分类和三级分类。</p>
    </header>
    <div class="search-summary" id="search-summary">请输入关键词。</div>
    <div class="search-results" id="search-results">
      {% for post in site.posts %}
        {% assign category_key = post.categories | first %}
        {% assign category_item = project_menu_doc.items | where: 'key', category_key | first %}
        {% assign subcategory_item = nil %}
        {% if category_item and post.subcategory %}{% assign subcategory_item = category_item.children | where: 'key', post.subcategory | first %}{% endif %}
      <article class="search-result" data-search="{{ post.title | escape }} {{ post.content | strip_html | strip_newlines | escape }} {{ post.tags | join: ' ' | escape }} {{ category_key | escape }} {{ category_item.label | default: '' | escape }} {{ post.subcategory | default: '' | escape }} {{ subcategory_item.label | default: '' | escape }}">
        <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
        <div class="search-result-meta">
          <time>{{ post.date | date: "%Y-%m-%d" }}</time>
          {% if category_item %}<span>{{ category_item.label }}</span>{% elsif category_key %}<span>{{ category_key }}</span>{% endif %}
          {% if subcategory_item %}<span>{{ subcategory_item.label }}</span>{% elsif post.subcategory %}<span>{{ post.subcategory }}</span>{% endif %}
          {% if post.tags and post.tags.size > 0 %}<span>{{ post.tags | join: " · " }}</span>{% endif %}
        </div>
        <p>{{ post.content | strip_html | strip_newlines | truncate: 180 }}</p>
      </article>
      {% endfor %}
    </div>
    <div class="search-empty" id="search-empty">没有找到匹配的文章。</div>
  </section>
</div>

<script>
(function(){
  var params=new URLSearchParams(window.location.search);
  var raw=params.get('q')||'';
  var q=raw.trim().toLowerCase();
  var items=[].slice.call(document.querySelectorAll('.search-result'));
  var summary=document.getElementById('search-summary');
  var empty=document.getElementById('search-empty');
  if(!q){items.forEach(function(x){x.style.display='none';});summary.textContent='请输入关键词后搜索。';return;}
  var shown=0;
  items.forEach(function(item){var ok=(item.dataset.search||'').toLowerCase().indexOf(q)>-1;item.style.display=ok?'':'none';if(ok)shown++;});
  summary.textContent='关键词“'+raw+'”，找到 '+shown+' 篇文章。';
  if(empty)empty.classList.toggle('show',shown===0);
})();
</script>
