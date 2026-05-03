#!/bin/bash

#
# 图片优化助手
# 提供简单的图片优化操作指南
#

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🖼️ 图片优化助手${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 检查图片
echo "📊 当前图片状态："
echo ""

if [ -f "static/logo.png" ]; then
    logo_size=$(du -h static/logo.png | cut -f1)
    echo "  logo.png: $logo_size"
fi

if [ -f "static/favicon.ico" ]; then
    favicon_size=$(du -h static/favicon.ico | cut -f1)
    echo "  favicon.ico: $favicon_size"
fi

echo ""
echo "💡 推荐的优化方案："
echo ""

# Logo.png 优化
echo "1️⃣ 优化 logo.png (722KB → 目标 < 100KB)"
echo ""
echo "   步骤："
echo "   a) 访问: https://squoosh.app/"
echo "   b) 点击 '选择文件' 上传 static/logo.png"
echo "   c) 调整设置："
echo "      - 压缩: 70-80%"
echo "      - 格式: PNG"
echo "   d) 点击 '下载' 保存优化后的文件"
echo "   e) 替换 static/logo.png"
echo ""

# Favicon.ico 优化
echo "2️⃣ 优化 favicon.ico (722KB → 目标 < 50KB)"
echo ""
echo "   步骤："
echo "   a) 访问: https://realfavicongenerator.net/"
echo "   b) 上传 static/logo.png"
echo "   '选择 'ICO' 格式，尺寸推荐 32x32 或 64x64"
echo "   c) 点击 '生成 favicon'"
echo "   '下载 ' 下载优化后的 favicon.ico"
echo "   e) 替换 static/favicon.ico"
echo ""

# 创建测试脚本
echo "3️⃣ 创建验证脚本..."

cat > "$PROJECT_DIR/verify-images.sh" << 'EOF'
#!/bin/bash

echo "🔍 验证图片优化效果..."

if [ -f "static/logo.png" ]; then
    size=$(du -h static/logo.png | cut -f1)
    echo "  logo.png: $size"
    size_bytes=$(stat -f%z static/logo.png 2>/dev/null || stat -c%s static/logo.png)
    if [ "$size_bytes" -lt 102400 ]; then
        echo "  ✅ 优化成功！(< 100KB)"
    else
        echo "  ⚠️  仍需优化($(echo "scale=1; $size_bytes/1024" | bc)KB)"
    fi
fi

if [ -f "static/favicon.ico" ]; then
    size=$(du -h static/favicon.ico | cut -f1)
    echo "  favicon.ico: $size"
    size_bytes=$(stat -f%z static/favicon.ico 2>/dev/null || stat -c%s static/favicon.ico)
    if [ "$size_bytes" -lt 51200 ]; then
        echo "  ✅ 优化成功！(< 50KB)"
    else
        echo "  ⚠️  仍需优化($(echo "scale=1; $size_bytes/1024" | bc)KB)"
    fi
fi

echo ""
echo "💡 推荐工具："
echo "  - Squoosh: https://squoosh.app/"
echo "  - TinyPNG: https://tinypng.com/"
echo "  - RealFaviconGenerator: https://realfavicongenerator.net/"
EOF

chmod +x "$PROJECT_DIR/verify-images.sh"

echo "   ✅ 创建验证脚本: verify-images.sh"
echo ""

# 自动打开浏览器到优化工具
echo "4️⃣ 自动打开优化工具..."

echo "   🌐 打开 Squoosh (logo.png 优化)..."
if command -v open &> /dev/null; then
    sleep 2
    # 注意：这里只是提供链接，用户需要手动上传文件
    echo "   💡 请手动上传 static/logo.png 到: https://squoosh.app/"
fi

echo ""
echo -e "${GREEN}✅ 图片优化准备完成！${NC}"
echo ""
echo "📋 下一步操作："
echo ""
echo "1. 优化 logo.png:"
echo "   - 打开: https://squoosh.app/"
echo "   - 上传: static/logo.png"
echo "   - 压缩到 70-80%"
echo "   - 下载并替换"
echo ""
echo "2. 优化 favicon.ico:"
echo "   - 打开: https://realfavicongenerator.net/"
echo "   - 上传: static/logo.png"
echo "   - 选择 ICO 格式"
echo "   - 下载并替换"
echo ""
echo "3. 验证优化效果:"
echo "   ./verify-images.sh"
echo ""
echo "4. 提交更改:"
echo "   git add static/"
echo "   git commit -m 'Optimize images'"
echo "   git push"
echo ""
