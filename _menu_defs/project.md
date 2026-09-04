---
module_key: project
show_top: true
article_enabled: true
top_label: 首页
top_url: /
top_order: 10
items:
  - key: all
    label: 推荐
    slides:
      - title: 项目知识库
        text: 银行监管、制造业数仓、电商分析与开发笔记持续整理。
        image: "/assets/images/banner/all-01.svg"
        url: /articles/
      - title: 项目实操记录
        text: 从业务需求、数据开发到问题排查，把完整链路沉淀下来。
        image: "/assets/images/banner/all-02.svg"
        url: /articles/
      - title: 技术与面试整理
        text: SQL、Python、数仓开发和项目面试问题的持续复盘。
        image: "/assets/images/banner/all-03.svg"
        url: /articles/

  - key: bank
    label: 银行监管
    children:
      - key: governance
        label: 数据治理
    slides:
      - title: 银行监管报送
        text: 1104体系、监管指标、Mapping、数据清洗与数据治理。
        image: "/assets/images/banner/bank-01.svg"
        url: /bank/
      - title: 监管数据与风险
        text: 从核心、信贷、财务数据到监管口径和报送文件。
        image: "/assets/images/banner/bank-02.svg"
        url: /bank/

  - key: manufacturing
    label: 制造业数仓
    children:
      - key: ods
        label: ODS
      - key: warehouse
        label: DWD / DWS
      - key: sync
        label: DataX / 调度
    slides:
      - title: 制造业数仓项目
        text: ERP、SRM、WMS 多业务系统数据进入数仓后的建模与分析。
        image: "/assets/images/banner/manufacturing-01.svg"
        url: /manufacturing/
      - title: 生产与仓储数据链路
        text: 采购、库存、生产、设备与调度任务的完整数据链路。
        image: "/assets/images/banner/manufacturing-02.svg"
        url: /manufacturing/

  - key: ecommerce
    label: 电商分析
    children:
      - key: funnel
        label: GMV / 漏斗
      - key: rfm
        label: RFM
      - key: product
        label: 商品 / 库存
    slides:
      - title: 电商经营分析
        text: 多平台 GMV、订单、用户、流量和商品经营分析。
        image: "/assets/images/banner/ecommerce-01.svg"
        url: /ecommerce/
      - title: 商品与用户分析
        text: 转化漏斗、RFM、商品库存和活动效果分析。
        image: "/assets/images/banner/ecommerce-02.svg"
        url: /ecommerce/

  - key: sql-hive
    label: SQL / Hive
    children:
      - key: sql
        label: SQL
      - key: hive
        label: Hive
      - key: tuning
        label: 性能优化
    slides:
      - title: SQL / Hive
        text: SQL、Hive SQL、窗口函数、数据清洗与性能优化。
        image: "/assets/images/banner/sql-hive-01.svg"
        url: /sql-hive/
      - title: SQL 性能优化
        text: 执行计划、Join、分区、数据倾斜与常见调优方法。
        image: "/assets/images/banner/sql-hive-02.svg"
        url: /sql-hive/

  - key: python
    label: Python
    children:
      - key: pandas
        label: Pandas
      - key: analysis
        label: 数据分析
    slides:
      - title: Python 数据处理
        text: Pandas、数据清洗、分析脚本和自动化处理。
        image: "/assets/images/banner/python-01.svg"
        url: /python/
      - title: Python 数据分析
        text: 数据处理、指标计算、专题分析和自动化脚本。
        image: "/assets/images/banner/python-02.svg"
        url: /python/

  - key: git
    label: Git / GitHub
    children:
      - key: git-basic
        label: Git基础
      - key: pages
        label: GitHub Pages
    slides:
      - title: Git / GitHub
        text: Git 常用操作、GitHub Pages 与个人博客维护。
        image: "/assets/images/banner/git-01.svg"
        url: /git/
      - title: 版本管理与发布
        text: 分支、提交、远程仓库与自动部署工作流。
        image: "/assets/images/banner/git-02.svg"
        url: /git/
---

# 项目分类配置

`article_enabled: true` 表示这个一级模块可以通过“新建博客文章.bat”发布文章。

在上面的 `items:` 中维护项目二级分类、三级分类和该分类自己的轮播图。

## 轮播图规则

- 不同二级分类尽量使用不同图片。
- 同一分类可以在 `slides:` 下配置多张不同图片。
- 推荐使用仓库本地图片，例如 `/assets/images/banner/bank-01.jpg`，长期更稳定。
