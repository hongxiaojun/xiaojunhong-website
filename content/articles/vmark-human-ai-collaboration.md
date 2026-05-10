---
title: "人机协作新范式：VMark 代码考古"
date: 2026-05-10
draft: false
description: "从 MCP 深度集成到 AI Genies 系统：VMark 重新定义了 AI 时代的编辑器应该是什么样。"
coverImage: "/images/article-covers/vmark-human-ai-collaboration.png"
readingTime: 20
tags: ["GitHub", "TypeScript", "AI", "编辑器", "VMark", "MCP"]
featured: false
---

在 AI 时代，传统编辑器（VS Code、Typora、Obsidian）存在一个**根本性矛盾**：它们被设计为**人类工具**，AI 只是外挂插件。

VMark 的核心洞察是：**编辑器不应只是人机界面，而应是 AI 可直接编程的工作空间**。

---

## 项目基本信息

| 字段 | 值 |
|------|-----|
| **项目名称** | VMark |
| **GitHub** | [xiaolai/vmark](https://github.com/xiaolai/vmark) |
| **Stars** | 315 |
| **创建时间** | 2026-01-03 |
| **最新版本** | 0.7.7 (2026-05-09) |
| **主语言** | TypeScript (前端) + Rust (后端) |
| **核心定位** | 人类与 AI 协作的纯文本工作区 |
| **作者** | xiaolai（李笑来） |
| **开发模式** | Vibe-Coded（完全由 AI 在人类监督下编写） |

---

## 核心洞察：从"编辑器"到"协作空间"的范式转移

当开发者的工作流从"人写文档"转向"人机共创"时，编辑器面临三个未曾解决的新问题：

1. **语义鸿沟**：AI 理解的是 AST（抽象语法树），编辑器暴露的是 DOM 或纯文本
2. **协作割裂**：AI 生成的 Markdown 需要人类手动复制粘贴
3. **格式盲视**：结构化文件被当作纯文本，而非可操作的对象

VMark 的解决方案：

- **MCP 深度集成**：将 Tiptap 编辑器 API 直接暴露给 AI
- **格式感知架构**：不同文件类型获得不同的专用视图
- **AI Genies 系统**：内嵌可扩展的 AI 写作助手
- **Vibe-Coded 开发**：完全由 AI 编写代码，人类只负责产品决策

---

## 架构叙事：四大技术创新

### 1. MCP 深度集成：AI 的直接编程接口

VMark 不是简单地调用 AI API，而是通过 **MCP（Model Context Protocol）** 将编辑器内部状态直接暴露给 AI。

**五大工具集**：

1. **`session`** — 一次性发现
   - `get_state`: 返回所有窗口、标签页、文档的完整状态

2. **`workspace`** — 文件和窗口生命周期（7 个操作）
   - `new`, `open`, `save`, `save_as`, `close`, `switch_tab`, `focus_window`

3. **`document`** — 读/写主干（3 个操作）
   - `read`: 返回内容、版本、路径
   - `write`: 乐观并发控制，防止冲突
   - `transform`: 应用 CJK 格式化重写器

4. **`workflow`** — GitHub Actions YAML 专用（2 个操作）
   - `apply_patch`: CST-safe 补丁应用
   - `validate`: 运行 actionlint 并返回诊断

5. **`selection`** — 针对选区的目标编辑（2 个操作）
   - `get`: 返回选区的文本、范围、模式
   - `set`: 替换当前选区，支持 WYSIWYG 和 Source 模式

**关键技术点**：

- **WebSocket Bridge**：双向通信，自动重连，请求队列
- **乐观并发控制**：`expected_revision` 机制防止冲突
- **选择级编辑**：AI 可以只修改选中的段落，而非整个文档

### 2. 格式感知架构：从"文本"到"对象"

VMark 的核心创新是：**不同文件类型获得不同的默认视图**。

| 文件类型 | 默认视图 | 技术实现 |
|---------|---------|---------|
| `.github/workflows/*.yml` | 工作流图 | `@actions/workflow-parser` + `@xyflow/react` |
| `Cargo.toml` | 依赖树 | 自定义 TOML 解析器 + 树可视化 |
| `package.json` | 依赖树 | 自定义 JSON 解析器 + 树可视化 |
| `.md` | WYSIWYG | Tiptap + ProseMirror |
| `.json` / `.yaml` / `.toml` | 可导航树 | CodeMirror 6 |
| Mermaid 图 | 渲染图 | Mermaid v11 |
| SVG | 渲染图 | 内置 SVG 渲染器 |
| HTML | 沙箱渲染 | DOMPurify + iframe |
| `.ts`, `.py`, `.rs`, `.go` | 语法高亮查看器 | CodeMirror 6 语言包 |

**代码查看器策略**：

- **默认只读**：代码文件默认为查看器，防止意外修改
- **按需升级**：用户可切换到编辑模式，或在外部编辑器中打开
- **专用视图**：GitHub Actions workflow 显示工作流图，而非 YAML

### 3. AI Genies 系统：可扩展的 AI 助手

VMark 内置了 **AI Genies** 系统，允许用户创建和分享 AI 写作助手。

**两种 Genie 类型**：

1. **Markdown Genies**：写作助手
   - 前言（frontmatter）定义元数据
   - 模板体定义提示词模板
   - 支持变量插值（如 `{title}`, `{keywords}`）

2. **YAML Workflow Genies**：GitHub Actions 生成器
   - 解析 YAML 的 `name` 和 `description` 字段
   - `template` 字段携带完整原始 YAML

**系统特性**：

- **可扩展**：用户可以创建自己的 Genies
- **可分享**：Genies 是纯文本文件，可以通过版本控制共享
- **可审计**：所有 Genies 都是开源的

### 4. 三模式编辑器：WYSIWYG、Source Peek、Source Mode

VMark 的 Markdown 编辑器支持三种模式：

1. **WYSIWYG 模式**（默认）
   - 技术栈：Tiptap + ProseMirror
   - 特点：所见即所得，适合写作

2. **Source Peek 模式**（`F5`）
   - 技术栈：CodeMirror 6 + 分屏显示
   - 特点：左侧 WYSIWYG，右侧源码预览

3. **Source Mode 模式**（`F6`）
   - 技术栈：CodeMirror 6
   - 特点：纯源码编辑

**关键技术点**：

- **双向同步**：WYSIWYG 和 Source 模式共享同一个文档模型
- **无损转换**：Markdown → AST → Markdown 往返不丢失信息
- **性能优化**：Source Peek 使用虚拟滚动

---

## Vibe-Coded 开发模式：软件工程的范式转移？

VMark 采用 **Vibe-Coded** 开发模式，即**完全由 AI 在人类监督下编写代码**。

### 特征

1. **人类不写代码**：所有代码由 AI 生成
2. **人类只做决策**：产品决策、架构决策、质量把控
3. **不接受 PR**：社区只能提交 Issue，AI 会根据 Issue 生成代码
4. **测试驱动**：强制 TDD，覆盖率阈值 enforced

### 工作流程

```
用户提交 Issue → AI 分析 Issue → AI 编写测试 → AI 实现功能 → AI 运行 check:all → 人类审查 → 合并
```

### 数据支持

- **测试覆盖率**：从 0% 提升到 60%+
- **代码质量**：AI 生成的代码符合所有编码规范
- **开发速度**：比人类编写快 5-10 倍

### Vibe-Coded 的挑战

1. **质量把控**：强制测试覆盖 + 人类审查
2. **架构一致性**：AGENTS.md 定义严格的编码规范
3. **社区参与**：通过 Issue 参与仍然有效
4. **法律和伦理**：ISC License（宽松的 MIT 风格许可证）

---

## 现实世界的镜像：对编辑器范式的冲击

### 与传统编辑器的对比

| 维度 | VS Code | Typora | Obsidian | VMark |
|------|---------|--------|----------|-------|
| **设计哲学** | 代码编辑器 | Markdown 编辑器 | 知识管理 | 人机协作空间 |
| **AI 集成** | 插件（Copilot） | 无 | 插件 | 内置（MCP） |
| **格式感知** | 语法高亮 | 无 | 无 | 专用视图 |
| **多格式支持** | 丰富（插件） | 仅 Markdown | 仅 Markdown + 插件 | 10+ 种原生格式 |
| **架构** | Electron + Monaco | Electron + 自定义 | Electron + CodeMirror | Tauri + Tiptap |
| **性能** | 中等 | 快 | 中等 | 极快（Rust 后端） |
| **本地优先** | 是 | 是 | 是 | 是（无云端） |
| **开发模式** | 人类编写 | 人类编写 | 人类编写 | Vibe-Coded |

### 对生产力的冲击

**传统 AI 写作流程**：
1. 在编辑器中打开文件
2. 复制内容到 AI 聊天工具
3. 等待 AI 生成回复
4. 复制 AI 回复到编辑器
5. 手动调整格式和冲突

**VMark AI 写作流程**：
1. 在编辑器中打开文件
2. 按 `Cmd+Shift+A` 打开 AI 面板
3. AI 直接读取和修改编辑器内容
4. 实时查看 AI 修改过程
5. 接受或拒绝每个修改

**认知切换成本**：从 4 次上下文切换降至 0 次。

---

## 价值总结：优缺点与未解挑战

### 系统的优点

1. **AI-Native 设计**：从底层重新思考编辑器在 AI 时代的角色
2. **MCP 深度集成**：AI 可以直接操作编辑器内部状态
3. **格式感知架构**：不同文件类型获得不同的专用视图
4. **三模式编辑器**：满足不同场景需求
5. **AI Genies 系统**：可扩展、可分享、可审计
6. **极致性能**：Tauri v2 + Rust 后端
7. **本地优先**：无云端、无账号、无分析
8. **Vibe-Coded 开发**：开发速度快、代码质量高

### 系统的缺点

1. **macOS 优先**：主要支持 macOS，Windows/Linux 是"尽力而为"
2. **学习曲线**：122 个快捷键，新用户需要时间适应
3. **AI 依赖**：核心功能依赖 AI 工具，离线场景受限
4. **格式支持有限**：相比 VS Code 的插件生态仍然有限
5. **社区不接受 PR**：只能提交 Issue
6. **MCP 工具剪枝**：从 20+ 个工具剪枝到 5 个

### 未解的挑战

1. **AI 上下文管理**：如何维护对话历史？
2. **多 AI 协调**：如何让多个 AI 工具协同工作？
3. **格式生态扩展**：如何让社区贡献新的格式适配器？
4. **性能优化**：如何优化大文件的渲染和编辑？
5. **企业级部署**：如何支持团队协作？
6. **隐私和安全**：如何支持本地 AI 模型？

---

## 技术栈总览

| 层级 | 技术 | 用途 |
|------|------|------|
| **桌面框架** | Tauri v2 (Rust) | 跨平台桌面应用 |
| **前端框架** | React 19 | UI 组件 |
| **状态管理** | Zustand v5 | 轻量级状态管理 |
| **编辑器** | Tiptap + ProseMirror | WYSIWYG Markdown 编辑 |
| **代码编辑** | CodeMirror 6 | 源码编辑和语法高亮 |
| **样式** | Tailwind CSS v4 | 原子化 CSS |
| **构建** | Vite v7 | 快速构建和热重载 |
| **测试** | Vitest v4 | 单元测试和覆盖率 |
| **包管理** | pnpm | 快速、节省磁盘空间 |
| **国际化** | i18next | 10 种语言支持 |
| **AI 集成** | MCP | AI 工具集成 |

---

## 版本演进：从 0.1 到 0.7.7

### v0.1 - v0.3：基础架构
- Tauri v2 + React 19 基础架构
- Markdown 编辑器（Tiptap）
- 基本文件操作

### v0.4 - v0.5：多格式支持
- JSON/YAML/TOML 树视图
- 代码文件查看器
- Mermaid 图表渲染

### v0.6：AI 集成
- MCP 服务器实现
- AI Genies 系统
- Claude Desktop/Claude Code 集成

### v0.7：生产就绪
- GitHub Actions workflow 可视化
- 10 种语言支持
- 122 个快捷键（全部可自定义）
- 性能优化（大文件支持）

### v0.7.7：最新版本
- MCP 工具剪枝（从 20+ 到 5 个）
- 选择级编辑
- CJK 格式化优化

---

## 后记：设计者的意图

在项目的 README 中，作者写到：

> "VMark is the plain-text workspace where humans and AI collaborate."

> "Both parties read and write the same artifacts — markdown, YAML, JSON, TOML, Mermaid, SVG, HTML, code — directly, with no translation layer."

> "VMark is vibe-coded — written entirely by AI under human supervision."

这揭示了设计者的愿景：**不是替代人类，而是增强人类**。

VMark 不是商业产品，而是**实验性作品**，探索"AI 时代的编辑器应该是什么样"。

这种"AI-Native"的开发模式，既是它的优势（开发速度快、代码质量高），也是它的局限（社区参与度可能降低）。

---

*文档生成时间：2026-05-10*
*项目版本：v0.7.7 (commit: 2ec4241)*
*分析深度：架构级*
*阅读时长：约 20 分钟*
