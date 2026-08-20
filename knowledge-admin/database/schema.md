# 数据库模型设计

## category 分类表

保存：

- id
- key
- name
- parent_id
- status
- created_time
- updated_time

状态：

- ACTIVE 正常
- HIDDEN 隐藏
- ARCHIVED 归档
- DELETED 删除

---

## article 文章表

保存：

- id
- title
- path
- category_id
- tags
- version
- status

---

## asset 图片资源表

保存：

- id
- filename
- path
- category_id
- tags

---

## operation_log 操作日志

保存：

- id
- user
- action
- before_data
- after_data
- result
- created_time
