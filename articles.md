---
layout: default
title: 文章归档
permalink: /articles/
nav_key: project
---

<style>
.archive-three-grid{width:min(1420px,calc(100% - 36px));margin:0 auto;display:grid;grid-template-columns:190px minmax(0,1fr) 330px;gap:20px;align-items:start}.archive-left{position:sticky;top:96px;max-height:calc(100vh - 116px);overflow:auto}.archive-center{min-width:0;background:#fff;box-shadow:0 2px 14px rgba(0,0,0,.07)}.archive-header{padding:24px 28px;border-bottom:1px solid #eceeef}.archive-header .archive-kicker{margin-bottom:4px;color:#9aa1a8;font-size:11px;letter-spacing:.15em}.archive-header h1{margin:0;font-size:30px}.archive-header p{margin:6px 0 0;color:#858d95;font-size:13px}.archive-year{padding:13px 26px;background:#f7f8f9;border-bottom:1px solid #eceeef;font-size:18px;font-weight:800}.archive-entry{display:grid;grid-template-columns:72px minmax(0,1fr);gap:18px;padding:18px 26px;border-bottom:1px solid #eceeef}.archive-entry time{padding-top:3px;color:#9aa1a8;font-size:12px}.archive-entry h2{margin:0 0 5px;font-size:18px;font-weight:600}.archive-entry h2 a:hover{color:#2990df}.archive-entry-meta{display:flex;flex-wrap:wrap;gap:8px;color:#9aa1a8;font-size:11px}.archive-entry-summary{margin:8px 0 0;color:#68717a;font-size:13px;line-height:1.7}.persistent-project-nav{background:#fff;box-shadow:0 2px 14px rgba(0,0,0,.07)}.persistent-nav-title{padding:14px 16px;border-bottom:1px solid #eceeef;font-size:16px;font-weight:800}.persistent-nav-item{border-bottom:1px solid #f0f1f2}.persistent-nav-parent-row{display:flex;align-items:stretch}.persistent-nav-parent{flex:1;padding:11px 12px;color:#4c535a;font-size:14px}.persistent-nav-parent:hover,.persistent-nav-parent.active{color:#d94b40;background:#fff7f6}.persistent-nav-toggle{width:34px;border:0;background:#fff;color:#8d959c;cursor:pointer;font-size:19px;transition:.18s}.persistent-nav-item.open .persistent-nav-toggle{transform:rotate(90deg)}.persistent-nav-children{display:none;padding:5px 0 8px;background:#fafafa}.persistent-nav-item.open .persistent-nav-children{display:block}.persistent-nav-child{display:block;padding:7px 12px 7px 25px;color:#737a81;font-size:12px}.persistent-nav-child:hover,.persistent-nav-child.active{color:#2990df;background:#f2f8fc}@media(max-width:1100px){.archive-three-grid{grid-template-columns:170px minmax(0,1fr)}.archive-three-grid>.xm-rightbar{display:none}}@media(max-width:760px){.archive-three-grid{width:min(100% - 20px,1180px);grid-template-columns:1fr}.archive-left{position:static;max-height:none}.archive-entry{grid-template-columns:52px minmax(0,1fr);padding:16px 18px}}
</style>

<div class="archive-three-grid">
  <div class="archive-left">
    {% include project-side-nav.html %}
  </div>

  <main class="archive-center">
    <header class="archive-header">
      <div class="archive-kicker">ARCHIVE</div>
      <h1>文章归档</h1>
      <p>按发布时间浏览全部公开文章，共 {{ site.posts | size }} 篇。</p>
    </header>

    {% if site.posts.size > 0 %}
      {% assign current_year = '' %}
      {% for post in site.posts %}
        {% assign year = post.date | date: "%Y" %}
        {% if year != current_year %}
          <div class="archive-year">{{ year }}</div>
          {% assign current_year = year %}
        {% endif %}
        <article class="archive-entry">
          <time>{{ post.date | date: "%m.%d" }}</time>
          <div>
            <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
            <div class="archive-entry-meta">
              {% if post.categories and post.categories.size > 0 %}<span>{{ post.categories | join: " / " }}</span>{% endif %}
              {% if post.subcategory %}<span>{{ post.subcategory }}</span>{% endif %}
              {% if post.tags and post.tags.size > 0 %}<span>{{ post.tags | join: " · " }}</span>{% endif %}
            </div>
            {% if post.excerpt %}<p class="archive-entry-summary">{{ post.excerpt | strip_html | strip_newlines | truncate: 100 }}</p>{% endif %}
          </div>
        </article>
      {% endfor %}
    {% else %}
      <div class="xm-empty">还没有公开文章。</div>
    {% endif %}
  </main>

  {% include global-rightbar.html %}
</div>
