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
  background:
    radial-gradient(circle at 72% 28%,rgba(125,104,185,.28),transparent 28%),
    radial-gradient(circle at 26% 72%,rgba(70,122,171,.26),transparent 30%),
    linear-gradient(135deg,#eef2f6 0%,#e6ebf1 52%,#f4f6f8 100%);
  border:1px solid #e2e6ea;
  cursor:pointer;
  isolation:isolate;
}
.video-lite::before{
  content:"";
  position:absolute;
  inset:0;
  background:linear-gradient(115deg,transparent 0 38%,rgba(255,255,255,.42) 49%,transparent 60%);
  transform:translateX(-100%);
  animation:videoShine 3.8s ease-in-out infinite;
  z-index:0;
}
.video-lite-inner{position:absolute;inset:0;z-index:2;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:10px;color:#66717b;text-align:center;padding:18px}
.video-lite-play{display:flex;align-items:center;justify-content:center;width:58px;height:58px;border-radius:50%;background:rgba(255,255,255,.94);box-shadow:0 5px 20px rgba(0,0,0,.12);font-size:23px;color:#e14f43;padding-left:3px}
.video-lite-title{font-size:14px;font-weight:800;color:#3f4851;text-shadow:0 1px 0 rgba(255,255,255,.8)}
.video-lite-tip{font-size:12px;color:#7d8790}
.video-lite-loading{position:absolute;inset:0;z-index:4;display:none;align-items:center;justify-content:center;flex-direction:column;gap:10px;background:linear-gradient(135deg,#eef2f6,#f7f8f9);color:#66717b;font-size:13px}
.video-lite.loading .video-lite-loading{display:flex}
.video-lite.loading .video-lite-inner{opacity:0}
.video-lite-spinner{width:30px;height:30px;border:3px solid #d7dde3;border-top-color:#2990df;border-radius:50%;animation:videoSpin .8s linear infinite}
.video-lite iframe{position:absolute;inset:0;z-index:5;width:100%;height:100%;border:0;background:transparent;opacity:0;transition:opacity .18s ease}
.video-lite.ready iframe{opacity:1}
.video-lite.ready .video-lite-loading,.video-lite.ready .video-lite-inner,.video-lite.ready::before{display:none}
.xm-media-item{content-visibility:auto;contain-intrinsic-size:350px}
@keyframes videoSpin{to{transform:rotate(360deg)}}
@keyframes videoShine{0%,60%,100%{transform:translateX(-120%)}75%{transform:translateX(120%)}}
</style>

{% assign menu_doc = site.menu_defs | where: 'module_key', 'videos' | first %}
<div class="xm-home-grid xm-module-grid" data-module="videos">
  <aside class="xm-left-menu">
    {% include collapsible-menu.html menu=menu_doc.items %}
  </aside>

  <main class="xm-center">
    {% include module-filter.html placeholder='筛选当前视频' %}
    <section class="xm-page" style="width:100%">
      <header class="xm-page-head"><h1>视频收藏</h1><p>首屏只显示轻量预览；点击某个视频后才单独加载对应播放器。</p></header>
      <div class="xm-page-body"><div class="xm-media-grid">
        {% for item in site.data.videos %}
        <article class="xm-media-item xm-filter-item" data-group="{{ item.group }}" data-subgroup="{{ item.subgroup }}" data-search="{{ item.title }} {{ item.description }}">
          {% if item.platform == 'bilibili' and item.bvid %}
          <div class="video-lite" data-bvid="{{ item.bvid }}" role="button" tabindex="0" aria-label="播放 {{ item.title }}">
            <div class="video-lite-inner">
              <div class="video-lite-play">▶</div>
              <div class="video-lite-title">{{ item.title }}</div>
              <div class="video-lite-tip">点击播放 · 未点击前不加载 B 站播放器</div>
            </div>
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
        if(tip)tip.textContent='播放器加载较慢，可使用下方“在原网站打开”';
      }
    },8000);

    box.appendChild(iframe);
  }

  document.querySelectorAll('.video-lite').forEach(function(box){
    box.addEventListener('click',function(){loadVideo(box)});
    box.addEventListener('keydown',function(e){
      if(e.key==='Enter'||e.key===' '){e.preventDefault();loadVideo(box)}
    });
  });
})();
</script>
