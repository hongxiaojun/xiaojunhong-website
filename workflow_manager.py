#!/opt/homebrew/bin/python3
"""
双 AI 协同工作流管理器
Claude Code (项目经理/主笔) + Gemini App (研究员/事实核查员)

工作流：
1. Claude 分析原始材料 → 生成架构和 Gemini 协同任务书
2. Gemini 接收任务书 → 检索验证数据 → 扩充素材
3. Claude 接收素材 → 组装成文 → 自动发布到网站
"""

import os
import sys
import json
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

# 配置
WEBSITE_ROOT = Path("/Users/add/xiaojunhong-website")
ARTICLES_DIR = WEBSITE_ROOT / "content" / "articles"
NOTES_DIR = WEBSITE_ROOT / "content" / "notes"
WORKFLOW_STATE_DIR = WEBSITE_ROOT / ".workflow-state"
STATE_FILE = WORKFLOW_STATE_DIR / "current_workflow.json"

class Colors:
    """终端颜色"""
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    END = '\033[0m'
    BOLD = '\033[1m'

def print_header(text: str):
    """打印标题"""
    print(f"\n{Colors.HEADER}{Colors.BOLD}{'='*60}{Colors.END}")
    print(f"{Colors.HEADER}{Colors.BOLD}{text.center(60)}{Colors.END}")
    print(f"{Colors.HEADER}{Colors.BOLD}{'='*60}{Colors.END}\n")

def print_step(step: str, description: str):
    """打印步骤"""
    print(f"{Colors.CYAN}➜ {step}{Colors.END}")
    print(f"  {description}\n")

def print_success(text: str):
    """打印成功信息"""
    print(f"{Colors.GREEN}✓ {text}{Colors.END}")

def print_warning(text: str):
    """打印警告"""
    print(f"{Colors.YELLOW}⚠ {text}{Colors.END}")

def print_error(text: str):
    """打印错误"""
    print(f"{Colors.RED}✗ {text}{Colors.END}")

def print_info(text: str):
    """打印信息"""
    print(f"{Colors.BLUE}ℹ {text}{Colors.END}")

class WorkflowState:
    """工作流状态管理"""

    def __init__(self):
        self.state = {
            "stage": "idle",  # idle, architecting, researching, writing, publishing
            "content_type": "",  # article, note
            "title": "",
            "original_material": "",
            "architecture": "",
            "gemini_prompt": "",
            "gemini_response": "",
            "final_content": "",
            "created_at": None,
            "file_path": None
        }
        self.load()

    def load(self):
        """加载状态"""
        if STATE_FILE.exists():
            try:
                with open(STATE_FILE, 'r', encoding='utf-8') as f:
                    self.state = json.load(f)
            except:
                pass

    def save(self):
        """保存状态"""
        WORKFLOW_STATE_DIR.mkdir(exist_ok=True)
        with open(STATE_FILE, 'w', encoding='utf-8') as f:
            json.dump(self.state, f, ensure_ascii=False, indent=2)

    def reset(self):
        """重置状态"""
        if STATE_FILE.exists():
            STATE_FILE.unlink()
        self.__init__()

class WorkflowManager:
    """工作流管理器"""

    def __init__(self):
        self.state = WorkflowState()
        self.verify_setup()

    def verify_setup(self):
        """验证环境设置"""
        if not WEBSITE_ROOT.exists():
            print_error(f"网站目录不存在: {WEBSITE_ROOT}")
            sys.exit(1)

        if not ARTICLES_DIR.exists():
            print_error(f"文章目录不存在: {ARTICLES_DIR}")
            sys.exit(1)

        # 检查 Hugo
        try:
            subprocess.run(['hugo', 'version'],
                         capture_output=True, check=True)
        except:
            print_warning("Hugo 未安装，发布功能可能不可用")

    def stage1_architect(self, material: str, content_type: str = "article"):
        """
        阶段1：架构设计
        Claude 分析原始材料，生成文章架构和 Gemini 协同任务书
        """
        print_header("阶段 1：架构设计")
        print_step("Claude Code 主笔", "分析材料、设计架构、生成协同任务书")

        self.state.state['stage'] = "architecting"
        self.state.state['content_type'] = content_type
        self.state.state['original_material'] = material
        self.state.state['created_at'] = datetime.now().isoformat()
        self.state.save()

        print_info("正在分析原始材料...")
        print_info(f"内容类型: {content_type}")
        print("\n原始材料:")
        print("-" * 60)
        print(material)
        print("-" * 60)

        # 这里应该由 Claude 分析材料，现在生成提示词
        print_warning("\n🤔 请让 Claude Code 分析上述材料，生成以下内容：")
        print("\n1. 文章标题")
        print("2. 核心观点总结")
        print("3. 文章架构（大纲）")
        print("4. 需要 Gemini 验证的数据点")
        print("5. 需要的故事/案例素材")
        print("6. 可能的跨界应用场景")

        return True

    def stage2_gemini_research(self) -> str:
        """
        阶段2：Gemini 调研
        生成发给 Gemini 的调研提示词
        """
        print_header("阶段 2：Gemini 调研")

        if self.state.state['stage'] != "architecting":
            print_error("请先完成阶段 1（架构设计）")
            return ""

        # 生成 Gemini 调研提示词模板
        gemini_prompt = f"""# Gemini 协同任务书

## 原始材料
{self.state.state['original_material']}

## 当前架构
（请在此处填写 Claude Code 生成的文章架构）

## 你的任务
你是资深事实核查员兼高级研究员。请根据上述材料补充以下内容：

### 1. 数据验证
- 列出文章中所有需要验证的数据、历史事件、人物言论
- 对每个数据点，提供：
  - 准确的数值/事实
  - 可靠的来源（学术论文、权威媒体报道、官方记录）
  - 如果数据有争议，说明不同观点

### 2. 故事/案例扩充
- 为文章核心观点寻找生动的案例
- 案例类型：
  - 商业案例（成功/失败故事）
  - 历史事件
  - 人物故事
  - 科技发展案例
  - 跨界应用实例
- 每个案例需包含：背景、过程、结果、启示

### 3. 跨界应用
- 这个方法论/观点还能应用在哪些领域？
- 提供 3-5 个具体的应用场景
- 说明为什么适用，以及可能的挑战

### 4. 逻辑漏洞检测
- 检查文章逻辑是否存在漏洞
- 指出可能的反驳观点
- 建议如何强化论证

## 输出要求
1. **严格事实核查**：所有数据、案例必须真实可考
2. **深入浅出**：保持精炼、重点突出的风格
3. **结构清晰**：分节输出，便于后续组装
4. **标注来源**：重要数据和案例注明信息来源

## 自我审稿清单（输出前必须检查）
- [ ] 所有数据都经过验证
- [ ] 所有案例都有明确来源
- [ ] 没有编造或推测的内容
- [ ] 语言风格匹配"深入浅出、精炼"的要求
- [ ] 逻辑链条完整，没有明显漏洞

请开始你的调研工作。
"""

        self.state.state['gemini_prompt'] = gemini_prompt
        self.state.save()

        print_success("Gemini 调研提示词已生成！\n")
        print("=" * 60)
        print(gemini_prompt)
        print("=" * 60)

        print_warning("\n📋 请复制上述提示词到 Gemini App")
        print_info("等待 Gemini 完成调研后，运行: python workflow_manager.py --stage3")

        return gemini_prompt

    def stage3_assemble(self, gemini_response: str):
        """
        阶段3：内容组装
        使用 writing-coach 技能接收 Gemini 的调研结果，组装成最终文章
        """
        print_header("阶段 3：内容组装（使用 writing-coach 技能）")
        print_step("Writing Coach", "接收调研素材、系统化组装、六重质量检查")

        if self.state.state['stage'] != "architecting":
            print_error("请先完成阶段 1（架构设计）")
            return False

        self.state.state['stage'] = "writing"
        self.state.state['gemini_response'] = gemini_response
        self.state.save()

        print_info("Gemini 调研素材已接收")
        print_warning("\n📝 请使用 /writing-coach 技能执行以下任务：")
        print("\nWriting Coach 将执行：")
        print("1. 【阶段1】提炼核心 + 感知框架搭建")
        print("2. 【阶段2】初稿生成 + 感知传递检查")
        print("3. 【阶段3】迭代优化 + 修辞正义检查")
        print("4. 【阶段4】六重质量检查：")
        print("   - Fact-Check（事实核查）")
        print("   - 去AI味检查")
        print("   - 感知传递质量检查")
        print("   - 逻辑关系质量检查")
        print("   - 修辞正义检查")
        print("   - HKR+R内容质量检查")
        print("5. 【阶段5】最终润色 + 网页格式排版")
        print("6. 【最高准则】'你会这样跟一个聪明的朋友说话吗？'")

        print_success("\nWriting Coach 质量保障：")
        print("- ✅ 传递感知核心思想")
        print("- ✅ HKR+R质量理念（快乐、知识、共鸣、节奏）")
        print("- ✅ 严格执行去AI味标准")
        print("- ✅ 六重检查确保质量")
        print("- ✅ 像和聪明朋友聊天一样的自然文风")

        return True

    def stage4_publish(self, title: str, content: str, tags: List[str] = None,
                      description: str = "", featured: bool = False):
        """
        阶段4：自动发布
        创建文章文件并提交到 Git
        """
        print_header("阶段 4：自动发布")

        # 生成文件名
        filename = self._generate_filename(title)
        file_path = ARTICLES_DIR / filename

        # 生成 Front Matter
        front_matter = self._generate_front_matter(
            title, content, tags, description, featured
        )

        # 写入文件
        full_content = front_matter + "\n" + content

        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(full_content)

        print_success(f"文章已创建: {file_path}")

        # Git 操作
        print_info("\n正在提交到 Git...")

        try:
            subprocess.run(
                ['git', 'add', str(file_path)],
                cwd=WEBSITE_ROOT,
                capture_output=True,
                check=True
            )

            commit_msg = f"Add {filename}"
            subprocess.run(
                ['git', 'commit', '-m', commit_msg],
                cwd=WEBSITE_ROOT,
                capture_output=True,
                check=True
            )

            print_success("Git 提交成功")

            # 询问是否推送
            print_warning("\n是否立即推送到远程仓库？（触发自动部署）")
            choice = input("输入 'y' 推送，其他键跳过: ").strip().lower()

            if choice == 'y':
                subprocess.run(
                    ['git', 'push'],
                    cwd=WEBSITE_ROOT,
                    check=True
                )
                print_success("✓ 已推送到远程仓库")
                print_info("Cloudflare Pages 将自动构建部署")
                print_info(f"访问: https://xiaojunhong.space")
            else:
                print_info("跳过推送。稍后可手动运行: git push")

        except subprocess.CalledProcessError as e:
            print_error(f"Git 操作失败: {e}")
            return False

        # 更新状态
        self.state.state['stage'] = "published"
        self.state.state['title'] = title
        self.state.state['final_content'] = content
        self.state.state['file_path'] = str(file_path)
        self.state.save()

        print_success("\n📝 文章发布完成！")
        print(f"   文件: {file_path}")
        print(f"   标题: {title}")

        return True

    def _generate_filename(self, title: str) -> str:
        """生成文件名"""
        # 简化标题为文件名
        filename = title.lower()
        filename = filename.replace(' ', '-')
        # 移除特殊字符
        import re
        filename = re.sub(r'[^\w\s-]', '', filename)
        filename = re.sub(r'[-\s]+', '-', filename)
        return filename + ".md"

    def _generate_front_matter(self, title: str, content: str,
                               tags: List[str], description: str,
                               featured: bool) -> str:
        """生成 Front Matter"""
        # 估算阅读时间（假设每分钟 300 字）
        word_count = len(content)
        reading_time = max(1, round(word_count / 300))

        # 当前日期
        date_str = datetime.now().strftime("%Y-%m-%d")

        # 默认值
        if not tags:
            tags = ["未分类"]
        if not description:
            description = title

        front_matter = f"""---
title: "{title}"
date: {date_str}
draft: false
description: "{description}"
readingTime: {reading_time}
tags: {json.dumps(tags, ensure_ascii=False)}
featured: {str(featured).lower()}
---"""

        return front_matter

    def show_status(self):
        """显示当前状态"""
        print_header("工作流状态")

        state = self.state.state

        print(f"阶段: {state.get('stage', 'idle')}")
        print(f"内容类型: {state.get('content_type', 'N/A')}")
        print(f"标题: {state.get('title', 'N/A')}")
        print(f"创建时间: {state.get('created_at', 'N/A')}")
        print(f"文件路径: {state.get('file_path', 'N/A')}")

        if state.get('stage') == 'architecting':
            print_warning("\n⏳ 等待 Gemini 调研结果")
            print_info("运行: python3 workflow_manager.py --stage2")
        elif state.get('stage') == 'writing':
            print_warning("\n⏳ 等待内容组装")
            print_info("使用 /writing-coach 技能进行内容组装")

    def reset_workflow(self):
        """重置工作流"""
        self.state.reset()
        print_success("工作流已重置")

def main():
    """主函数"""
    import argparse

    parser = argparse.ArgumentParser(
        description="双 AI 协同工作流管理器"
    )
    parser.add_argument('--stage1', metavar='MATERIAL',
                       help='阶段1：输入原始材料')
    parser.add_argument('--type', choices=['article', 'note'],
                       default='article', help='内容类型')
    parser.add_argument('--stage2', action='store_true',
                       help='阶段2：生成 Gemini 调研提示词')
    parser.add_argument('--stage3', metavar='RESPONSE',
                       help='阶段3：接收 Gemini 调研结果')
    parser.add_argument('--stage4', action='store_true',
                       help='阶段4：自动发布（交互式）')
    parser.add_argument('--status', action='store_true',
                       help='显示当前状态')
    parser.add_argument('--reset', action='store_true',
                       help='重置工作流')

    args = parser.parse_args()

    manager = WorkflowManager()

    if args.stage1:
        # 从文件读取或使用命令行参数
        material = args.stage1
        if os.path.isfile(material):
            with open(material, 'r', encoding='utf-8') as f:
                material = f.read()

        manager.stage1_architect(material, args.type)

    elif args.stage2:
        manager.stage2_gemini_research()

    elif args.stage3:
        # 从文件读取或使用命令行参数
        response = args.stage3
        if os.path.isfile(response):
            with open(response, 'r', encoding='utf-8') as f:
                response = f.read()

        manager.stage3_assemble(response)

    elif args.stage4:
        print_warning("阶段4 需要通过 Claude Code 完成")
        print_info("请让 Claude Code 调用 stage4_publish() 方法")

    elif args.status:
        manager.show_status()

    elif args.reset:
        manager.reset_workflow()

    else:
        # 交互式模式
        print_header("双 AI 协同工作流管理器")
        print("Claude Code + Gemini App")
        print("=" * 60)

        print("\n选择操作:")
        print("1. 开始新文章（阶段1）")
        print("2. 生成 Gemini 调研提示词（阶段2）")
        print("3. 接收 Gemini 结果（阶段3）")
        print("4. 查看状态")
        print("5. 重置工作流")
        print("0. 退出")

        choice = input("\n请选择 [0-5]: ").strip()

        if choice == '1':
            material = input("请输入原始材料（或文件路径）: ").strip()
            if os.path.isfile(material):
                with open(material, 'r', encoding='utf-8') as f:
                    material = f.read()

            content_type = input("内容类型 [article/note，默认article]: ").strip()
            if content_type not in ['article', 'note']:
                content_type = 'article'

            manager.stage1_architect(material, content_type)

        elif choice == '2':
            manager.stage2_gemini_research()

        elif choice == '3':
            print_warning("请复制 Gemini 的回复，然后粘贴到终端")
            print("输入完成后按 Ctrl+D（Unix）或 Ctrl+Z（Windows）")

            lines = []
            try:
                while True:
                    line = input()
                    lines.append(line)
            except EOFError:
                pass

            response = '\n'.join(lines)
            manager.stage3_assemble(response)

        elif choice == '4':
            manager.show_status()

        elif choice == '5':
            manager.reset_workflow()

        else:
            print_info("退出")

if __name__ == '__main__':
    main()
