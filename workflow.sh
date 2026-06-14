#!/bin/bash
# 双 AI 协同工作流启动脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 网站目录
WEBSITE_DIR="/Users/add/xiaojunhong-website"

# 帮助信息
show_help() {
    echo -e "${CYAN}双 AI 协同工作流${NC}"
    echo ""
    echo "用法: ./workflow.sh [选项]"
    echo ""
    echo "选项:"
    echo "  start, --stage1 MATERIAL   开始新工作流（阶段1：架构设计）"
    echo "  research, --stage2         生成 Gemini 调研任务书（阶段2）"
    echo "  assemble, --stage3 FILE    接收 Gemini 结果（阶段3：内容组装）"
    echo "  status, --status           查看当前状态"
    echo "  reset, --reset             重置工作流"
    echo "  help, --help               显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  ./workflow.sh start \"原始材料\""
    echo "  ./workflow.sh research"
    echo "  ./workflow.sh assemble gemini_response.txt"
    echo "  ./workflow.sh status"
    echo ""
}

# 检查 Python3
check_python() {
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}错误: Python3 未安装${NC}"
        echo "请运行: brew install python3"
        exit 1
    fi
}

# 检查工作流管理器
check_workflow_manager() {
    if [ ! -f "$WEBSITE_DIR/workflow_manager.py" ]; then
        echo -e "${RED}错误: workflow_manager.py 不存在${NC}"
        exit 1
    fi
}

# 主函数
main() {
    # 检查环境
    check_python
    check_workflow_manager

    # 进入网站目录
    cd "$WEBSITE_DIR"

    # 解析参数
    case "$1" in
        start|--stage1)
            if [ -z "$2" ]; then
                echo -e "${YELLOW}请提供原始材料${NC}"
                echo "用法: ./workflow.sh start \"你的原始材料\""
                exit 1
            fi
            python3 workflow_manager.py --stage1 "$2"
            ;;
        research|--stage2)
            python3 workflow_manager.py --stage2
            ;;
        assemble|--stage3)
            if [ -z "$2" ]; then
                echo -e "${YELLOW}请提供 Gemini 回复文件或内容${NC}"
                echo "用法: ./workflow.sh assemble gemini_response.txt"
                exit 1
            fi

            # 如果是文件，读取内容
            if [ -f "$2" ]; then
                python3 workflow_manager.py --stage3 "$(cat "$2")"
            else
                python3 workflow_manager.py --stage3 "$2"
            fi
            ;;
        status|--status)
            python3 workflow_manager.py --status
            ;;
        reset|--reset)
            python3 workflow_manager.py --reset
            ;;
        help|--help|"")
            show_help
            ;;
        *)
            echo -e "${RED}未知选项: $1${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"
