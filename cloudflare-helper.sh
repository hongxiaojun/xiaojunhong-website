#!/bin/bash

# Cloudflare Pages 自动化配置助手
# 这个脚本会指导你完成 Cloudflare Pages 的配置

set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         Cloudflare Pages 自动化配置助手                       ║"
echo "║              xiaojunhong.space 网站部署                       ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# 检查是否在正确的目录
if [ ! -f "config.toml" ]; then
    echo "❌ 错误：请在 xiaojunhong-website 项目目录中运行此脚本"
    exit 1
fi

echo "✅ 项目目录确认"
echo ""

# 显示项目信息
echo "📊 项目信息："
echo "   • GitHub 仓库：https://github.com/hongxiaojun/xiaojunhong-website"
echo "   • 构建命令：hugo --minify"
echo "   • 输出目录：public"
echo "   • 生产分支：main"
echo ""

# 检查 GitHub 仓库是否可访问
echo "🔍 检查 GitHub 仓库..."
if git ls-remote git@github.com:hongxiaojun/xiaojunhong-website.git &> /dev/null; then
    echo "✅ GitHub 仓库可访问"
else
    echo "❌ GitHub 仓库无法访问"
    exit 1
fi
echo ""

# Cloudflare Pages 配置步骤
echo "🚀 Cloudflare Pages 配置步骤："
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Step 1
echo "Step 1: 登录 Cloudflare"
echo "─────────────────────────────────────────────────────────────"
echo "1. 在浏览器中访问：https://dash.cloudflare.com/"
echo "2. 使用你的 Cloudflare 账户登录"
echo ""
read -p "按 Enter 键，确认已登录 Cloudflare..."
echo ""

# Step 2
echo "Step 2: 创建 Pages 项目"
echo "─────────────────────────────────────────────────────────────"
echo "1. 在左侧菜单找到 'Workers & Pages'"
echo "2. 点击 'Create application'"
echo "3. 选择 'Pages' 标签"
echo "4. 点击 'Connect to Git'"
echo ""
read -p "按 Enter 键，准备连接 GitHub..."
echo ""

# Step 3
echo "Step 3: 连接 GitHub 仓库"
echo "─────────────────────────────────────────────────────────────"
echo "1. 如果首次使用，点击 'Connect GitHub'"
echo "2. 授权 Cloudflare 访问你的 GitHub"
echo "3. 找到并选择 'xiaojunhong-website' 仓库"
echo "4. 点击 'Begin setup'"
echo ""
read -p "按 Enter 键，继续配置构建设置..."
echo ""

# Step 4
echo "Step 4: 配置构建设置"
echo "─────────────────────────────────────────────────────────────"
echo "请在 Cloudflare Pages 中填写以下配置："
echo ""
echo "┌──────────────────────────────────────────────────────────┐"
echo "│ 设置项              │ 值                                │"
echo "├──────────────────────────────────────────────────────────┤"
echo "│ Project name        │ xiaojunhong-website               │"
echo "│ Production branch   │ main                              │"
echo "│ Framework preset    │ Hugo                              │"
echo "│ Build command       │ hugo --minify                     │"
echo "│ Build output dir    │ public                            │"
echo "│ Root directory      │ (留空)                            │"
echo "└──────────────────────────────────────────────────────────┘"
echo ""
echo "环境变量（可选）："
echo "  HUGO_VERSION: 0.161.1"
echo ""
read -p "按 Enter 键，确认配置完成并开始部署..."
echo ""

# Step 5
echo "Step 5: 等待部署完成"
echo "─────────────────────────────────────────────────────────────"
echo "1. 点击 'Save and Deploy'"
echo "2. 等待构建完成（通常 1-2 分钟）"
echo "3. 构建成功后会显示临时网址"
echo ""
echo "临时网址格式："
echo "   https://xiaojunhong-website.pages.dev"
echo ""
read -p "按 Enter 键，准备验证部署..."
echo ""

# Step 6
echo "Step 6: 验证部署"
echo "─────────────────────────────────────────────────────────────"
echo "请访问以下网址验证网站是否正常："
echo ""
echo "   🔗 https://xiaojunhong-website.pages.dev"
echo ""
read -p "网站是否正常显示？(y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✅ 部署验证成功！"
else
    echo "❌ 部署可能有问题，请检查 Cloudflare Pages 的构建日志"
    exit 1
fi
echo ""

# 下一步
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "🎉 Cloudflare Pages 基础配置完成！"
echo ""
echo "📋 下一步：配置自定义域名"
echo ""
echo "1. 在 Cloudflare Pages 项目中，点击 'Custom domains'"
echo "2. 添加自定义域名：xiaojunhong.space"
echo "3. 在 Namecheap 配置 DNS 记录"
echo "4. 等待 DNS 生效"
echo ""
echo "详细步骤请参考：CLOUDFLARE_SETUP.md"
echo ""

# 提供域名配置提示
echo "💡 域名配置提示："
echo ""
echo "在 Namecheap 的 DNS 设置中添加："
echo ""
echo "记录 1:"
echo "  Type: CNAME"
echo "  Name: @"
echo "  Value: xiaojunhong-website.pages.dev"
echo ""
echo "记录 2:"
echo "  Type: CNAME"
echo "  Name: www"
echo "  Value: xiaojunhong-website.pages.dev"
echo ""

# 创建继续脚本
cat > continue-domain-setup.sh << 'EOF'
#!/bin/bash
# 域名配置继续脚本

echo "🔧 继续配置域名..."
echo ""
echo "请确认以下步骤已完成："
echo "1. ✅ 在 Cloudflare Pages 添加了自定义域名"
echo "2. ⏳ 在 Namecheap 配置了 DNS 记录"
echo "3. ⏳ 等待 DNS 生效（5-30 分钟）"
echo ""
echo "DNS 检查工具：https://www.whatsmydns.net/"
echo ""

read -p "是否已完成上述步骤？(y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✅ 正在验证域名..."
    echo ""
    echo "请访问以下网址验证："
    echo "   🔗 https://xiaojunhong.space"
    echo ""
    read -p "网站是否可以正常访问？(y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🎉 恭喜！网站部署完全成功！"
        echo ""
        echo "✅ xiaojunhong.space 现在可以正常访问了！"
    else
        echo "⚠️  DNS 可能还在生效中，请稍后再试"
        echo "   可以使用 https://www.whatsmydns.net/ 检查 DNS 状态"
    fi
else
    echo "请先完成上述步骤后再运行此脚本"
fi
EOF

chmod +x continue-domain-setup.sh

echo "💾 已创建继续脚本：continue-domain-setup.sh"
echo "   完成域名配置后运行：./continue-domain-setup.sh"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📞 需要帮助？"
echo "   • 查看 CLOUDFLARE_SETUP.md"
echo "   • 查看 DEPLOYMENT_PROGRESS.md"
echo "   • 或询问 AI 助手"
echo ""
echo "🚀 祝你部署顺利！"
echo ""
