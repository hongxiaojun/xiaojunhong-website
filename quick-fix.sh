#!/bin/bash

#
# 快速修复常见问题
#

echo "🔧 Quick Fixes for Website Health"

# 1. 优化图片
echo "1️⃣ Optimizing images..."
if [ -f "optimize-images.sh" ]; then
    chmod +x optimize-images.sh
    ./optimize-images.sh
fi

# 2. 运行健康检查
echo "2️⃣ Running health check..."
if [ -f "website-health.sh" ]; then
    chmod +x website-health.sh
    ./website-health.sh
fi

# 3. 构建网站
echo "3️⃣ Building website..."
hugo --minify

echo "✅ Quick fixes completed!"
