---
layout: default
title: 视频收藏
permalink: /videos/
module_key: videos
---

<style>
.video-lite{
  position:relative;
  width:100%;
  aspect-ratio:16/9;
  margin-bottom:10px;
  overflow:hidden;
  background:#e9edf1;
  border:1px solid #e2e6ea;
  cursor:pointer;
  isolation:isolate;
}
.video-lite-bg{
  position:absolute;
  inset:0;
  background-size:cover;
  background-position:center;
  transform:scale(1.01);
  transition:transform .25s ease,filter .25s ease;
}
.video-lite:hover .video-lite-bg{transform:scale(1.035)}
.video-lite-mask{position:absolute;inset:0;background:linear-gradient(to bottom,rgba(12,18,28,.05),rgba(12,18,28,.28))}
.video-lite-inner{position:absolute;inset:0;z-index:2;display:flex;align-items:center;justify-content:center}
.video-lite-play{display:flex;align-items:center;justify-content:center;width:60px;height:60px;border-radius:50%;background:rgba(255,255,255,.94);box-shadow:0 6px 20px rgba(0,0,0,.18);font-size:25px;color:#e14f43;padding-left:3px}
.video-lite-loading{position:absolute;inset:0;z-index:4;display:none;align-items:center;justify-content:center;flex-direction:column;gap:10px;background:rgba(238,242,246,.86);backdrop-filter:blur(2px);color:#66717b;font-size:13px}
.video-lite.loading .video-lite-loading{display:flex}
.video-lite-spinner{width:30px;height:30px;border:3px solid #d7dde3;border-top-color:#2990df;border-radius:50%;animation:videoSpin .8s linear infinite}
.video-lite iframe{position:absolute;inset:0;z-index:5;width:100%;height:100%;border:0;background:transparent;opacity:0;transition:opacity .18s ease}
.video-lite.ready iframe{opacity:1}
.video-lite.ready .video-lite-bg,.video-lite.ready .video-lite-mask,.video-lite.ready .video-lite-inner,.video-lite.ready .video-lite-loading{display:none}
.xm-media-item{content-visibility:auto;contain-intrinsic-size:350px}
@keyframes videoSpin{to{transform:rotate(360deg)}}
</style>

{% assign menu_doc = site.menu_defs | where: 'module_key', 'videos' | first %}
<div class="xm-home-grid xm-module-grid" data-module="videos">
  <aside class="xm-left-menu">
    {% include collapsible-menu.html menu=menu_doc.items %}
  </aside>

  <main class="xm-center">
    {% include module-filter.html placeholder='筛选当前视频' %}
    <section class="xm-page" style="width:100%">
      <header class="xm-page-head"><h1>视频收藏</h1><p>点击封面后再加载对应播放器，首屏不预加载视频。</p></header>
      <div class="xm-page-body"><div class="xm-media-grid">
        {% for item in site.data.videos %}
        <article class="xm-media-item xm-filter-item" data-group="{{ item.group }}" data-subgroup="{{ item.subgroup }}" data-search="{{ item.title }} {{ item.description }}">
          {% if item.platform == 'bilibili' and item.bvid %}
          <div class="video-lite" data-bvid="{{ item.bvid }}" role="button" tabindex="0" aria-label="播放 {{ item.title }}">
            <div class="video-lite-bg" style="background-image:url('{{ item.cover }}')"></div>
            <div class="video-lite-mask"></div>
            <div class="video-lite-inner"><div class="video-lite-play">▶</div></div>
            <div class="video-lite-loading"><div class="video-lite-spinner"></div><div>正在加载播放器…</div></div>
          </div>
          {% elsif item.video and item.video != '' %}
          <video controls preload="none"{% if item.poster and item.poster != '' %} poster="{{ item.poster }}"{% endif %}><source src="{{ item.video }}"></video>
          {% endif %}
          <h3>{{ item.title }}</h3><p>{{ item.description }}</p>
          {% if item.url %}<p style="margin-top:8px"><a href="{{ item.url }}" target="_blank" rel="noopener" style="color:#2990df">在原网站打开 →</a></p>{% endif %}
        </article>
        {% endfor %}
      </div></div>
    </section>
  </main>

  {% include global-rightbar.html %}
  {% include tree-filter-script.html %}
</div>

<script>
(function(){
  function loadVideo(box){
    if(!box || box.dataset.loaded==='1')return;
    box.dataset.loaded='1';
    box.classList.add('loading');

    var bvid=box.dataset.bvid;
    var iframe=document.createElement('iframe');
    iframe.src='https://player.bilibili.com/player.html?bvid='+encodeURIComponent(bvid)+'&page=1&high_quality=1&danmaku=0';
    iframe.allowFullscreen=true;
    iframe.scrolling='no';
    iframe.loading='eager';
    iframe.title='Bilibili video player';

    iframe.addEventListener('load',function(){
      box.classList.remove('loading');
      box.classList.add('ready');
    });

    setTimeout(function(){
      if(!box.classList.contains('ready')){
        var tip=box.querySelector('.video-lite-loading div:last-child');
        if(tip)tip.textContent='加载较慢，可点击下方链接去原站播放';
      }
    },8000);

    box.appendChild(iframe);
  }

  document.querySelectorAll('.video-lite').forEach(function(box){
    box.addEventListener('click',function(){loadVideo(box)});
    box.addEventListener('keydown',function(e){if(e.key==='Enter'||e.key===' '){e.preventDefault();loadVideo(box)}});
  });
})();
</script>
