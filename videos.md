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
  background:linear-gradient(135deg,#eef1f4,#f7f8f9);
  border:1px solid #e5e8eb;
  cursor:pointer;
}
.video-lite-inner{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:10px;color:#66717b;text-align:center;padding:18px}
.video-lite-play{display:flex;align-items:center;justify-content:center;width:58px;height:58px;border-radius:50%;background:#fff;box-shadow:0 5px 20px rgba(0,0,0,.12);font-size:23px;color:#e14f43;padding-left:3px}
.video-lite-title{font-size:14px;font-weight:700;color:#4c535a}.video-lite-tip{font-size:12px;color:#929aa1}
.video-lite.loading .video-lite-tip::after{content:' · 正在加载播放器…'}
.video-lite iframe{position:absolute;inset:0;width:100%;height:100%;border:0;background:#fff}
.xm-media-item{content-visibility:auto;contain-intrinsic-size:350px}
</style>

{% assign menu_doc = site.menu_defs | where: 'module_key', 'videos' | first %}
<div class="xm-home-grid xm-module-grid" data-module="videos">
  <aside class="xm-left-menu">
    {% include collapsible-menu.html menu=menu_doc.items %}
  </aside>

  <main class="xm-center">
    {% include module-filter.html placeholder='筛选当前视频' %}
    <section class="xm-page" style="width:100%">
      <header class="xm-page-head"><h1>视频收藏</h1><p>默认不加载播放器，点击播放卡片后才加载对应视频，减少首屏等待。</p></header>
      <div class="xm-page-body"><div class="xm-media-grid">
        {% for item in site.data.videos %}
        <article class="xm-media-item xm-filter-item" data-group="{{ item.group }}" data-subgroup="{{ item.subgroup }}" data-search="{{ item.title }} {{ item.description }}">
          {% if item.platform == 'bilibili' and item.bvid %}
          <div class="video-lite" data-bvid="{{ item.bvid }}" role="button" tabindex="0" aria-label="播放 {{ item.title }}">
            <div class="video-lite-inner">
              <div class="video-lite-play">▶</div>
              <div class="video-lite-title">{{ item.title }}</div>
              <div class="video-lite-tip">点击后加载 B 站播放器</div>
            </div>
          </div>
          {% elsif item.video and item.video != '' %}
          <video controls preload="metadata"{% if item.poster and item.poster != '' %} poster="{{ item.poster }}"{% endif %}><source src="{{ item.video }}"></video>
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
    iframe.loading='lazy';
    iframe.title='Bilibili video player';
    box.innerHTML='';
    box.appendChild(iframe);
  }
  document.querySelectorAll('.video-lite').forEach(function(box){
    box.addEventListener('click',function(){loadVideo(box)});
    box.addEventListener('keydown',function(e){if(e.key==='Enter'||e.key===' '){e.preventDefault();loadVideo(box)}});
  });
})();
</script>
