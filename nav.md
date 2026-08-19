---
layout: default
title: 网址导航
permalink: /nav/
nav_key: nav
---

<section class="xm-page">
  <header class="xm-page-head">
    <h1>网址导航</h1>
    <p>整理常用网站、开发工具和学习入口。</p>
  </header>
  <div class="xm-page-body">
    <div class="xm-nav-grid">
      {% for item in site.data.site_links %}
      <a class="xm-nav-item" href="{{ item.url }}" target="_blank" rel="noopener">
        <h3>{{ item.title }}</h3>
        <p>{{ item.description }}</p>
        <span>{{ item.group }}</span>
      </a>
      {% endfor %}
    </div>
  </div>
</section>
