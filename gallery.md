---
layout: default
title: 图片收藏
permalink: /gallery/
module_key: gallery
---

<style>
.gallery-image-link{
  position:relative;
  display:block;
  min-height:180px;
  margin-bottom:10px;
  overflow:hidden;
  background:#eef1f4;
  border:1px solid #e5e8eb;
}
.gallery-image-link::before{
  content:"图片加载中…";
  position:absolute;
  inset:0;
  display:flex;
  align-items:center;
  justify-content:center;
  color:#9aa2aa;
  font-size:13px;
  background:linear-gradient(100deg,#eef1f4 20%,#f7f8f9 40%,#eef1f4 60%);
  background-size:200% 100%;
  animation:gallerySkeleton 1.35s linear infinite;
}
.gallery-image-link.loaded::before{display:none}
.gallery-image-link img{
  position:relative;
  z-index:1;
  display:block;
  width:100%;
  max-height:420px;
  object-fit:contain;
  opacity:0;
  background:#fff;
  transition:opacity .22s ease;
}
.gallery-image-link.loaded img{opacity:1}
.xm-media-item{content-visibility:auto;contain-intrinsic-size:320px}
@keyframes gallerySkeleton{from{background-position:200% 0}to{background-position:-200% 0}}
</style>

{% assign menu_doc = site.menu_defs | where: 'module_key', 'gallery' | first %}
<div class="xm-home-grid xm-module-grid" data-module="gallery">
  <aside class="xm-left-menu">
    {% include collapsible-menu.html menu=menu_doc.items %}
  </aside>

  <main class="xm-center">
    {% include module-filter.html placeholder='筛选当前图片' %}
    <section class="xm-page" style="width:100%">
      <header class="xm-page-head"><h1>图片收藏</h1><p>左侧负责图片分类；流程图点击后可查看原尺寸。</p></header>
      <div class="xm-page-body"><div class="xm-media-grid">
        {% for item in site.data.gallery %}
        <article class="xm-media-item xm-filter-item" data-group="{{ item.group }}" data-subgroup="{{ item.subgroup }}" data-search="{{ item.title }} {{ item.description }}">
          {% if item.image and item.image != '' %}
          <a href="{{ item.image }}" target="_blank" rel="noopener" class="gallery-image-link">
            <img src="{{ item.image }}" alt="{{ item.title }}" loading="lazy" decoding="async" fetchpriority="low" onload="this.parentElement.classList.add('loaded')" onerror="this.parentElement.style.display='none';this.parentElement.nextElementSibling.style.display='flex'">
          </a>
          <div class="gallery-missing" style="display:none;min-height:150px;align-items:center;justify-content:center;background:#f5f6f7;color:#8a9198;padding:18px;text-align:center">图片暂时无法加载，请稍后重试或检查本地图片是否已发布。</div>
          {% endif %}
          <h3>{{ item.title }}</h3><p>{{ item.description }}</p>
          {% if item.source %}<p style="margin-top:8px"><a href="{{ item.source }}" target="_blank" rel="noopener" style="color:#2990df">查看来源 →</a></p>{% endif %}
        </article>
        {% endfor %}
      </div></div>
    </section>
  </main>

  {% include global-rightbar.html %}
  {% include tree-filter-script.html %}
</div>
