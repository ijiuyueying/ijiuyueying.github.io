# GitHub同步设计

## 当前阶段

博客作为展示层：

Jekyll
 |
 Markdown/YAML
 |
 GitHub Pages

## 专业版阶段

管理后台：

frontend
 |
 backend API
 |
 GitHub API
 |
 repository

## 原则

- 不在前端保存GitHub Token
- 所有修改经过API层
- 所有操作记录日志
- 删除支持回滚

## 后续桌面版

Electron客户端复用backend API。
