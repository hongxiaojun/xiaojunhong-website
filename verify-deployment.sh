#!/bin/bash

# 网站部署验证脚本
# 自动测试网站的各个方面

set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║              xiaojunhong.space 部署验证工具                    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试计数器
PASS=0
FAIL=0

# 测试函数
test_item() {
    local name="$1"
    local command="$2"
    local expected="$3"

    echo -n "测试 $name... "

    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 通过${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${RED}❌ 失败${NC}"
        ((FAIL++))
        return 1
    fi
}

# 本地构建测试
echo "📋 本地构建测试"
echo "─────────────────────────────────────────────────────────────"

test_item "Hugo 安装" "which hugo"
test_item "配置文件存在" "test -f config.toml"
test_item "布局文件存在" "test -d layouts"
test_item "内容目录存在" "test -d content"
test_item "本地构建" "hugo --minify"

echo ""
echo "本地构建统计："
echo "  ✅ 通过: $PASS"
echo "  ❌ 失败: $FAIL"
echo ""

# Git 状态检查
echo "📋 Git 状态检查"
echo "─────────────────────────────────────────────────────────────"

test_item "Git 仓库初始化" "git rev-parse --git-dir"
test_item "GitHub 远程仓库" "git remote get-url origin"

if git ls-remote git@github.com:hongxiaojun/xiaojunhong-website.git &> /dev/null; then
    echo -e "GitHub 连接: ${GREEN}✅ 正常${NC}"
    ((PASS++))
else
    echo -e "GitHub 连接: ${RED}❌ 失败${NC}"
    ((FAIL++))
fi

# 检查是否有未提交的更改
if [ -z "$(git status --porcelain)" ]; then
    echo -e "Git 工作区状态: ${GREEN}✅ 干净${NC}"
    ((PASS++))
else
    echo -e "Git 工作区状态: ${YELLOW}⚠️  有未提交的更改${NC}"
fi

echo ""
echo "Git 状态统计："
echo "  ✅ 通过: $PASS"
echo "  ❌ 失败: $FAIL"
echo ""

# 文件结构检查
echo "📋 项目结构检查"
echo "─────────────────────────────────────────────────────────────"

required_files=(
    "config.toml"
    "layouts/_default/baseof.html"
    "layouts/_default/single.html"
    "layouts/_default/list.html"
    "layouts/index.html"
    "layouts/partials/header.html"
    "layouts/partials/footer.html"
    "content/articles/welcome.md"
    "content/notes/first-note.md"
    "content/about/_index.md"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  $file: ${GREEN}✅${NC}"
    else
        echo -e "  $file: ${RED}❌${NC}"
        ((FAIL++))
    fi
    ((PASS++))
done

echo ""
echo "文件结构统计：共检查 ${#required_files[@]} 个文件"
echo ""

# 内容检查
echo "📋 内容检查"
echo "─────────────────────────────────────────────────────────────"

article_count=$(find content/articles -name "*.md" -type f 2>/dev/null | wc -l)
note_count=$(find content/notes -name "*.md" -type f 2>/dev/null | wc -l)

echo "  文章数: $article_count"
echo "  笔记数: $note_count"
echo "  总页面数: $((article_count + note_count + 1))" # +1 for about page

if [ $article_count -gt 0 ] && [ $note_count -gt 0 ]; then
    echo -e "内容状态: ${GREEN}✅ 正常${NC}"
else
    echo -e "内容状态: ${YELLOW}⚠️  建议添加更多内容${NC}"
fi

echo ""

# 生成的文件检查
echo "📋 构建输出检查"
echo "─────────────────────────────────────────────────────────────"

if [ -d "public" ]; then
    echo -e "输出目录: ${GREEN}✅ 存在${NC}"

    html_count=$(find public -name "*.html" -type f | wc -l)
    echo "  生成的 HTML 文件: $html_count"

    if [ -f "public/index.html" ]; then
        echo -e "  首页: ${GREEN}✅${NC}"
    else
        echo -e "  首页: ${RED}❌${NC}"
    fi

    # 检查关键页面
    key_pages=("articles" "notes" "about")
    for page in "${key_pages[@]}"; do
        if [ -d "public/$page" ] || [ -f "public/$page/index.html" ]; then
            echo -e "  /$page/: ${GREEN}✅${NC}"
        else
            echo -e "  /$page/: ${RED}❌${NC}"
        fi
    done
else
    echo -e "输出目录: ${RED}❌ 不存在${NC}"
    echo "请运行: hugo --minify"
fi

echo ""

# 网络连接测试
echo "📋 网络连接测试"
echo "─────────────────────────────────────────────────────────────"

test_item "GitHub 可访问性" "curl -s -o /dev/null https://github.com"
test_item "Cloudflare 可访问性" "curl -s -o /dev/null https://dash.cloudflare.com"

echo ""
echo "网络连接统计："
echo "  ✅ 通过: $PASS"
echo "  ❌ 失败: $FAIL"
echo ""

# 总结
TOTAL_TESTS=$((PASS + FAIL))
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📊 测试总结"
echo "─────────────────────────────────────────────────────────────"
echo "  总测试数: $TOTAL_TESTS"
echo "  通过: $PASS"
echo "  失败: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}🎉 所有测试通过！项目状态良好${NC}"
    echo ""
    echo "下一步："
    echo "  1. 运行 ./cloudflare-helper.sh 配置 Cloudflare Pages"
    echo "  2. 配置自定义域名 xiaojunhong.space"
    echo "  3. 验证网站上线"
else
    echo -e "${YELLOW}⚠️  有 $FAIL 个测试失败，请检查上述错误${NC}"
    echo ""
    echo "常见问题："
    echo "  • Hugo 未安装：brew install hugo"
    echo "  • 构建失败：检查 config.toml 配置"
    echo "  • GitHub 连接失败：检查 SSH 密钥配置"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""

# 退出码
if [ $FAIL -eq 0 ]; then
    exit 0
else
    exit 1
fi
