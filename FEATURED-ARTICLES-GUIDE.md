# 首页置顶文章使用指南

**功能说明**: 通过配置文件和文章标记，灵活控制首页显示的文章

---

## 工作原理

首页文章展示遵循以下规则：

1. **置顶文章优先**：所有标记为 `featured: true` 的文章会优先显示
2. **最新文章补充**：自动获取最新的 2 篇文章（排除已置顶的）
3. **智能合并**：置顶文章 + 最新文章组合显示
4. **数量控制**：最多显示 6 篇文章（可配置）

---

## 如何置顶文章

### 方法 1：在文章 Front Matter 中添加标记

在文章的 YAML 头部添加 `featured: true`：

```yaml
---
title: "你的文章标题"
date: 2026-05-03
draft: false
featured: true  # 添加这一行
description: "文章描述"
tags: ["标签1", "标签2"]
---
```

### 方法 2：编辑已有文章

打开任何已存在的文章，在 front matter 中添加 `featured: true` 即可置顶。

---

## 配置参数

在 `config.toml` 中可以调整以下参数：

```toml
[params]
  # 首页显示的最新文章数量（不包括置顶文章）
  latestArticlesCount = 2

  # 首页最多显示的文章总数
  maxHomepageArticles = 6
```

### 参数说明

- **latestArticlesCount**: 控制显示多少篇最新文章
- **maxHomepageArticles**: 控制首页最多显示多少篇文章（置顶 + 最新）

---

## 显示逻辑示例

### 场景 1：有 2 篇置顶文章

```
置顶文章 A ⭐
置顶文章 B ⭐
最新文章 1 (非置顶)
最新文章 2 (非置顶)
─────────────────
总计：4 篇文章
```

### 场景 2：有 0 篇置顶文章

```
最新文章 1
最新文章 2
─────────────────
总计：2 篇文章
```

### 场景 3：有 5 篇置顶文章

```
置顶文章 A ⭐
置顶文章 B ⭐
置顶文章 C ⭐
置顶文章 D ⭐
置顶文章 E ⭐
最新文章 1
─────────────────
总计：6 篇文章（受 maxHomepageArticles 限制）
```

---

## 视觉效果

置顶文章有特殊的视觉标识：

- ⭐ **徽章显示**：左上角显示 "⭐ Featured" 徽章
- **渐变背景**：微妙的渐变背景效果
- **强调色边框**：使用品牌色边框
- **标题高亮**：标题使用品牌色显示

---

## 管理建议

### 推荐做法

1. **保持精选**：建议置顶 2-4 篇代表作品
2. **定期更新**：每月更新置顶文章，保持新鲜感
3. **内容多样**：置顶不同类型的文章（教程、经验分享、深度思考）
4. **质量优先**：只置顶你认为最值得展示的内容

### 取消置顶

只需删除或注释掉 `featured: true` 这一行：

```yaml
---
title: "文章标题"
# featured: true  # 注释掉或删除这行
---
```

---

## 快速操作

### 置顶最新一篇文章

```bash
# 1. 找到最新的文章
ls -lt content/articles/ | head -2

# 2. 编辑文章，在 front matter 添加 featured: true
# 3. 重新构建并推送
hugo --minify
git add .
git commit -m "Feature latest article"
git push origin main
```

### 批量管理置顶文章

```bash
# 查看所有置顶文章
grep -r "featured: true" content/articles/

# 取消所有置顶（谨慎使用）
# find content/articles/ -name "*.md" -exec sed -i '' '/featured: true/d' {} \;
```

---

## 技术细节

### 优先级逻辑

Hugo 模板中的处理顺序：

1. 获取所有标记为 `featured: true` 的文章
2. 获取最新 N 篇非置顶文章（N = `latestArticlesCount`）
3. 合并两个列表
4. 限制总数量（M = `maxHomepageArticles`）

### 按日期排序

- 置顶文章：保持原有顺序（或按发布日期降序）
- 最新文章：按发布日期降序自动排序

---

## 常见问题

**Q: 如果我置顶了 10 篇文章会怎样？**
A: 首页最多显示 `maxHomepageArticles` 篇（默认 6 篇）。置顶文章会优先显示，最新的几篇会被截断。

**Q: 置顶文章会一直显示在首页吗？**
A: 是的，除非你取消 `featured: true` 标记。

**Q: 可以改变置顶文章的显示顺序吗？**
A: 当前按发布日期排序。如需自定义顺序，可以在文章中添加 `weight` 参数。

**Q: 最新文章包括置顶文章吗？**
A: 不包括。最新文章会自动排除已置顶的文章。

---

## 示例配置

### 配置 1：展示更多内容

```toml
[params]
  latestArticlesCount = 4  # 显示 4 篇最新文章
  maxHomepageArticles = 8  # 最多 8 篇
```

### 配置 2：突出置顶内容

```toml
[params]
  latestArticlesCount = 1  # 只显示 1 篇最新文章
  maxHomepageArticles = 5  # 给置顶文章更多空间
```

### 配置 3：纯最新文章模式

不在任何文章中添加 `featured: true`，首页就只显示最新 2 篇文章。

---

**更新日期**: 2026-05-03
**版本**: 1.0
**相关文件**:
- `config.toml` - 配置参数
- `layouts/index.html` - 首页模板
- `layouts/_default/baseof.html` - 样式定义
