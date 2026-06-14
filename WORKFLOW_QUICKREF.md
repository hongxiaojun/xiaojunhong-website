# 双 AI 协同工作流 - 快速参考

## 🚀 一分钟上手

```bash
# 进入网站目录
cd /Users/add/xiaojunhong-website

# 启动工作流（交互式）
python workflow_manager.py
```

## 📋 四阶段工作流

```
原始材料 → [Claude Code] → 架构 + 任务书
                              ↓
                          [Gemini App] → 调研 + 验证
                              ↓
                          [Claude Code] → 组装文章
                              ↓
                          [自动发布] → 推送网站
```

## 💡 快捷命令

```bash
# 查看状态
python workflow_manager.py --status

# 重置工作流
python workflow_manager.py --reset

# 创建文章
python workflow_manager.py --stage1 "你的材料"
python workflow_manager.py --stage2
python workflow_manager.py --stage3 "Gemini回复"

# 或使用别名（需配置）
wf --status
wf --reset
```

## 🎯 核心提示词

### Claude Code（架构设计）
```
你是主笔兼架构师。请分析材料：
1. 深度总结核心逻辑
2. 设计文章架构
3. 识别缺失数据/案例
4. 生成 Gemini 调研任务书
```

### Gemini App（素材调研）
```
你是研究员兼事实核查员。
1. 验证所有数据、事件
2. 扩充案例和故事
3. 探索跨界应用
4. 自我审稿确保准确
```

### Claude Code（内容组装）
```
你是主笔。组装完整文章：
1. 融合架构和素材
2. 确保逻辑连贯
3. 保持深入浅出
4. 生成 Markdown 文章
```

## 📁 文件位置

- 工作流管理器：`workflow_manager.py`
- 使用指南：`WORKFLOW_GUIDE.md`
- 状态文件：`.workflow-state/current_workflow.json`
- 文章目录：`content/articles/`
- 笔记目录：`content/notes/`

## ⚙️ 配置别名

```bash
# 添加到 ~/.zshrc
alias wf='cd /Users/add/xiaojunhong-website && python workflow_manager.py'
alias website='cd /Users/add/xiaojunhong-website'

# 使用
wf --stage1 "新材料"
```

## 🎨 文章格式

```yaml
---
title: "文章标题"
date: 2026-05-23
description: "文章描述"
readingTime: 6
tags: ["标签1", "标签2"]
featured: true
---

## 引言
内容...

## 核心观点
内容...
```

## 🐛 常见问题

**问题**：工作流卡住
```bash
python workflow_manager.py --reset
```

**问题**：Hugo 未安装
```bash
brew install hugo
```

**问题**：未自动部署
```bash
git push  # 手动推送触发 Cloudflare Pages
```

## 📊 时间估算

- 阶段1（架构）：15-30分钟
- 阶段2（调研）：30-60分钟
- 阶段3（组装）：30-60分钟
- 阶段4（发布）：5分钟

**总计**：1.5-2.5小时/篇

## 🎓 最佳实践

1. **素材积累**：随时记录灵感
2. **质量控制**：必经 Gemini 事实核查
3. **时间管理**：建立稳定生产节奏
4. **迭代优化**：持续改进提示词

---

**详细指南**：查看 `WORKFLOW_GUIDE.md`
