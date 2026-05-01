#!/bin/bash

# 域名配置自动化脚本
# xiaojunhong.space DNS 配置和验证

set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║              域名配置自动化脚本                                ║"
echo "║           xiaojunhong.space DNS 设置                         ║"
╚═══════════════════════════════════════════════════════════════╝"
echo ""

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📋 前置条件检查${NC}"
echo "─────────────────────────────────────────────────────────────"

# 检查 Cloudflare Pages 是否已部署
echo "请确认："
echo "  ✅ Cloudflare Pages 项目已创建"
echo "  ✅ 临时网址可以访问：https://xiaojunhong-website.pages.dev"
echo "  ✅ 构建成功，网站正常显示"
echo ""

read -p "按 Enter 确认继续..."
echo ""

echo -e "${BLUE}Step 1: 在 Cloudflare Pages 添加自定义域名${NC}"
echo "─────────────────────────────────────────────────────────────"
echo ""
echo "请在浏览器中操作："
echo ""
echo "1. 访问 Cloudflare Dashboard: https://dash.cloudflare.com/"
echo "2. 进入 Workers & Pages → xiaojunhong-website 项目"
echo "3. 点击 'Custom domains' 标签"
echo "4. 点击 'Set up a custom domain'"
echo "5. 输入域名: xiaojunhong.space"
echo "6. 点击 'Continue'"
echo ""
echo "Cloudflare 会显示需要添加的 DNS 记录。"
echo ""

read -p "按 Enter 确认已添加自定义域名..."
echo ""

echo -e "${BLUE}Step 2: 在 Namecheap 配置 DNS${NC}"
echo "─────────────────────────────────────────────────────────────"
echo ""
echo "请在浏览器中操作："
echo ""
echo "1. 访问: https://ap.www.namecheap.com/"
echo "2. 进入 Domain List → 找到 xiaojunhong.space → Manage"
echo "3. 点击 'Advanced DNS' 标签"
echo "4. 删除现有记录（如果有）"
echo "5. 点击 'Add New Record'，添加以下记录："
echo ""
echo "📋 DNS 记录配置："
echo ""
echo "┌──────────────────────────────────────────────────────────┐"
echo "│ 记录 1:                                                   │"
echo "│   Type: CNAME                                             │"
echo "│   Name: @                                                │"
echo "│   Value: xiaojunhong-website.pages.dev                   │"
echo "│   TTL: Automatic                                         │"
echo "├──────────────────────────────────────────────────────────┤"
echo "│ 记录 2:                                                   │"
echo "│   Type: CNAME                                             │"
echo "│   Name: www                                              │"
echo "│   Value: xiaojunhong-website.pages.dev                   │"
echo "│   TTL: Automatic                                         │"
echo "└──────────────────────────────────────────────────────────┘"
echo ""

read -p "按 Enter 确认已配置 DNS..."
echo ""

echo -e "${BLUE}Step 3: 验证 DNS 配置${NC}"
echo "─────────────────────────────────────────────────────────────"
echo ""
echo "DNS 传播通常需要 5-30 分钟。"
echo ""
echo "🔍 DNS 检查工具："
echo "   • https://www.whatsmydns.net/
echo "   • 输入域名: xiaojunhong.space"
echo "   • 检查全球 DNS 传播状态"
echo ""

# 检查 DNS 是否已经生效
echo "正在检查 DNS 状态..."
sleep 2

if host xiaojunhong.space &> /dev/null; then
    echo -e "${GREEN}✅ DNS 已开始生效${NC}"
    host xiaojunhong.space
else
    echo -e "${YELLOW}⏳ DNS 还未生效，这是正常的${NC}"
    echo "   通常需要 5-30 分钟，请稍后再试"
fi

echo ""

echo -e "${BLUE}Step 4: 测试网站访问${NC}"
echo "─────────────────────────────────────────────────────────────"
echo ""
echo "请尝试访问以下网址："
echo ""
echo "   🔗 https://xiaojunhong.space"
echo "   🔗 https://www.xiaojunhong.space"
echo ""
echo "预期结果："
echo "  ✅ 网站正常加载"
echo "  ✅ 显示你的个人网站首页"
echo "  ✅ 浏览器地址栏显示 🔒 (HTTPS)"
echo "  ✅ 没有 SSL 证书警告"
echo ""

read -p "网站是否可以正常访问？(y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}🎉 恭喜！网站部署完全成功！${NC}"
    echo ""
    echo "✅ xiaojunhong.space 现在可以正常访问了！"
    echo ""
    echo "📊 最终状态："
    echo "   ✅ 网站构建: Hugo"
    echo "   ✅ 代码托管: GitHub"
    echo "   ✅ 网站托管: Cloudflare Pages"
    echo "   ✅ 域名: xiaojunhong.space"
    echo "   ✅ HTTPS: 自动启用"
    echo "   ✅ CDN: 全球加速"
    echo ""
    echo "🚀 后续使用："
    echo "   创建新内容: ./new-article.sh article '标题'"
    echo "   发布更新: git add . && git commit -m '更新' && git push"
    echo "   Cloudflare 会自动部署你的更改"
else
    echo -e "${YELLOW}⏳ 可能还在 DNS 传播中${NC}"
    echo ""
    echo "建议："
    echo "  1. 使用 DNS 检查工具确认传播状态"
    echo "  2. 等待 10-15 分钟后重试"
    echo "  3. 如果仍有问题，检查 Cloudflare SSL 证书状态"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""

# 创建快速检查脚本
cat > check-domain.sh << 'EOF'
#!/bin/bash
echo "🔍 检查 xiaojunhong.space 状态..."
echo ""

# DNS 检查
echo "DNS 状态:"
if host xiaojunhong.space &> /dev/null; then
    echo "  ✅ DNS 已生效"
    host xiaojunhong.space | grep "has address"
else
    echo "  ❌ DNS 未生效"
fi

# HTTP 检查
echo ""
echo "网站访问测试:"
if curl -s -o /dev/null -w "%{http_code}" https://xiaojunhong.space | grep -q "200"; then
    echo "  ✅ 网站可访问 (HTTP 200)"
else
    echo "  ❌ 网站无法访问"
fi

# SSL 检查
echo ""
echo "SSL 证书:"
if echo | openssl s_client -servername xiaojunhong.space -connect xiaojunhong.space:443 2>/dev/null | grep -q "Verify return code: 0"; then
    echo "  ✅ SSL 证书有效"
else
    echo "  ❌ SSL 证书问题"
fi

echo ""
EOF

chmod +x check-domain.sh

echo "💾 已创建域名检查脚本: check-domain.sh"
echo "   随时运行: ./check-domain.sh"
echo ""
echo "═══════════════════════════════════════════════════════════════"
