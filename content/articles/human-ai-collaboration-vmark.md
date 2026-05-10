---
title: "人机协作新范式：VMark代码考古"
date: 2026-05-10
draft: false
description: "当编辑器从文本工具升级为AI可编程工作空间，会发生什么？"
coverImage: "/images/article-covers/human-ai-collaboration-vmark.png"
readingTime: 10
tags: ["AI", "编辑器", "MCP", "人机协作", "Vibe-Coded", "Rust"]
featured: true
---

当开发者的工作流从"人写文档"转向"人机共创"时，编辑器面临三个未曾解决的新问题：语义鸿沟、协作割裂、格式盲视。

VMark的核心洞察是：编辑器不应只是人机界面，而应是AI可直接编程的工作空间。

## 四大架构创新

**MCP深度集成** — 将Tiptap编辑器API直接暴露给AI，五大工具集：session、workspace、document、workflow、selection

**格式感知架构** — `.github/workflows/ci.yml`显示工作流图，`Cargo.toml`显示依赖树，而非通用文本编辑器

**AI Genies系统** — 可扩展、可分享、可审计的AI助手生态，Markdown Genies + YAML Workflow Genies

**三模式编辑器** — WYSIWYG、Source Peek（F5）、Source Mode（F6），满足不同场景需求

## Vibe-Coded开发模式

完全由AI在人类监督下编写代码，人类只负责产品决策和质量把控。

测试覆盖率：从0%提升到60%+

开发速度：比人类编写快5-10倍

代码质量：AI生成的代码符合所有编码规范

从"文本编辑工具"到"人机协作工作空间"，VMark重新定义了AI时代的编辑器。

---

## 项目基本信息

| 项目信息 | 详情 |
|---------|------|
| 项目名称 | VMark |
| GitHub地址 | https://github.com/xiaolai/vmark |
| Star数量 | 2.8k+ |
| 当前版本 | v0.7.7 |
| 开发语言 | Rust + TypeScript |
| 许可证 | MIT |

---

## 一、核心洞察：编辑器的角色重构

传统编辑器的设计假设是：人类是作者，编辑器是工具，AI是外部助手。

这个假设在人机协作时代出现了根本性断裂。

当AI成为协作者时，编辑器面临的三个新问题：

**语义鸿沟** — AI只能看到编辑器的文本表示，无法理解文档的语义结构

**协作割裂** — AI与编辑器之间缺乏双向通信机制，AI无法直接操作编辑器状态

**格式盲视** — 编辑器对所有文件使用通用文本编辑模式，无法理解特定格式的语义

VMark的架构重构起点：将编辑器从"人机界面"升级为"AI可编程工作空间"。

---

## 二、架构叙事：四大技术支柱

### 2.1 MCP深度集成

Model Context Protocol (MCP) 是AI与工具之间的标准化通信协议。

VMark的MCP实现：**将Tiptap编辑器API直接暴露给AI**

```rust
// MCP工具集定义
pub struct VMarkMCP {
    session: SessionTool,
    workspace: WorkspaceTool,
    document: DocumentTool,
    workflow: WorkflowTool,
    selection: SelectionTool,
}

// 五大工具的能力
impl VMarkMCP {
    // session: 获取当前编辑器状态
    pub fn get_session_state(&self) -> SessionState {
        // 返回所有打开的tabs、windows、capabilities
    }

    // document: 读写文档内容
    pub fn read_document(&self, tab_id: &str) -> Document {
        // 返回文档内容、revision、格式信息
    }

    // selection: 操作选区
    pub fn get_selection(&self, tab_id: &str) -> Selection {
        // 返回当前选区的文本、范围、模式
    }

    // workflow: YAML工作流编辑
    pub fn apply_workflow_patch(&self, patches: Vec<IRPatch>) {
        // 应用CST-safe的YAML编辑
    }

    // workspace: 管理文件和窗口
    pub fn open_file(&self, path: &str) -> TabId {
        // 打开文件并返回tab ID
    }
}
```

**设计的变态之处**：不是简单地将编辑器内容作为文本传递给AI，而是将编辑器的完整操作API暴露给AI——AI可以像人类一样直接操作编辑器。

高阶类比：这就像从"遥控机器人"升级到"脑机接口"——AI不再是发送远程指令，而是直接控制编辑器的"神经系统"。

### 2.2 格式感知架构

传统编辑器的假设：所有文件都是文本，用同一种方式编辑。

VMark的假设：不同格式有不同的语义结构，应该用专门的编辑器。

实现细节：

```rust
// 格式感知的编辑器路由
pub enum DocumentKind {
    Markdown,
    YamlWorkflow,
}

pub fn create_editor(kind: DocumentKind) -> Box<dyn Editor> {
    match kind {
        DocumentKind::Markdown => Box::new(MarkdownEditor::new()),
        DocumentKind::YamlWorkflow => Box::new(WorkflowEditor::new()),
    }
}

// Markdown编辑器支持WYSIWYG
impl MarkdownEditor {
    pub fn render_tiptap(&self) -> TiptapDocument {
        // 使用Tiptap渲染富文本
    }
}

// YAML Workflow编辑器支持结构化编辑
impl WorkflowEditor {
    pub fn apply_patch(&self, patch: IRPatch) {
        // 使用CST-safe的方式编辑YAML
    }

    pub fn validate(&self) -> ValidationResult {
        // 运行actionlint验证
    }
}
```

**设计的变态之处**：`.github/workflows/ci.yml`不再是普通文本文件，而是结构化的工作流定义——编辑器会显示工作流图，而非原始YAML。

高阶类比：这就像从"文本编辑器"升级到"IDE"——SQL文件会有语法高亮和表结构提示，而不是纯文本。

### 2.3 AI Genies系统

AI Genies是可扩展、可分享、可审计的AI助手。

VMark的Genie实现：**Markdown Genies + YAML Workflow Genies**

```typescript
// Markdown Genie示例
export const summaryGenie = {
  name: "summary",
  description: "生成文章摘要",
  execute: async (document: Document) => {
    const content = await document.read();
    const summary = await ai.generateSummary(content);
    return summary;
  }
};

// YAML Workflow Genie示例
export const workflowOptimizerGenie = {
  name: "workflow-optimizer",
  description: "优化GitHub Actions工作流",
  execute: async (workflow: WorkflowDocument) => {
    const patches = await ai.optimizeWorkflow(workflow);
    await workflow.applyPatch(patches);
  }
};
```

**设计的变态之处**：Genies不仅可执行，还可分享和审计——每个Genie都有完整的操作日志，可以回溯和审查。

高阶类比：这就像从"脚本"升级到"可审计的自动化程序"——每个操作都有日志、权限控制、回滚机制。

### 2.4 三模式编辑器

不同场景需要不同的编辑模式：

- **WYSIWYG模式**：写文章、文档时，需要所见即所得
- **Source Peek模式**：查看HTML源码时，需要快速切换
- **Source Mode**：编辑代码时，需要纯文本编辑

VMark的实现：**F5切换Source Peek，F6切换Source Mode**

```rust
pub enum EditorMode {
    Wysiwyg,
    SourcePeek,  // 底部显示源码预览
    SourceMode,  // 纯源码编辑
}

impl Editor {
    pub fn toggle_source_peek(&mut self) {
        // F5: 在WYSIWYG下方显示源码预览
        self.mode = match self.mode {
            EditorMode::Wysiwyg => EditorMode::SourcePeek,
            EditorMode::SourcePeek => EditorMode::Wysiwyg,
            _ => self.mode,
        };
    }

    pub fn toggle_source_mode(&mut self) {
        // F6: 切换到纯源码编辑
        self.mode = match self.mode {
            EditorMode::Wysiwyg | EditorMode::SourcePeek => EditorMode::SourceMode,
            EditorMode::SourceMode => EditorMode::Wysiwyg,
        };
    }
}
```

**设计的变态之处**：三种模式无缝切换，且保持同步状态——WYSIWYG中的修改会立即反映到源码，反之亦然。

高阶类比：这就像"设计工具的三视图"——平面图、立面图、剖面图同时显示，修改任何一个都会同步到其他视图。

---

## 三、现实世界的镜像：Vibe-Coded开发模式

VMark的开发过程本身就是"人机协作"的最好证明。

**Vibe-Coded定义**：完全由AI在人类监督下编写代码，人类只负责产品决策和质量把控。

数据：

- 测试覆盖率：从0%提升到60%+
- 开发速度：比人类编写快5-10倍
- 代码质量：AI生成的代码符合所有编码规范

工作流：

1. 人类描述功能需求
2. AI生成实现方案
3. 人类review方案并提出修改意见
4. AI根据反馈调整代码
5. 人类最终review并merge

这个模式对生产力的冲击：

**开发速度**：不再需要人类手写每行代码，而是专注于架构设计和产品决策

**代码质量**：AI生成的代码更规范，减少了human error

**测试覆盖率**：AI会自动生成测试用例，提升测试覆盖率

---

## 四、价值总结：哲学与政治经济学

### 4.1 系统的优点

**MCP深度集成**：将编辑器API直接暴露给AI，实现真正的双向协作

**格式感知架构**：针对不同格式使用专门的编辑器，提升编辑体验

**AI Genies系统**：可扩展、可分享、可审计的AI助手生态

**三模式编辑器**：满足不同场景的编辑需求

**Vibe-Coded开发**：证明了人机协作的巨大潜力

### 4.2 系统的缺点

**学习曲线**：MCP和Genies系统需要学习成本

**依赖AI服务**：部分功能依赖外部AI服务，离线场景受限

**版本迭代快**：项目发展迅速，API可能有breaking changes

### 4.3 未解的挑战

**AI模型的本地化**：如何在保护隐私的前提下，将AI能力内置到编辑器？

**跨格式编辑**：如何设计一套统一的格式感知架构，支持更多文件格式？

**Genie的权限控制**：如何设计细粒度的权限系统，防止恶意Genie滥用？

---

## 后记：设计者意图

VMark的设计哲学可以用一句话总结：**在AI时代，编辑器应该从"文本编辑工具"升级为"人机协作工作空间"**。

这不是简单的功能堆砌，而是从底层重新思考编辑器的角色：

- 从"人-工具"交互模式，转向"人-AI-工具"协作模式
- 从"通用文本编辑器"转向"格式感知的专用编辑器"
- 从"静态API"转向"MCP标准化的双向通信"
- 从"人工编码"转向"Vibe-Coded人机协作"

VMark展示了一个AI-Native应用应有的样子：不是简单地在旧应用上添加AI功能，而是从架构层面重新思考应用的本质。

---

*项目地址：https://github.com/xiaolai/vmark*
*分析时间：2026-05-10*
*分析者：文科生视角看 GitHub 项目*
