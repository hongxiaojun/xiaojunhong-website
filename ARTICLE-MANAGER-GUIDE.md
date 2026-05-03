# 文章管理工具使用指南

**功能**: 通过可视化界面管理文章置顶状态，点击按钮即可切换

---

## 快速开始

### 1. 启动管理工具

在项目根目录运行：

```bash
node article-manager.js
```

你会看到：

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   📚 文章管理工具已启动！                                      ║
║                                                               ║
║   在浏览器中打开: http://localhost:3000                        ║
║                                                               ║
║   按Ctrl+C停止服务器                                          ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

### 2. 打开管理界面

在浏览器中访问：**http://localhost:3000**

---

## 功能说明

### 统计面板

管理页面顶部显示三个统计卡片：
- **全部文章**: 网站中的文章总数
- **置顶文章**: 当前置顶的文章数量
- **最新文章**: 最近的 2 篇文章

### 过滤选项

点击不同的过滤按钮查看：
- **全部文章**: 显示所有文章
- **置顶文章**: 只显示已置顶的文章
- **未置顶**: 只显示未置顶的文章

### 置顶操作

每篇文章都有一个操作按钮：
- **设为置顶**: 将文章设置为置顶，显示在首页
- **取消置顶**: 取消文章的置顶状态

**视觉效果**：
- 置顶文章有橙色渐变背景
- 左上角显示 ⭐ 徽章
- 按钮为橙色样式

---

## 操作流程

### 置顶文章

1. 启动管理工具
2. 在浏览器打开管理界面
3. 找到想置顶的文章
4. 点击"设为置顶"按钮
5. 看到"已设为置顶"的提示

### 取消置顶

1. 在管理界面找到已置顶的文章（有⭐徽章）
2. 点击"取消置顶"按钮
3. 看到"已取消置顶"的提示

### 提交更改

管理工具会自动修改文章文件，你只需要：

```bash
# 1. 停止管理工具（按 Ctrl+C）

# 2. 查看修改的文件
git status

# 3. 提交更改
git add content/articles/
git commit -m "Update featured articles"

# 4. 推送到 GitHub
git push origin main
```

---

## 技术细节

### 工作原理

1. **本地服务器**: Node.js 创建 HTTP 服务器
2. **文件操作**: 直接读写 Markdown 文件
3. **Front Matter 解析**: 自动识别和更新 YAML 格式
4. **实时更新**: 点击按钮立即生效

### 修改内容

当点击"设为置顶"时：

```markdown
---
title: "文章标题"
date: 2026-05-03
featured: true  # 添加这一行
---
```

当点击"取消置顶"时：

```markdown
---
title: "文章标题"
date: 2026-05-03
featured: false  # 或删除这一行
---
```

### 数量限制

- **最多置顶**: 6 篇文章
- **超过限制**: 会显示提示信息

---

## 常见问题

**Q: 为什么启动失败？**
A: 确保端口 3000 没有被占用，或者修改脚本中的端口号。

**Q: 修改后没有生效？**
A: 需要重新构建网站：`hugo --minify`

**Q: 如何更改端口号？**
A: 编辑 `article-manager.js` 中的 `CONFIG.port` 值。

**Q: 管理工具会影响网站吗？**
A: 不会。管理工具只是修改文章文件，不参与网站构建。

**Q: 可以同时运行 Hugo 和管理工具吗？**
A: 可以，但它们使用不同端口：
- Hugo: `http://localhost:1313`
- 管理工具: `http://localhost:3000`

---

## 快捷命令

### 查看所有置顶文章

```bash
grep -r "featured: true" content/articles/
```

### 批量取消置顶（谨慎使用）

```bash
find content/articles/ -name "*.md" -exec sed -i '' '/featured: true/d' {} \;
```

### 统计置顶文章数

```bash
grep -r "featured: true" content/articles/ | wc -l
```

---

## 文件结构

```
xiaojunhong-website/
├── article-manager.js           # 管理工具主程序
├── static/
│   └── article-admin.html      # 管理界面（自动生成）
├── content/
│   └── articles/               # 文章目录
│       ├── article-1.md        # 文章文件
│       └── ...
└── ARTICLE-MANAGER-GUIDE.md    # 本文档
```

---

## 安全说明

- 本地工具，仅在开发环境使用
- 不要在生产服务器上运行
- 修改文件前建议先备份
- 使用 Git 可以随时回退

---

## 高级用法

### 自定义配置

编辑 `article-manager.js` 中的 `CONFIG` 对象：

```javascript
const CONFIG = {
    port: 3000,                          // 修改端口
    articlesDir: './content/articles',   // 修改文章目录
    maxFeatured: 6                       // 修改最大置顶数
};
```

### 集成到 npm scripts

在 `package.json` 中添加：

```json
{
  "scripts": {
    "manage": "node article-manager.js"
  }
}
```

然后使用：`npm run manage`

### 开机自启动（不推荐）

如果你想让管理工具一直运行：

```bash
# macOS
brew services start article-manager

# Linux
systemctl start article-manager
```

---

**版本**: 1.0
**更新日期**: 2026-05-03
**相关文件**:
- `article-manager.js` - 主程序
- `FEATURED-ARTICLES-GUIDE.md` - 置顶文章功能说明
