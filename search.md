---
layout: default
title: 文章搜索
permalink: /search/
nav_key: project
---

<style>
.search-page{width:min(1180px,calc(100% - 36px));margin:0 auto}.search-panel{background:#fff;box-shadow:0 2px 14px rgba(0,0,0,.07)}.search-head{padding:24px 28px;border-bottom:1px solid #eceeef}.search-head h1{margin:0;font-size:30px}.search-head p{margin:6px 0 0;color:#858d95;font-size:14px}.search-summary{padding:14px 28px;background:#f7f8f9;color:#707880;font-size:14px}.search-results{display:grid}.search-result{padding:22px 28px;border-bottom:1px solid #eceeef}.search-result:last-child{border-bottom:0}.search-result h2{margin:0 0 6px;font-size:22px}.search-result h2 a:hover{color:#2990df}.search-result-meta{display:flex;flex-wrap:wrap;gap:8px;color:#969da4;font-size:12px}.search-result p{margin:10px 0 0;color:#5e6770;font-size:14px;line-height:1.8}.search-empty{display:none;padding:42px 28px;text-align:center;color:#8d959c}.search-empty.show{display:block}
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
      <article class="search-result" data-search="{{ post.title | escape }} {{ post.content | strip_html | strip_newlines | escape }} {{ post.tags | join: ' ' | escape }} {{ post.categories | join: ' ' | escape }} {{ post.subcategory | default: '' | escape }}">
        <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
        <div class="search-result-meta">
          <time>{{ post.date | date: "%Y-%m-%d" }}</time>
          {% if post.categories and post.categories.size > 0 %}<span>{{ post.categories | join: " / " }}</span>{% endif %}
          {% if post.subcategory %}<span>{{ post.subcategory }}</span>{% endif %}
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
  var q=(params.get('q')||'').trim().toLowerCase();
  var items=[].slice.call(document.querySelectorAll('.search-result'));
  var summary=document.getElementById('search-summary');
  var empty=document.getElementById('search-empty');
  if(!q){items.forEach(function(x){x.style.display='none';});summary.textContent='请输入关键词后搜索。';return;}
  var shown=0;
  items.forEach(function(item){
    var hay=(item.dataset.search||'').toLowerCase();
    var ok=hay.indexOf(q)>-1;
    item.style.display=ok?'':'none';
    if(ok)shown++;
  });
  summary.textContent='关键词“'+(params.get('q')||'')+'”，找到 '+shown+' 篇文章。';
  if(empty)empty.classList.toggle('show',shown===0);
})();
</script>
