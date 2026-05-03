# 播客板块使用指南

## 功能特性

✅ **完整的播客系统**
- 播客列表页面
- 单个播客播放页面
- 内置音频播放器
- 下载功能
- 上下期导航

✅ **支持的音频格式**
- MP3 (推荐)
- WAV
- M4A
- OGG

✅ **UI 设计**
- 与 Kami 纸质感设计风格完美匹配
- 响应式设计，支持移动端
- 暗色模式支持

## 如何添加新播客

### 1. 准备音频文件

将音频文件放到 `static/podcasts/` 目录：

```bash
static/podcasts/
├── 001-welcome.mp3
├── 002-tech-talk.mp3
└── 003-life-lesson.mp3
```

### 2. 创建播客内容文件

在 `content/podcasts/` 目录创建 markdown 文件：

```yaml
---
title: "第002期：技术分享"
date: 2026-05-04
draft: false
description: "分享一些技术心得和经验"
episode: "EP.002"
duration: "15:30"
audio_file: "/podcasts/002-tech-talk.mp3"
audio_size: "15.2 MB"
audio_format: "mp3"
tags: ["技术", "分享"]
---

# 第002期：技术分享

## 本期内容

- 技术心得
- 经验分享
- 学习建议

## 相关链接

- [相关文章](https://...)
- [参考资源](https://...)
```

### 3. 字段说明

| 字段 | 必填 | 说明 |
|------|------|------|
| `title` | ✅ | 播客标题 |
| `date` | ✅ | 发布日期 |
| `description` | ✅ | 播客描述 |
| `episode` | ⭕ | 集数标识（如：EP.001） |
| `duration` | ✅ | 音频时长（如：10:30） |
| `audio_file` | ✅ | 音频文件路径 |
| `audio_size` | ✅ | 文件大小（如：5.2 MB） |
| `audio_format` | ✅ | 音频格式（mp3/wav/m4a/ogg） |
| `tags` | ⭕ | 标签列表 |

## 音频文件优化建议

### 音频质量设置

- **比特率**: 128kbps (语音) 或 192kbps (音乐)
- **采样率**: 44.1kHz
- **声道**: 单声道可减小 50% 文件大小
- **格式**: MP3 提供最佳兼容性和压缩率

### 使用 FFmpeg 压缩音频

```bash
# 安装 FFmpeg
brew install ffmpeg

# 压缩为 128kbps MP3
ffmpeg -i input.wav -b:a 128k output.mp3

# 转换为单声道
ffmpeg -i input.wav -ac 1 -b:a 128k output.mp3

# 显示音频信息
ffmpeg -i input.mp3
```

### 在线工具

- **Audio Converter**: https://cloudconvert.com/
- **FreeConvert**: https://freeconvert.com/
- **Online Audio Converter**: https://online-audio-converter.com/

## 访问播客板块

- **播客列表**: https://www.xiaojunhong.space/podcasts/
- **单集播放**: https://www.xiaojunhong.space/podcasts/001-welcome/

## 文件结构

```
xiaojunhong-website/
├── content/
│   └── podcasts/
│       ├── _index.md          # 播客列表页
│       ├── 001-welcome.md     # 第1期
│       └── 002-tech-talk.md   # 第2期
├── static/
│   └── podcasts/
│       ├── README.md          # 音频文件说明
│       ├── 001-welcome.mp3    # 音频文件
│       └── 002-tech-talk.mp3
└── layouts/
    └── podcasts/
        ├── list.html          # 列表页模板
        └── single.html        # 单页模板
```

## UI 设计特色

### 播客列表页
- 卡片式布局，与 Notes 板块风格一致
- 显示集数、标题、描述、时长、格式
- 悬停效果和播放按钮
- 标签展示

### 单集播放页
- 大标题显示
- 集数徽章
- 内置音频播放器（浏览器原生）
- 下载按钮
- 播放提示
- 上下期导航

### 颜色方案
- 使用 Kami 品牌色（墨蓝色渐变）
- 纸质感背景
- 暖色调边框
- 暗色模式完整支持

## 测试本地预览

```bash
# 启动开发服务器
hugo server

# 访问播客页面
open http://localhost:1313/podcasts/
```

## 发布新播客

```bash
# 1. 添加音频文件到 static/podcasts/
# 2. 创建播客 markdown 文件
# 3. 测试本地预览
hugo server

# 4. 提交更改
git add .
git commit -m "Add new podcast episode"
git push

# 5. 等待 Cloudflare Pages 自动部署
```

## 注意事项

⚠️ **文件大小**
- 音频文件会占用网站存储空间
- 建议单集不超过 50MB
- 定期检查和优化文件大小

⚠️ **版权问题**
- 确保使用自有内容或授权内容
- 标注音乐和音效的来源

⚠️ **SEO 优化**
- 每期播客都会自动生成页面
- 适合搜索引擎索引
- 建议添加详细的描述和标签

## 未来增强功能

可选的增强功能：
- [ ] 播客 RSS 订阅
- [ ] 播放进度记录
- [ ] 播放列表功能
- [ ] 评论系统
- [ ] 分享按钮
- [ ] 下载统计
- [ ] 音频波形可视化

## 技术支持

如有问题，请查看：
- Hugo 文档: https://gohugo.io/
- 音频处理: FFmpeg 官方文档
- 项目 README: `/README.md`
