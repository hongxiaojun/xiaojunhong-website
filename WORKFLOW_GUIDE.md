# 双 AI 协同工作流使用指南

## 🎯 工作流概述

这是一套完整的"双 AI 协同"内容生产系统，结合了 Claude Code 和 Gemini App 的优势：

### 角色分工

**Claude Code（主笔兼架构师）**
- ✅ 深度总结材料核心逻辑
- ✅ 设计文章架构和行文逻辑
- ✅ 识别缺失的数据和案例
- ✅ 组装最终文章并发布

**Gemini App（研究员兼事实核查员）**
- ✅ 多维检索验证数据
- ✅ 扩充故事和案例素材
- ✅ 探索跨界应用场景
- ✅ 自我审稿确保事实准确

## 🚀 快速开始

### 方式一：使用 Python 脚本

```bash
# 进入网站目录
cd /Users/add/xiaojunhong-website

# 查看帮助
python workflow_manager.py --help

# 阶段1：开始新文章（输入原始材料）
python workflow_manager.py --stage1 "你的原始材料"

# 阶段2：生成 Gemini 调研任务书
python workflow_manager.py --stage2

# 阶段3：接收 Gemini 调研结果
python workflow_manager.py --stage3 "Gemini的回复内容"

# 查看状态
python workflow_manager.py --status

# 重置工作流
python workflow_manager.py --reset
```

### 方式二：交互式模式

```bash
python workflow_manager.py
```

然后按提示选择操作。

### 方式三：使用 Claude Code 技能

在你的项目中可以直接使用 `/workflow` 命令启动工作流。

## 📋 完整工作流程

### 阶段 1：架构设计（Claude Code）

**输入**：原始文章、观点、想法

**Claude Code 的任务**：
1. 深度总结材料核心逻辑
2. 设计文章架构（大纲）
3. 识别需要验证的数据点
4. 列出需要的故事/案例类型
5. 发现跨界应用场景

**输出**：
- 文章标题建议
- 核心观点总结
- 完整文章架构
- Gemini 协同任务书

**示例输入**：
```
最近看了罗翔的采访，他说"熟能生巧是颠扑不破的真理"。
他一年讲课50-60次，每场重要讲座都写几万字逐字稿。
F1赛车换胎只需1.82秒，罗振宇十年每天60秒语音。
这些"毫不费力的卓越"都是怎么练出来的？
```

### 阶段 2：素材调研（Gemini App）

**输入**：Claude Code 生成的协同任务书

**Gemini App 的任务**：
1. 验证所有数据、历史事件
2. 扩充商业案例、历史事件、人物故事
3. 探索跨界应用场景
4. 检查逻辑漏洞
5. 自我审稿确保准确性

**输出要求**：
- 所有数据标注来源
- 所有案例有明确出处
- 语言风格深入浅出
- 逻辑链条完整

**自我审稿清单**：
- [ ] 所有数据都经过验证
- [ ] 所有案例都有明确来源
- [ ] 没有编造或推测的内容
- [ ] 语言风格深入浅出、精炼
- [ ] 逻辑链条完整

### 阶段 3：内容组装（Claude Code）

**输入**：
- 原始架构
- Gemini 调研素材

**Claude Code 的任务**：
1. 无缝融合架构和素材
2. 确保逻辑连贯
3. 生成完整 Markdown 文章
4. 保持深入浅出的风格

**输出**：
- 完整的文章内容（Markdown 格式）
- 准备发布的文章文件

### 阶段 4：自动发布

**自动执行**：
1. 生成文章文件名
2. 创建 Front Matter（标题、日期、标签等）
3. 写入文件到 `content/articles/`
4. Git 提交
5. 询问是否推送（触发 Cloudflare Pages 自动部署）

**文章文件位置**：
```
xiaojunhong-website/content/articles/文章标题.md
```

**发布命令**：
```bash
# 文章会自动提交到 Git
git add content/articles/文章标题.md
git commit -m "Add article: 文章标题"
git push  # 手动推送，触发自动部署
```

## 📝 文章格式规范

### Front Matter 模板

```yaml
---
title: "文章标题"
date: 2026-05-23
draft: false
description: "文章描述（用于 SEO 和分享）"
readingTime: 6
tags: ["标签1", "标签2", "标签3"]
featured: true  # 是否为精选文章
---
```

### 内容结构建议

```markdown
## 引言
- 背景/引入点
- 核心问题

## 核心观点
- 方法论/原理阐述
- 关键论据

## 案例支撑
- 案例1：具体说明
- 案例2：强化论证

## 跨界应用
- 应用场景1
- 应用场景2

## 行动建议
- 读者可以怎么做

## 结语
- 总结升华
```

## 🎨 写作风格指南

### 核心原则

**深入浅出**
- 用简练语言解释复杂概念
- 用具体案例说明抽象观点
- 用生动比喻帮助理解

**精炼重点突出**
- 每节一个核心观点
- 用小标题明确结构
- 用列表和表格总结要点

**事实准确**
- 所有数据标注来源
- 所有案例有据可查
- 避免推测和夸张

### 语言技巧

1. **用问句引发思考**
   ```
   这些"毫不费力的卓越"都是怎么练出来的？
   ```

2. **用数据支撑观点**
   ```
   F1赛车换胎只需1.82秒，20个人不到2秒完成四轮更换。
   ```

3. **用对比强化论证**
   ```
   | 非工程化 | 工程化 |
   |---------|--------|
   | 凭感觉 | 有标准 |
   ```

4. **用引用增加权威性**
   ```
   > "熟能生巧是颠扑不破的真理。" —— 罗翔
   ```

## 🔧 高级技巧

### 1. 批量生产文章

```bash
# 准备多个原始材料文件
mkdir workflow-materials
echo "材料1" > material1.txt
echo "材料2" > material2.txt

# 批量启动工作流
for file in workflow-materials/*.txt; do
  python workflow_manager.py --stage1 "$(cat $file)"
done
```

### 2. 自定义文章模板

编辑 `workflow_manager.py` 中的 `_generate_front_matter()` 方法：

```python
def _generate_front_matter(self, title: str, content: str,
                           tags: List[str], description: str,
                           featured: bool) -> str:
    # 自定义你的默认 Front Matter
    custom_categories = ["思考", "方法", "案例"]
    # ...
```

### 3. 集成到现有工作流

```bash
# 添加到你的 .zshrc
alias workflow='cd /Users/add/xiaojunhong-website && python workflow_manager.py'
alias wf='workflow'

# 使用
wf --stage1 "新材料"
```

### 4. 自动化发布流程

```bash
# 创建自动发布脚本
cat > auto-publish.sh << 'EOF'
#!/bin/bash
cd /Users/add/xiaojunhong-website
python workflow_manager.py --stage1 "$1"
python workflow_manager.py --stage2
# 等待 Gemini 回复...
# python workflow_manager.py --stage3 "$2"
# python workflow_manager.py --stage4
EOF

chmod +x auto-publish.sh

# 使用
./auto-publish.sh "原始材料"
```

## 📊 工作流状态管理

工作流状态保存在 `.workflow-state/current_workflow.json`

```json
{
  "stage": "architecting",
  "content_type": "article",
  "title": "",
  "original_material": "...",
  "architecture": "",
  "gemini_prompt": "",
  "gemini_response": "",
  "final_content": "",
  "created_at": "2026-05-23T12:00:00",
  "file_path": null
}
```

### 状态说明

- `idle`: 空闲
- `architecting`: 架构设计中
- `researching`: Gemini 调研中
- `writing`: 内容组装中
- `published`: 已发布

## 🐛 故障排除

### 问题 1：Hugo 未安装

```bash
# 安装 Hugo
brew install hugo

# 验证安装
hugo version
```

### 问题 2：Git 权限问题

```bash
# 配置 Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 问题 3：工作流卡住

```bash
# 重置工作流
python workflow_manager.py --reset

# 或手动删除状态文件
rm .workflow-state/current_workflow.json
```

### 问题 4：Cloudflare Pages 未自动部署

检查：
1. GitHub webhook 配置
2. Cloudflare Pages 构建设置
3. 构建日志查看错误

## 📚 参考资料

### Claude Code 文档
- https://docs.anthropic.com/claude-code

### Gemini App 文档
- https://gemini.google.com/app

### Hugo 文档
- https://gohugo.io/documentation/

### Cloudflare Pages 文档
- https://developers.cloudflare.com/pages

## 🎓 最佳实践

### 1. 素材积累

- 随时记录灵感
- 使用统一的素材格式
- 定期整理素材库

### 2. 质量控制

- 每篇文章都要经过 Gemini 事实核查
- 重要文章要多次打磨
- 建立自己的检查清单

### 3. 时间管理

- 阶段1（架构）：15-30分钟
- 阶段2（调研）：30-60分钟
- 阶段3（组装）：30-60分钟
- 阶段4（发布）：5分钟

总计：1.5-2.5小时/篇文章

### 4. 迭代优化

- 记录每次工作流的改进点
- 优化自己的提示词
- 建立个人化的模板库

## 🚀 下一步

1. **试运行**：用一篇简单的材料测试完整流程
2. **优化提示词**：根据结果调整 Claude 和 Gemini 的提示
3. **建立素材库**：创建个人化的素材管理系统
4. **批量生产**：建立稳定的内容生产节奏

---

**开始你的双 AI 协同创作之旅！** 🎉

有问题？查看故障排除或参考 Claude Code / Gemini App 官方文档。
