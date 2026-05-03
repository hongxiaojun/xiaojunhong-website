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
