# 九月影博客：Markdown 分类与收藏维护说明

现在网站的一、二、三级分类和右侧个人收藏，已经改成 Markdown 配置方式维护。

## 1. 顶部一级分类

顶部一级分类来自 `_menu_defs/` 下的 Markdown 文件。

当前主要文件：

```text
_menu_defs/project.md   项目
_menu_defs/nav.md       网址导航
_menu_defs/music.md     歌曲分类
_menu_defs/gallery.md   图片收藏（默认不显示在顶部）
_menu_defs/videos.md    视频收藏（默认不显示在顶部）
```

例如项目文件顶部：

```yml
---
module_key: project
show_top: true
top_label: 项目
top_url: /
top_order: 10
items:
  ...
---
```

字段说明：

- `module_key`：模块唯一英文 key
- `show_top: true`：显示在顶部一级导航
- `top_label`：顶部显示名称
- `top_url`：点击跳转地址
- `top_order`：顶部排序，数字越小越靠前

如果以后想把视频收藏放到顶部，在 `_menu_defs/videos.md` 的 YAML 中增加：

```yml
show_top: true
top_label: 视频收藏
top_url: /videos/
top_order: 40
```

## 2. 二级和三级分类

每个模块自己的 Markdown 文件中，`items:` 是二级分类。

例如项目：

```yml
items:
  - key: bank
    label: 银行监管
    children:
      - key: 1104
        label: 1104体系
      - key: governance
        label: 数据治理
```

这里：

```text
银行监管        二级分类
├─ 1104体系     三级分类
└─ 数据治理     三级分类
```

网站交互规则：

1. 默认只显示二级分类。
2. 第一次点击二级分类：展开它自己的三级分类，并按二级分类筛选内容。
3. 再次点击同一个二级分类：收起三级分类，仍保留二级筛选。
4. 点击其他二级分类：之前的三级目录自动收起，新的展开。
5. 点击三级分类：只显示该二级 + 三级对应内容。
6. 没有 `children:` 的二级分类不会显示箭头，也不会产生空展开区域。

## 3. 新增项目二级分类

打开：

```text
_menu_defs/project.md
```

在 `items:` 中加入：

```yml
- key: hadoop
  label: Hadoop
  children:
    - key: hdfs
      label: HDFS
    - key: yarn
      label: YARN
  slides:
    - title: Hadoop 学习笔记
      text: Hadoop、HDFS、YARN 等内容。
      image: /assets/images/banner/hadoop.jpg
      url: /hadoop/
```

之后双击 `新建博客文章.bat`，脚本会自动读取这个文件，Hadoop 会自动出现在二级分类选择菜单里，HDFS / YARN 会自动出现在三级分类选择菜单里。

## 4. 删除分类

删除对应的完整分类段即可。

例如删除：

```yml
- key: python
  label: Python
  ...
```

保存并发布后，左侧 Python 分类就会消失。

注意：如果已有文章仍然写着：

```yml
categories: [python]
```

文章本身不会自动删除，只是左侧不再有 Python 分类入口。

## 5. 新建文章自动选择二三级分类

双击：

```text
新建博客文章.bat
```

脚本现在读取：

```text
_menu_defs/project.md
```

例如选择：

```text
银行监管 → 数据治理
```

生成文章 YAML：

```yml
categories: [bank]
subcategory: governance
```

不需要自己记英文 key。

## 6. 网址、歌曲、图片、视频分类

分别维护：

```text
_menu_defs/nav.md
_menu_defs/music.md
_menu_defs/gallery.md
_menu_defs/videos.md
```

内容本身仍然分别放在：

```text
_data/site_links.yml
_data/music.yml
_data/gallery.yml
_data/videos.yml
```

分类 key 必须对应。

例如视频菜单：

```yml
- key: fox-spirit
  label: 狐妖小红娘
  children:
    - key: huaizhu
      label: 淮竹篇
```

视频数据写：

```yml
group: fox-spirit
subgroup: huaizhu
```

## 7. 右侧“个人收藏”改成一个模块一个 MD

目录：

```text
_collection_defs/
```

当前：

```text
_collection_defs/gallery.md
_collection_defs/videos.md
```

例如图片收藏：

```yml
---
key: gallery
title: 图片收藏
description: 学习图、截图、灵感
url: /gallery/
icon: "🖼"
order: 10
---
```

新增一个“游戏收藏”，可以新建：

```text
_collection_defs/games.md
```

内容：

```yml
---
key: games
title: 游戏收藏
description: 喜欢的游戏与攻略
url: /games/
icon: "🎮"
order: 30
---
```

右侧个人收藏会自动多出这个模块。

注意：如果 `/games/` 页面还不存在，还需要创建对应页面，否则点击会 404。

## 8. 为什么不做“一条三级分类一个 MD”

技术上可以，但项目一多会产生几十、上百个配置文件，维护反而更乱。

目前采用：

```text
一个一级模块 = 一个分类配置 MD
一个右侧收藏模块 = 一个 MD
```

这样既能用 Typora 直接编辑，也不会产生大量碎文件。

## 9. 发布流程

```text
修改 Markdown 配置
→ 保存
→ 发布博客.bat
→ 等 GitHub Actions 绿色通过
→ Ctrl + F5 刷新网站
```
