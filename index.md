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
      {% assign hero_posts = site.posts | slice: 0, 3 %}
      {% for post in hero_posts %}
      <a class="xm-slide{% if forloop.first %} active{% endif %}" href="{{ post.url | relative_url }}">
        {% if post.cover %}<img src="{{ post.cover | relative_url }}" alt="{{ post.title }}">{% endif %}
        <div class="xm-slide-overlay"></div>
        <div class="xm-slide-copy">
          <span>{{ post.categories | first | default: '项目笔记' }}</span>
          <h2>{{ post.title }}</h2>
          <p>{{ post.excerpt | strip_html | strip_newlines | truncate: 80 }}</p>
        </div>
      </a>
      {% endfor %}
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
  var search=document.getElementById('xm-search-input');
  var activeFilter='all';

  function apply(){
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
      apply();
    });
  });
  if(search) search.addEventListener('input',apply);

  var slides=[].slice.call(document.querySelectorAll('.xm-slide'));
  var dots=document.getElementById('xm-dots');
  var current=0,timer;
  function show(i){
    if(!slides.length)return;
    current=(i+slides.length)%slides.length;
    slides.forEach(function(s,j){s.classList.toggle('active',j===current);});
    if(dots){[].slice.call(dots.children).forEach(function(d,j){d.classList.toggle('active',j===current);});}
  }
  if(dots&&slides.length){
    slides.forEach(function(_,i){var b=document.createElement('button');b.type='button';b.addEventListener('click',function(){show(i);restart();});dots.appendChild(b);});
    show(0);
    function restart(){clearInterval(timer);timer=setInterval(function(){show(current+1);},5000);}restart();
  }
})();
</script>
