---
layout: default
title: 文章归档
permalink: /articles/
nav_key: project
---

{% assign project_menu_doc = site.menu_defs | where: 'module_key', 'project' | first %}

<style>
/* 归档页：配色全部走 --xm-* 变量 */
.archive-three-grid{
  width:min(var(--xm-shell),calc(100% - 40px));margin:0 auto;
  display:grid;grid-template-columns:212px minmax(0,1fr) 300px;gap:22px;align-items:start;
}
.archive-left{position:sticky;top:var(--xm-sticky-top);max-height:calc(100vh - 104px);overflow:auto}

.archive-center{
  min-width:0;background:var(--xm-surface);
  border:1px solid var(--xm-border);border-radius:var(--xm-radius);
  box-shadow:var(--xm-shadow-sm);overflow:hidden;
}
.archive-header{
  padding:26px 30px;border-bottom:1px solid var(--xm-border);
  background:var(--xm-surface-soft);
}
.archive-header .archive-kicker{
  margin-bottom:5px;color:var(--xm-faint);
  font-size:11px;letter-spacing:.15em;font-weight:700;
}
.archive-header h1{margin:0;font-size:26px;font-weight:800;color:var(--xm-ink)}
.archive-header p{margin:6px 0 0;color:var(--xm-muted);font-size:13.5px}

.archive-year{
  padding:13px 30px;background:var(--xm-surface-alt);
  border-bottom:1px solid var(--xm-border);
  font-size:15px;font-weight:800;color:var(--xm-ink);
  display:flex;align-items:center;gap:8px;
}
.archive-year::before{content:"";width:3px;height:14px;border-radius:2px;background:var(--xm-accent)}

.archive-entry{
  display:grid;grid-template-columns:76px minmax(0,1fr);gap:18px;
  padding:18px 30px;border-bottom:1px solid var(--xm-border-soft);
  transition:background-color .2s var(--xm-ease);
}
.archive-entry:hover{background:var(--xm-surface-soft)}
.archive-entry time{padding-top:3px;color:var(--xm-faint);font-size:12.5px}
.archive-entry h2{margin:0 0 5px;font-size:18px;font-weight:700;color:var(--xm-ink)}
.archive-entry h2 a:hover{color:var(--xm-accent)}
.archive-entry-meta{display:flex;flex-wrap:wrap;gap:8px;color:var(--xm-faint);font-size:11.5px}
.archive-entry-summary{margin:8px 0 0;color:var(--xm-muted);font-size:13.5px;line-height:1.7}

@media(max-width:1100px){
  .archive-three-grid{grid-template-columns:170px minmax(0,1fr)}
  .archive-three-grid>.xm-rightbar{display:none}
}
@media(max-width:760px){
  .archive-three-grid{width:min(100% - 28px,1180px);grid-template-columns:1fr}
  .archive-left{position:static;max-height:none}
  .archive-entry{grid-template-columns:56px minmax(0,1fr);padding:16px 18px}
}
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
