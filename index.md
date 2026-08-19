---
layout: default
title: 项目
nav_key: project
---

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
        <a href="{{ '/gallery/' | relative_url }}"><b>图片收藏</b><span>学习图、截图、灵感</span></a>
        <a href="{{ '/videos/' | relative_url }}"><b>视频收藏</b><span>教程、演示、项目视频</span></a>
        <a href="{{ '/nav/' | relative_url }}"><b>网址导航</b><span>常用网站与工具</span></a>
        <a href="{{ '/music/' | relative_url }}"><b>歌曲分类</b><span>个人音乐收藏</span></a>
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
  var activeFilter='all';
  var visibleSlides=[];
  var current=0;
  var timer=null;

  function rebuildSlides(){
    visibleSlides=allSlides.filter(function(slide){
      return slide.getAttribute('data-slide-category')===activeFilter;
    });
    allSlides.forEach(function(slide){slide.classList.remove('active');});
    if(dots) dots.innerHTML='';
    current=0;
    if(!visibleSlides.length) return;
    visibleSlides.forEach(function(_,i){
      var b=document.createElement('button');
      b.type='button';
      b.setAttribute('aria-label','切换到第 '+(i+1)+' 张');
      b.addEventListener('click',function(){showSlide(i);restart();});
      dots.appendChild(b);
    });
    showSlide(0);
    restart();
  }

  function showSlide(i){
    if(!visibleSlides.length) return;
    current=(i+visibleSlides.length)%visibleSlides.length;
    visibleSlides.forEach(function(slide,j){slide.classList.toggle('active',j===current);});
    if(dots){[].slice.call(dots.children).forEach(function(d,j){d.classList.toggle('active',j===current);});}
  }

  function restart(){
    clearInterval(timer);
    if(visibleSlides.length>1){timer=setInterval(function(){showSlide(current+1);},5000);}
  }

  function applyPosts(){
    var q=(search && search.value || '').trim().toLowerCase();
    cards.forEach(function(card){
      var cat=card.getAttribute('data-category')||'';
      var text=(card.getAttribute('data-search')||'').toLowerCase();
      var okFilter=activeFilter==='all'||cat===activeFilter;
      var okSearch=!q||text.indexOf(q)>-1;
      var show=okFilter&&okSearch;
      card.classList.toggle('hidden',!show);
      if(show){card.classList.remove('animate-in');void card.offsetWidth;card.classList.add('animate-in');}
    });
  }

  buttons.forEach(function(btn){
    btn.addEventListener('click',function(){
      buttons.forEach(function(b){b.classList.remove('active');});
      btn.classList.add('active');
      activeFilter=btn.getAttribute('data-filter');
      applyPosts();
      rebuildSlides();
    });
  });

  if(prev) prev.addEventListener('click',function(){showSlide(current-1);restart();});
  if(next) next.addEventListener('click',function(){showSlide(current+1);restart();});
  if(search) search.addEventListener('input',applyPosts);

  rebuildSlides();
})();
</script>
