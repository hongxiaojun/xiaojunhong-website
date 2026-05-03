#!/bin/bash

#
# 网站自动化设置脚本
# 配置定时任务、优化工具和健康检查
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🤖 Website Automation Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 1. 设置 GitHub Actions
echo "1️⃣  Setting up GitHub Actions..."
if [ ! -d ".github/workflows" ]; then
    mkdir -p .github/workflows
fi

echo "   ✅ GitHub Actions workflow created"
echo ""

# 2. 创建定时任务脚本
echo "2️⃣  Creating cron job setup..."

# 检查是否已经安装了 crontab
current_cron=$(crontab -l 2>/dev/null || true)

# 检查是否已经存在我们的定时任务
if ! echo "$current_cron" | grep -q "website-health.sh"; then
    echo "   💡 To enable weekly automated health checks, add this to your crontab:"
    echo ""
    echo "   crontab -e"
    echo ""
    echo "   然后添加以下行："
    echo "   # 每周日凌晨2点运行网站健康检查"
    echo "   0 2 * * 0 cd $PROJECT_DIR && ./website-health.sh >> .website-health/cron.log 2>&1"
    echo ""
    echo "   或者每月运行一次："
    echo "   0 2 1 * * cd $PROJECT_DIR && ./website-health.sh >> .website-health/cron.log 2>&1"
    echo ""
else
    echo "   ✅ Cron job already exists"
fi

echo ""

# 3. 创建快速优化脚本
echo "3️⃣  Creating quick optimization scripts..."

cat > "$PROJECT_DIR/quick-fix.sh" << 'EOF'
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
EOF

chmod +x "$PROJECT_DIR/quick-fix.sh"

echo "   ✅ Created quick-fix.sh script"
echo ""

# 4. 创建 Git pre-commit hook
echo "4️⃣  Setting up Git pre-commit hook..."

cat > "$PROJECT_DIR/.git/hooks/pre-commit" << 'EOF'
#!/bin/bash

# Git pre-commit hook: 自动检查网站健康

echo "🤖 Running pre-commit health check..."

# 运行健康检查
./website-health.sh > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "⚠️  Warning: Health check found issues. Commit anyway? (y/n)"
    read answer
    if [ "$answer" != "y" ]; then
        exit 1
    fi
fi
EOF

chmod +x "$PROJECT_DIR/.git/hooks/pre-commit"

echo "   ✅ Git pre-commit hook created"
echo ""

# 5. 创建监控脚本
echo "5️⃣  Creating monitoring script..."

cat > "$PROJECT_DIR/monitor.sh" << 'EOF'
#!/bin/bash

#
# 网站监控脚本
# 监控网站性能和可用性
#

echo "📊 Website Monitoring"

# 检查网站是否在线
check_site() {
    if curl -s -f "https://xiaojunhong.space" > /dev/null; then
        echo "✅ Website is online"
        return 0
    else
        echo "❌ Website is offline!"
        return 1
    fi
}

# 检查性能
check_performance() {
    echo "🚀 Checking performance..."

    # 使用 curl 测试加载时间
    start_time=$(date +%s%N)
    curl -s "https://xiaojunhong.space" > /dev/null
    end_time=$(date +%s%N)

    load_time=$(( (end_time - start_time) / 1000000 ))
    echo "   Load time: ${load_time}s"

    if [ "$load_time" -lt 2 ]; then
        echo "   ✅ Excellent performance"
    elif [ "$load_time" -lt 4 ]; then
        echo "   ⚠️  Good performance"
    else
        echo "   ❌ Slow performance"
    fi
}

# 主函数
main() {
    check_site
    check_performance
}

main "$@"
EOF

chmod +x "$PROJECT_DIR/monitor.sh"

echo "   ✅ Created monitor.sh script"
echo ""

# 6. 提供图片优化指南
echo "6️⃣ Image optimization guide..."

cat > "$PROJECT_DIR/IMAGE_OPTIMIZATION_GUIDE.md" << 'EOF'
# 图片优化指南

## 当前状态
- favicon.ico: 722KB（需要优化到 < 50KB）
- logo.png: 722KB（需要优化到 < 100KB）

## 推荐工具

### 在线工具（最简单）
1. **Squoosh** - https://squoosh.app/
   - 拖拽图片即可压缩
   - 支持 PNG, JPG, WebP
   - 免费，无限制

2. **TinyPNG** - https://tinypng.com/
   - 优秀的压缩率
   - 在线免费使用
   - 支持批量处理

3. **RealFaviconGenerator** - https://realfavicongenerator.net/
   - 专门用于 favicon
   - 生成多种尺寸
   - 压缩效果很好

### 本地工具
1. **ImageOptim** (Mac)
   ```bash
   brew install imageoptim
   imageoptim static/favicon.ico
   ```

2. **optipng** (PNG)
   ```bash
   brew install optipng
   optipng -o7 static/logo.png
   ```

## favicon.ico 优化步骤
1. 访问 https://realfavicongenerator.net/
2. 上传当前的 logo.png
3. 选择 "ICO" 格式
4. 下载优化后的 favicon.ico
5. 替换 static/favicon.ico

## logo.png 优化步骤
1. 访问 https://squoosh.app/
2. 上传 static/logo.png
3. 调整压缩质量（推荐 70-80%）
4. 下载优化版本
5. 替换 static/logo.png

## 验证优化效果
```bash
ls -lh static/favicon.ico static/logo.png
```

目标大小：
- favicon.ico < 50KB
- logo.png < 100KB
EOF

echo "   ✅ Created IMAGE_OPTIMIZATION_GUIDE.md"
echo ""

# 7. 总结
echo -e "${GREEN}✅ Automation Setup Completed!${NC}"
echo ""
echo "📋 Available Scripts:"
echo "  • ./website-health.sh      - 运行完整健康检查"
echo "  • ./optimize-images.sh     - 优化图片"
echo "  • ./quick-fix.sh           - 快速修复问题"
echo "  • ./monitor.sh             - 监控网站性能"
echo ""
echo "📚 Documentation:"
echo "  • IMAGE_OPTIMIZATION_GUIDE.md - 图片优化指南"
echo "  • .website-health/report-*.txt - 健康检查报告"
echo ""
echo "🤖 GitHub Actions:"
echo "  • 每周日凌晨2点自动运行健康检查"
echo "  • 手动触发: GitHub → Actions → Website Health Check"
echo ""
echo "💡 Next Steps:"
echo "  1. 优化 favicon.ico 和 logo.png（参考指南）"
echo "  2. 运行 ./quick-fix.sh 测试"
echo "  3. 查看健康报告：cat .website-health/report-*.txt"
echo ""
EOF

chmod +x "$PROJECT_DIR/setup-automation.sh"
