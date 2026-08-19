---
layout: default
title: 项目
nav_key: project
---

<style>
.xm-hero-arrow{position:absolute;top:50%;z-index:8;width:42px;height:64px;border:0;background:rgba(0,0,0,.25);color:#fff;font-size:40px;line-height:1;cursor:pointer;opacity:0;transform:translateY(-50%);transition:.2s}.xm-hero:hover .xm-hero-arrow{opacity:1}.xm-hero-arrow:hover{background:rgba(0,0,0,.48)}.xm-hero-arrow.prev{left:0}.xm-hero-arrow.next{right:0}.xm-filter-btn.active{position:relative}.xm-filter-btn.active:before{content:"";position:absolute;left:0;top:0;bottom:0;width:3px;background:#e14f43}.xm-category-empty{display:none;padding:34px 28px;background:#fff;color:#888;text-align:center;box-shadow:0 2px 12px rgba(0,0,0,.07)}.xm-category-empty.show{display:block;animation:xmFade .32s ease both}.xm-slide-copy{z-index:3}.xm-slide img{position:absolute;inset:0}.xm-slide-overlay{z-index:2}.xm-dots{z-index:8}@media(max-width:760px){.xm-hero-arrow{opacity:.75;width:34px;height:52px;font-size:30px}}
</style>

<div class="xm-home-grid">
  <aside class="xm-left-menu">
    {% for item in site.data.project_categories %}
    <button class="xm-filter-btn{% if forloop.first %} active{% endif %}" data-filter="{{ item.key }}">{{ item.label }}</button>
    {% endfor %}
  </aside>

  <main class="xm-center">
    <section class="xm-hero" id="xm-hero">
      {% for category in site.data.project_categories %}
        {% for slide in category.slides %}
        <a class="xm-slide{% if category.key == 'all' and forloop.first %} active{% endif %}" data-slide-category="{{ category.key }}" href="{{ slide.url | relative_url }}">
          <img src="{{ slide.image }}" alt="{{ slide.title }}">
          <div class="xm-slide-overlay"></div>
          <div class="xm-slide-copy">
            <span>{{ category.label }}</span>
            <h2>{{ slide.title }}</h2>
            <p>{{ slide.text }}</p>
          </div>
        </a>
        {% endfor %}
      {% endfor %}

      <button class="xm-hero-arrow prev" id="xm-prev" type="button" aria-label="上一张">‹</button>
      <button class="xm-hero-arrow next" id="xm-next" type="button" aria-label="下一张">›</button>
      <div class="xm-dots" id="xm-dots"></div>
    </section>

    <section class="xm-post-list" id="xm-post-list">
      {% for post in site.posts %}
      <article class="xm-post-card" data-category="{{ post.categories | first }}" data-search="{{ post.title | escape }} {{ post.excerpt | strip_html | strip_newlines | escape }}">
        {% if post.cover %}
        <a class="xm-post-cover" href="{{ post.url | relative_url }}"><img src="{{ post.cover | relative_url }}" alt="{{ post.title }}"></a>
        {% endif %}
        <div class="xm-post-content">
          <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
          <div class="xm-meta">{{ post.date | date: "%Y-%m-%d %H:%M" }}</div>
          <p>{% if post.excerpt %}{{ post.excerpt | strip_html | strip_newlines | truncate: 150 }}{% else %}点击查看完整内容。{% endif %}</p>
          {% if post.tags and post.tags.size > 0 %}
          <div class="xm-tags">{% for tag in post.tags limit:4 %}<span>{{ tag }}</span>{% endfor %}</div>
          {% endif %}
        </div>
      </article>
      {% endfor %}
    </section>
    <div class="xm-category-empty" id="xm-category-empty">这个分类暂时还没有文章，轮播主题图仍然可以正常切换。</div>
  </main>

  <aside class="xm-rightbar">
    <section class="xm-side-card">
      <div class="xm-side-title">好文推荐</div>
      <div class="xm-recommend-list">
        {% for post in site.posts limit:10 %}
        <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
        {% endfor %}
      </div>
    </section>

    <section class="xm-side-card">
      <div class="xm-side-title">个人收藏</div>
      <div class="xm-collection-grid">
        {% for item in site.data.collections %}
        <a href="{{ item.url | relative_url }}">
          <b>{% if item.icon and item.icon != '' %}<span style="margin-right:5px">{{ item.icon }}</span>{% endif %}{{ item.title }}</b>
          <span>{{ item.description }}</span>
        </a>
        {% endfor %}
      </div>
    </section>
  </aside>
</div>

<script>
(function(){
  var buttons=[].slice.call(document.querySelectorAll('.xm-filter-btn'));
  var cards=[].slice.call(document.querySelectorAll('.xm-post-card'));
  var allSlides=[].slice.call(document.querySelectorAll('.xm-slide'));
  var dots=document.getElementById('xm-dots');
  var prev=document.getElementById('xm-prev');
  var next=document.getElementById('xm-next');
  var search=document.getElementById('xm-search-input');
  var empty=document.getElementById('xm-category-empty');
  var activeFilter='all';
  var visibleSlides=[];
  var current=0;
  var timer=null;

  function rebuildSlides(){
    visibleSlides=allSlides.filter(function(slide){return slide.getAttribute('data-slide-category')===activeFilter;});
    allSlides.forEach(function(slide){slide.classList.remove('active');});
    if(dots) dots.innerHTML='';
    current=0;
    if(!visibleSlides.length)return;
    visibleSlides.forEach(function(_,i){
      var b=document.createElement('button');b.type='button';b.setAttribute('aria-label','切换到第 '+(i+1)+' 张');
      b.addEventListener('click',function(e){e.preventDefault();showSlide(i);restart();});dots.appendChild(b);
    });
    showSlide(0);restart();
  }

  function showSlide(i){
    if(!visibleSlides.length)return;
    current=(i+visibleSlides.length)%visibleSlides.length;
    visibleSlides.forEach(function(slide,j){slide.classList.toggle('active',j===current);});
    if(dots){[].slice.call(dots.children).forEach(function(d,j){d.classList.toggle('active',j===current);});}
  }

  function restart(){clearInterval(timer);if(visibleSlides.length>1){timer=setInterval(function(){showSlide(current+1);},5000);}}

  function applyPosts(){
    var q=(search&&search.value||'').trim().toLowerCase();
    var shown=0;
    cards.forEach(function(card){
      var cat=card.getAttribute('data-category')||'';var text=(card.getAttribute('data-search')||'').toLowerCase();
      var show=(activeFilter==='all'||cat===activeFilter)&&(!q||text.indexOf(q)>-1);
      card.classList.toggle('hidden',!show);
      if(show){shown++;card.classList.remove('animate-in');void card.offsetWidth;card.classList.add('animate-in');}
    });
    if(empty)empty.classList.toggle('show',shown===0);
  }

  buttons.forEach(function(btn){btn.addEventListener('click',function(){
    buttons.forEach(function(b){b.classList.remove('active');});btn.classList.add('active');
    activeFilter=btn.getAttribute('data-filter');applyPosts();rebuildSlides();
  });});
  if(prev)prev.addEventListener('click',function(e){e.preventDefault();showSlide(current-1);restart();});
  if(next)next.addEventListener('click',function(e){e.preventDefault();showSlide(current+1);restart();});
  if(search)search.addEventListener('input',applyPosts);
  applyPosts();rebuildSlides();
})();
</script>
