#!/bin/bash

#
# Image Optimizer
# 自动优化网站图片
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🖼️  Image Optimizer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 检查大图片
echo "🔍 Scanning for large images..."
large_images=0

find static -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.ico" \) -size +500k | while read img; do
    size=$(du -h "$img" | cut -f1)
    echo "  ⚠️  Found large image: $(basename "$img") ($size)"
    ((large_images++))
done

if [ "$large_images" -eq 0 ]; then
    echo "  ✅ No large images found!"
    exit 0
fi

echo ""
echo "📋 Optimization Recommendations:"
echo ""

# 检查是否安装了优化工具
if command -v optipng &> /dev/null; then
    echo "  ✅ optipng found"
else
    echo "  💡 Install optipng: brew install optipng"
fi

if command -v jpegoptim &> /dev/null; then
    echo "  ✅ jpegoptim found"
else
    echo "  💡 Install jpegoptim: brew install jpegoptim"
fi

echo ""
echo "🚀 Quick Fixes:"
echo ""

# 处理 favicon.ico
if [ -f "static/favicon.ico" ]; then
    echo "1. favicon.ico (722KB)"
    echo "   → 建议：使用在线工具"
    echo "   → https://realfavicongenerator.net/"
    echo "   → 上传当前 favicon，下载优化版本"
    echo ""
fi

# 处理 logo.png
if [ -f "static/logo.png" ]; then
    echo "2. logo.png (722KB)"
    echo "   → 建议：使用在线工具"
    echo "   → https://squoosh.app/"
    echo "   → 或使用本地工具：sips -Z 400 static/logo.png"
    echo ""

    # 尝试使用 sips 压缩（macOS 自带）
    if command -v sips &> /dev/null; then
        echo "   🔧 Attempting automatic optimization..."
        cp static/logo.png static/logo.png.backup
        sips -s format png -s formatOptions 70 --resampleHeight 100 static/logo.png 2>/dev/null || true

        new_size=$(du -h static/logo.png | cut -f1)
        old_size=$(du -h static/logo.png.backup | cut -f1)

        echo "   ✅ Optimized: $old_size → $new_size"

        # 如果优化后更小，就保留；否则恢复
        if [ $(stat -f%z "static/logo.png" 2>/dev/null || stat -c%s "static/logo.png") -lt $(stat -f%z "static/logo.png.backup" 2>/dev/null || stat -c%s "static/logo.png.backup") ]; then
            rm static/logo.png.backup
        else
            mv static/logo.png.backup static/logo.png
            echo "   ⚠️  Optimization didn't help, kept original"
        fi
    fi
fi

echo ""
echo "📊 Expected sizes after optimization:"
echo "  favicon.ico: < 50KB"
echo "  logo.png: < 100KB"
echo ""

echo "💡 Advanced tools:"
echo "  - ImageOptim (Mac): https://imageoptim.com/"
echo "  - FileOptim (Web): https://www.fileoptim.com/"
echo "  - Squoosh (Web): https://squoosh.app/"
echo ""

echo "✅ Image optimization guide completed!"
