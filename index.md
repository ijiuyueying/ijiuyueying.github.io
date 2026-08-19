---
layout: default
title: 项目
nav_key: project
---

{% assign menu_doc = site.menu_defs | where: 'module_key', 'project' | first %}
<style>
.xm-hero-arrow{position:absolute;top:50%;z-index:8;width:42px;height:64px;border:0;background:rgba(0,0,0,.25);color:#fff;font-size:40px;line-height:1;cursor:pointer;opacity:0;transform:translateY(-50%);transition:.2s}.xm-hero:hover .xm-hero-arrow{opacity:1}.xm-hero-arrow:hover{background:rgba(0,0,0,.48)}.xm-hero-arrow.prev{left:0}.xm-hero-arrow.next{right:0}.xm-category-empty{display:none;padding:34px 28px;background:#fff;color:#888;text-align:center;box-shadow:0 2px 12px rgba(0,0,0,.07)}.xm-category-empty.show{display:block;animation:xmFade .32s ease both}.xm-slide-copy{z-index:3}.xm-slide img{position:absolute;inset:0}.xm-slide-overlay{z-index:2}.xm-dots{z-index:8}@media(max-width:760px){.xm-hero-arrow{opacity:.75;width:34px;height:52px;font-size:30px}}
</style>

<div class="xm-home-grid xm-module-grid" data-module="project">
  <aside class="xm-left-menu">{% include collapsible-menu.html menu=menu_doc.items %}</aside>

  <main class="xm-center">
    {% include module-filter.html placeholder='筛选当前项目文章' %}

    <section class="xm-hero" id="xm-hero">
      {% for category in menu_doc.items %}
        {% for slide in category.slides %}
        <a class="xm-slide{% if category.key == 'all' and forloop.first %} active{% endif %}" data-slide-category="{{ category.key }}" href="{{ slide.url | relative_url }}">
          <img src="{{ slide.image }}" alt="{{ slide.title }}" decoding="async" {% if category.key == 'all' and forloop.first %}fetchpriority="high"{% else %}loading="lazy" fetchpriority="low"{% endif %}>
          <div class="xm-slide-overlay"></div>
          <div class="xm-slide-copy"><span>{{ category.label }}</span><h2>{{ slide.title }}</h2><p>{{ slide.text }}</p></div>
        </a>
        {% endfor %}
      {% endfor %}
      <button class="xm-hero-arrow prev" id="xm-prev" type="button" aria-label="上一张">‹</button>
      <button class="xm-hero-arrow next" id="xm-next" type="button" aria-label="下一张">›</button>
      <div class="xm-dots" id="xm-dots"></div>
    </section>

    <section class="xm-post-list" id="xm-post-list">
      {% for post in site.posts %}
        {% assign category_key = post.categories | first %}
        {% assign category_item = menu_doc.items | where: 'key', category_key | first %}
        {% assign subcategory_item = nil %}
        {% if category_item and post.subcategory %}{% assign subcategory_item = category_item.children | where: 'key', post.subcategory | first %}{% endif %}
      <article class="xm-post-card xm-filter-item" data-group="{{ category_key }}" data-subgroup="{{ post.subcategory | default: '' }}" data-search="{{ post.title | escape }} {{ post.excerpt | strip_html | strip_newlines | escape }} {{ post.tags | join: ' ' | escape }} {{ category_item.label | default: '' | escape }} {{ subcategory_item.label | default: '' | escape }}">
        {% if post.cover %}<a class="xm-post-cover" href="{{ post.url | relative_url }}"><img src="{{ post.cover | relative_url }}" alt="{{ post.title }}" loading="lazy" decoding="async"></a>{% endif %}
        <div class="xm-post-content">
          <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
          <div class="xm-meta">{{ post.date | date: "%Y-%m-%d %H:%M" }}{% if category_item %} · {{ category_item.label }}{% endif %}{% if subcategory_item %} · {{ subcategory_item.label }}{% endif %}</div>
          <p>{% if post.excerpt %}{{ post.excerpt | strip_html | strip_newlines | truncate: 150 }}{% else %}点击查看完整内容。{% endif %}</p>
          {% if post.tags and post.tags.size > 0 %}<div class="xm-tags">{% for tag in post.tags limit:4 %}<span>{{ tag }}</span>{% endfor %}</div>{% endif %}
        </div>
      </article>
      {% endfor %}
    </section>
    <div class="xm-category-empty" id="xm-category-empty">这个分类暂时还没有文章。</div>
  </main>

  {% include global-rightbar.html %}
</div>

<script>
(function(){
  var root=document.querySelector('[data-module="project"]');if(!root)return;
  var parents=[].slice.call(root.querySelectorAll('[data-tree-parent]'));
  var children=[].slice.call(root.querySelectorAll('[data-tree-child]'));
  var treeItems=[].slice.call(root.querySelectorAll('[data-tree-item]'));
  var cards=[].slice.call(root.querySelectorAll('.xm-post-card'));
  var allSlides=[].slice.call(root.querySelectorAll('.xm-slide'));
  var dots=document.getElementById('xm-dots'),prev=document.getElementById('xm-prev'),next=document.getElementById('xm-next'),search=root.querySelector('#xm-module-filter-input'),empty=document.getElementById('xm-category-empty');
  var params=new URLSearchParams(window.location.search);
  var group=params.get('category')||'all';
  var subgroup=params.get('subcategory')||'';
  var visibleSlides=[],current=0,timer=null;

  function applyPosts(){var q=(search&&search.value||'').trim().toLowerCase(),shown=0;cards.forEach(function(card){var okGroup=(group==='all'||card.dataset.group===group),okSub=(!subgroup||card.dataset.subgroup===subgroup),okSearch=(!q||(card.dataset.search||'').toLowerCase().indexOf(q)>-1),show=okGroup&&okSub&&okSearch;card.classList.toggle('hidden',!show);if(show){shown++;card.classList.remove('animate-in');void card.offsetWidth;card.classList.add('animate-in');}});if(empty)empty.classList.toggle('show',shown===0);}
  function showSlide(i){if(!visibleSlides.length)return;current=(i+visibleSlides.length)%visibleSlides.length;visibleSlides.forEach(function(slide,j){slide.classList.toggle('active',j===current);});if(dots)[].slice.call(dots.children).forEach(function(d,j){d.classList.toggle('active',j===current);});}
  function restart(){clearInterval(timer);if(visibleSlides.length>1)timer=setInterval(function(){showSlide(current+1);},5000);}
  function rebuildSlides(){visibleSlides=allSlides.filter(function(slide){return slide.dataset.slideCategory===group;});if(!visibleSlides.length&&group!=='all')visibleSlides=allSlides.filter(function(slide){return slide.dataset.slideCategory==='all';});allSlides.forEach(function(slide){slide.classList.remove('active');});if(dots)dots.innerHTML='';current=0;if(!visibleSlides.length)return;visibleSlides.forEach(function(_,i){var b=document.createElement('button');b.type='button';b.onclick=function(e){e.preventDefault();showSlide(i);restart();};dots.appendChild(b);});showSlide(0);restart();}
  function closeOthers(holder){treeItems.forEach(function(item){if(item!==holder)item.classList.remove('open');});}
  function clearActive(){parents.forEach(function(x){x.classList.remove('active');});children.forEach(function(x){x.classList.remove('active');});}
  function syncMenuState(){clearActive();var parent=parents.find(function(x){return (x.dataset.group||'all')===group;});if(!parent){group='all';subgroup='';parent=parents.find(function(x){return (x.dataset.group||'all')==='all';});}if(parent){var holder=parent.closest('[data-tree-item]');closeOthers(holder);parent.classList.add('active');if(holder&&holder.querySelector('.xm-tree-children'))holder.classList.add('open');}if(subgroup){var child=children.find(function(x){return x.dataset.group===group&&x.dataset.subgroup===subgroup;});if(child)child.classList.add('active');else subgroup='';}}

  parents.forEach(function(btn){btn.addEventListener('click',function(){var holder=btn.closest('[data-tree-item]'),childBox=holder&&holder.querySelector('.xm-tree-children'),wasOpen=!!(holder&&holder.classList.contains('open'));closeOthers(holder);if(holder&&childBox)holder.classList.toggle('open',!wasOpen);else if(holder)holder.classList.remove('open');clearActive();btn.classList.add('active');group=btn.dataset.group||'all';subgroup='';applyPosts();rebuildSlides();});});
  children.forEach(function(btn){btn.addEventListener('click',function(e){e.stopPropagation();var holder=btn.closest('[data-tree-item]');closeOthers(holder);if(holder)holder.classList.add('open');clearActive();var parent=holder&&holder.querySelector('[data-tree-parent]');if(parent)parent.classList.add('active');btn.classList.add('active');group=btn.dataset.group||'all';subgroup=btn.dataset.subgroup||'';applyPosts();rebuildSlides();});});
  if(prev)prev.onclick=function(e){e.preventDefault();showSlide(current-1);restart();};if(next)next.onclick=function(e){e.preventDefault();showSlide(current+1);restart();};if(search)search.addEventListener('input',applyPosts);
  syncMenuState();applyPosts();rebuildSlides();
})();
</script>
