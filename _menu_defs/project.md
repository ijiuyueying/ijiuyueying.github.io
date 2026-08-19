---
module_key: project
items:
  - key: all
    label: 推荐
    slides:
      - title: 银行监管报送
        text: 1104、G01 / G11 / G12、Mapping 与监管数据治理。
        image: "https://images.unsplash.com/photo-1768839720841-8219c4da7436?auto=format&fit=crop&w=1600&q=82"
        url: /bank/
      - title: 制造业数仓
        text: ERP、SRM、WMS、Hive、DataX 与制造业数据仓库项目。
        image: "https://images.unsplash.com/photo-1764835994645-3faa2c40f708?auto=format&fit=crop&w=1600&q=82"
        url: /manufacturing/
      - title: 电商数据分析
        text: GMV、转化漏斗、RFM、商品库存与经营分析。
        image: "https://images.unsplash.com/photo-1642177977596-36c73531208d?auto=format&fit=crop&w=1600&q=82"
        url: /ecommerce/

  - key: bank
    label: 银行监管
    children:
      - key: 1104
        label: 1104体系
      - key: reports
        label: G01 / G11 / G12
      - key: governance
        label: 数据治理
    slides:
      - title: 银行监管报送
        text: 1104 体系、监管指标、Mapping、数据清洗与数据治理。
        image: "https://images.unsplash.com/photo-1768839720841-8219c4da7436?auto=format&fit=crop&w=1600&q=82"
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
        image: "https://images.unsplash.com/photo-1764835994645-3faa2c40f708?auto=format&fit=crop&w=1600&q=82"
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
        image: "https://images.unsplash.com/photo-1642177977596-36c73531208d?auto=format&fit=crop&w=1600&q=82"
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
        image: "https://images.unsplash.com/photo-1518932945647-7a1c969f8be2?auto=format&fit=crop&w=1600&q=82"
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
        image: "https://images.unsplash.com/photo-1518932945647-7a1c969f8be2?auto=format&fit=crop&w=1600&q=82"
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
        image: "https://images.unsplash.com/photo-1518932945647-7a1c969f8be2?auto=format&fit=crop&w=1600&q=82"
        url: /git/
---

# 项目分类配置

在上面的 `items:` 中维护项目二级分类和三级分类。