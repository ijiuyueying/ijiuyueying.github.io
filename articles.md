---
layout: default
title: 文章归档
permalink: /articles/
nav_key: project
---

{% assign project_menu_doc = site.menu_defs | where: 'module_key', 'project' | first %}

<style>
.archive-three-grid{width:min(1420px,calc(100% - 36px));margin:0 auto;display:grid;grid-template-columns:190px minmax(0,1fr) 330px;gap:20px;align-items:start}.archive-left{position:sticky;top:96px;max-height:calc(100vh - 116px);overflow:auto}.archive-center{min-width:0;background:#fff;box-shadow:0 2px 14px rgba(0,0,0,.07)}.archive-header{padding:24px 28px;border-bottom:1px solid #eceeef}.archive-header .archive-kicker{margin-bottom:4px;color:#9aa1a8;font-size:11px;letter-spacing:.15em}.archive-header h1{margin:0;font-size:30px}.archive-header p{margin:6px 0 0;color:#858d95;font-size:13px}.archive-year{padding:13px 26px;background:#f7f8f9;border-bottom:1px solid #eceeef;font-size:18px;font-weight:800}.archive-entry{display:grid;grid-template-columns:72px minmax(0,1fr);gap:18px;padding:18px 26px;border-bottom:1px solid #eceeef}.archive-entry time{padding-top:3px;color:#9aa1a8;font-size:12px}.archive-entry h2{margin:0 0 5px;font-size:18px;font-weight:600}.archive-entry h2 a:hover{color:#2990df}.archive-entry-meta{display:flex;flex-wrap:wrap;gap:8px;color:#9aa1a8;font-size:11px}.archive-entry-summary{margin:8px 0 0;color:#68717a;font-size:13px;line-height:1.7}@media(max-width:1100px){.archive-three-grid{grid-template-columns:170px minmax(0,1fr)}.archive-three-grid>.xm-rightbar{display:none}}@media(max-width:760px){.archive-three-grid{width:min(100% - 20px,1180px);grid-template-columns:1fr}.archive-left{position:static;max-height:none}.archive-entry{grid-template-columns:52px minmax(0,1fr);padding:16px 18px}}
</style>

<div class="archive-three-grid">
  <div class="archive-left">{% include project-side-nav.html %}</div>

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
        {% assign category_key = post.categories | first %}
        {% assign category_item = project_menu_doc.items | where: 'key', category_key | first %}
        {% assign subcategory_item = nil %}
        {% if category_item and post.subcategory %}{% assign subcategory_item = category_item.children | where: 'key', post.subcategory | first %}{% endif %}
        {% if year != current_year %}
          <div class="archive-year">{{ year }}</div>
          {% assign current_year = year %}
        {% endif %}
        <article class="archive-entry">
          <time>{{ post.date | date: "%m.%d" }}</time>
          <div>
            <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
            <div class="archive-entry-meta">
              {% if category_item %}<span>{{ category_item.label }}</span>{% elsif category_key %}<span>{{ category_key }}</span>{% endif %}
              {% if subcategory_item %}<span>{{ subcategory_item.label }}</span>{% elsif post.subcategory %}<span>{{ post.subcategory }}</span>{% endif %}
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
