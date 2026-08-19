---
module_key: gallery
items:
  - key: all
    label: 全部图片

  - key: data-warehouse
    label: 数仓建设
    children:
      - key: architecture
        label: 架构 / 全链路
      - key: governance
        label: 数据治理 / 质量
      - key: performance
        label: 性能优化
      - key: troubleshooting
        label: 异常排查
      - key: scheduling
        label: 调度 / 同步
      - key: reporting
        label: 报表分析

  - key: game
    label: 游戏
    children:
      - key: genshin
        label: 原神
---

# 图片收藏分类配置

这里维护图片收藏的二级、三级分类。

例如：

```text
图片收藏
├─ 数仓建设
│  ├─ 架构 / 全链路
│  ├─ 数据治理 / 质量
│  ├─ 性能优化
│  ├─ 异常排查
│  ├─ 调度 / 同步
│  └─ 报表分析
└─ 游戏
   └─ 原神
```
