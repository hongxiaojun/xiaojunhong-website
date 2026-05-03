---
title: "三天搭建个人网站：完整教程"
date: 2026-05-03
draft: false
featured: true
description: "从零到上线的完整指南：使用Hugo+Cloudflare Pages快速构建你的数字家园。基于真实三天开发经历，包含所有关键步骤和常见问题解决方案。"
readingTime: 15
tags: ["教程", "Hugo", "Cloudflare Pages", "Web开发", "新手指南", "Kami设计"]
---

## 开篇：你也能做到

你是否也有过这样的经历：想拥有个人网站，但每次都被"还不太会技术"、"内容还不够多"、"设计不好看"这些念头劝退？

我懂。因为三天前，我也是这么想的。

但三天后，我拥有了个人网站：https://xiaojunhong.space

**完成这个教程后，你将能够**：
- 在三天内从零搭建一个功能完整的个人网站
- 掌握Hugo静态网站生成器的基础使用
- 应用Kami设计系统打造温暖的纸张风格
- 通过Cloudflare Pages免费部署到公网
- 建立持续迭代的心态，让网站随你一起成长

不需要你是技术专家，不需要你有完美设计，不需要你准备大量内容。**你只需要一个开始的决定**。

---

## 第1章：准备与开始

### 1.1 为什么你需要个人网站

**章节目标**：理解个人网站的价值，打破"还没准备好"的心理障碍

#### 数字主权 vs 租用空间

你每天在社交媒体上发布内容、在社区分享观点、在论坛写回答——但这些内容不属于你。平台算法决定谁能看到，平台政策决定什么能留，平台变迁可能让一切消失。

**个人网站是你的数字家园**。你拥有完全的控制权：设计、内容、访问方式。

#### 常见误区 vs 真实情况

| 你以为的 | 实际上 |
|---------|--------|
| 需要深厚的编程基础 | 现代工具很简单，一行命令就能搭建 |
| 需要大量内容准备 | 网站会随你一起成长 |
| 需要专业的设计能力 | 好的设计系统可以借鉴和定制 |
| 需要昂贵的服务器 | 有很多免费托管选项 |

#### 真实的障碍

不是技术，而是**心理**。是"还没准备好"的完美主义，是"不会技术"的恐惧，是"做得不够好"的自我怀疑。

**如何打破心理障碍？**

接受一个事实：**完美的个人网站不存在，只有不断进化的个人网站**。

我的第一个版本很简陋，但它在线。这很重要——当你的网站真正在互联网上可以被访问时，你就跨过了最大的心理门槛。

#### 练习任务

花5分钟，列出你想在网站上分享的三件事（可以是文章、项目、想法、照片）

#### 检查点

你是否认可"现在开始就是最好的时机"？

---

### 1.2 选择工具：Hugo+Cloudflare Pages

**章节目标**：了解Hugo+Cloudflare Pages的组合优势，完成环境准备

#### Hugo的优势

- **安装简单**：一行命令搞定
- **无需编程**：Markdown语法写文章
- **速度极快**：静态网站，加载迅速
- **免费开源**：永久免费，社区活跃

#### Cloudflare Pages的优势

- **自动部署**：连接GitHub，自动构建
- **全球CDN**：世界各地的快速访问
- **免费HTTPS**：自动配置安全证书
- **零成本**：个人使用完全免费

#### 环境准备（5分钟）

```bash
# macOS安装Hugo
brew install hugo

# 验证安装
hugo version
```

如果你看到版本号（例如 `hugo v0.161.1+extended`），说明安装成功！

#### 注意事项

- Hugo版本要求：0.121.0以上
- 需要GitHub账号（Cloudflare Pages需要）
- Windows用户下载Hugo二进制文件

#### 练习任务

安装Hugo并验证版本

#### 检查点

你的终端能显示`hugo version`吗？

---

## 第2章：搭建基础网站

### 2.1 创建第一个Hugo网站

**章节目标**：从零创建Hugo网站，理解目录结构

#### 核心概念

Hugo是**静态网站生成器**：

```
Markdown文章 + HTML模板 = 完整的网站
```

#### 实际操作（10分钟）

```bash
# 1. 创建新网站
hugo new site my-website

# 2. 进入网站目录
cd my-website

# 3. 添加第一篇文章
hugo new posts/my-first-post.md

# 4. 启动本地服务器
hugo server -D

# 5. 浏览访问
open http://localhost:1313
```

#### 目录结构

```
my-website/
├── content/          # 内容目录
│   └── posts/        # 文章存放
├── layouts/          # 布局模板
├── static/           # 静态资源
├── config.toml       # 配置文件
└── themes/           # 主题目录
```

#### 注意事项

- `hugo server -D` 会显示草稿文章
- 修改文件后自动刷新浏览器
- 按 `Ctrl+C` 停止服务器

#### 练习任务

创建一个网站，启动服务器

#### 检查点

你能在浏览器看到欢迎页面吗？

---

### 2.2 配置网站基础信息

**章节目标**：设置网站标题、菜单链接、基础配置

#### config.toml配置

```toml
baseURL = "https://yourname.github.io/"
languageCode = "zh-cn"
title = "你的网站名称"

# 菜单配置
[[menu.main]]
    name = "首页"
    url = "/"
    weight = 1

[[menu.main]]
    name = "文章"
    url = "/posts/"
    weight = 2

[[menu.main]]
    name = "关于"
    url = "/about/"
    weight = 3
```

#### Front Matter格式

```yaml
---
title: "我的第一篇文章"
date: 2026-05-03
draft: false
---

正文内容...
```

#### 练习任务

修改config.toml，设置你的网站标题

#### 检查点

你的网站标题和菜单显示正确吗？

---

## 第3章：应用Kami设计

### 3.1 理解Kami设计系统

**章节目标**：了解Kami的核心理念

#### Kami的核心特征

1. **纸张质感**：温暖的米色背景
2. **点状网格**：subtle的纹理点缀
3.  **墨水蓝强调色**：#1B365D
4. **优雅字体**：serif字体

#### 设计哲学

> 内容为王，设计为辅。好的设计让内容更突出，而不是抢戏。

#### 练习任务

访问Kami官网，感受设计风格

#### 检查点

你能描述 Kami 的三个核心特征吗？

---

### 3.2 应用基础样式

**章节目标**：将Kami设计应用到你的网站

#### CSS变量配置

在 `layouts/_default/baseof.html` 中添加：

```css
:root {
    /* Kami色彩系统 */
    --parchment: #f5f4ed;
    --ivory: #faf9f5;
    --warm-sand: #ebe8de;
    --brand: #1B365D;
    --near-black: #141413;
    --olive: #504e49;
    --stone: #6b6a64;
}
```

#### 深色模式支持

```css
[data-theme="dark"] {
    --parchment: #1a1a1a;
    --ivory: #242424;
    --brand: #4da6ff;
    --near-black: #e0e0e0;
    --olive: #a0a0a0;
    --stone: #707070;
}
```

#### 练习任务

复制CSS到你的baseof.html

#### 检查点

背景颜色变了吗？

---

## 第4章：内容组织与优化

### 4.1 创建内容页面

**章节目标**：添加文章、笔记、关于页面

#### 内容结构

```
content/
├── posts/          # 文章
├── notes/          # 笔记
└── about/          # 关于页面
    └── _index.md
```

#### 练习任务

创建你的关于页面

#### 检查点

点击导航菜单的"关于"，能看到你的页面吗？

---

### 4.2 批量导入现有内容

**章节目标**：将本地笔记转换为网站内容

#### 转换示例

**原始笔记**：
```
# 学习笔记
今天学习了Python...
```

**转换后**：

```yaml
---
title: "学习笔记"
date: 2026-05-03
draft: false
tags: ["学习", "Python"]
---

今天学习了Python...

## 主要收获

- 变量和数据类型
- 函数定义
```

#### 注意事项

- 移除重复标题
- 检查特殊字符编码
- 验证链接正确性

#### 练习任务

导入5篇本地笔记

#### 检查点

笔记页面显示正常吗？

---

## 第5章：修复与优化

### 5.1 常见问题修复

**章节目标**：解决深色模式、响应式问题

#### 问题1：深色模式文字不可见

**原因**：CSS变量没有完全覆盖

**解决方案**：

```css
[data-theme="dark"] {
    --near-black: #e0e0e0;  /* 浅色文字 */
}
```

#### 问题2：移动端布局错乱

**解决方案**：

```css
@media (max-width: 768px) {
    .container {
        padding: 0 20px;
    }
    
    .sidebar {
        display: none;
    }
}
```

#### 练习任务

切换深色模式，检查文字可读性

#### 检查点

所有问题都解决了吗？

---

### 5.2 性能优化

**章节目标**：提升网站加载速度

#### 优化清单

- ✅ 压缩CSS和JS
- ✅ 优化图片大小
- ✅ 启用浏览器缓存
- ✅ 使用CDN

#### 练习任务

使用PageSpeed Insights测试

#### 检查点

得分超过80分了吗？

---

## 第6章：部署上线

### 6.1 连接GitHub和Cloudflare Pages

**章节目标**：将网站部署到公网

#### 步骤1：推送到GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/username/repo.git
git branch -M main
git push -u origin main
```

#### 步骤2：Cloudflare Pages设置

1. 登录 Cloudflare Dashboard
2. 进入 Pages → Create a project
3. 连接GitHub账户
4. 选择仓库
5. 配置构建设置

#### 练习任务

推送代码到GitHub

#### 检查点

你的网站能在公网访问了吗？

---

### 6.2 持续迭代

**章节目标**：建立持续改进的心态

#### 迭代原则

1. **先上线，再优化**
2. **小步快跑**
3. **收集反馈**
4. **记录过程**

#### 改进清单

- [ ] 修复发现的bug
- [ ] 优化移动端体验
- [ ] 添加新功能
- [ ] 定期更新内容
- [ ] 分享你的网站

#### 练习任务

写下你想做的3个改进

#### 检查点

你准备持续改进吗？

---

## 实践项目：一周行动计划

### 第1-2天

- [ ] 安装Hugo
- [ ] 创建第一个网站
- [ ] 配置网站标题和菜单

### 第3-4天

- [ ] 应用Kami设计
- [ ] 创建关于页面
- [ ] 写第一篇文章

### 第5-6天

- [ ] 导入5篇笔记
- [ ] 优化移动端
- [ ] 修复bug

### 第7天

- [ ] 推送到GitHub
- [ ] 部署到Cloudflare Pages
- [ ] 告诉朋友你的网站

---

## 总结：最重要的不是完美，而是开始

### 你学会了

- ✅ 使用Hugo搭建静态网站
- ✅ 应用Kami设计系统
- ✅ 组织和管理网站内容
- ✅ 部署网站到公网

### 下一步学习

- Hugo高级功能
- 自动化部署
- SEO优化
- 内容策略

### 记住

> 完美的个人网站不存在，只有不断进化的个人网站。

### 资源链接

- Hugo文档：https://gohugo.io/documentation/
- Kami设计：https://github.com/tw93/Kami
- Cloudflare Pages：https://developers.cloudflare.com/pages/
- 本教程源码：https://github.com/hongxiaojun/xiaojunhong-website
- 实际网站：https://xiaojunhong.space

---

**现在就开始吧！**

不要等明天，不要等下次，不要等"准备好了"。现在就开始。

你的数字家园在等你。

*P.S. 如果遇到问题，随时联系我：junqiaochen@gmail.com*
