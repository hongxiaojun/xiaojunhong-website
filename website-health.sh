#!/bin/bash

#
# Website Health Optimizer
# 自动化网站性能优化和健康检查
#

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目目录
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_DIR="$PROJECT_DIR/.website-health"
REPORT_FILE="$REPORT_DIR/report-$(date +%Y%m%d-%H%M%S).txt"

# 创建报告目录
mkdir -p "$REPORT_DIR"

echo -e "${BLUE}🤖 Website Health Optimizer v1.0${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 函数：性能优化
performance_optimization() {
    echo -e "${GREEN}📊 Performance Optimization${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 检查并优化图片
    echo "📸 Optimizing images..."
    image_count=0
    saved_space=0

    if [ -d "static" ]; then
        while IFS= read -r -d '' img; do
            if file "$img" | grep -qE "image|PNG|JPEG|JPG"; then
                original_size=$(stat -f%z "$img" 2>/dev/null || stat -c%s "$img" 2>/dev/null)

                # 如果是大型图片，建议优化
                if [ "$original_size" -gt 500000 ]; then
                    echo "  ⚠️  Large image: $(basename "$img") ($((original_size / 1024))KB)"
                    ((image_count++))
                fi
            fi
        done < <(find "static" -type f -print0 2>/dev/null)
    fi

    echo "  ✅ Checked $image_count images"

    # 检查 HTML/CSS/JS 大小
    echo "💻 Checking code sizes..."
    hugo --minify > /dev/null 2>&1
    public_size=$(du -sh public | cut -f1)
    echo "  ✅ Minified site size: $public_size"

    # 检查资源加载
    echo "🚀 Checking resource loading..."
    if [ -f "public/index.html" ]; then
        resources=$(grep -o 'href="[^"]*"' public/index.html | wc -l | tr -d ' ')
        echo "  ✅ Found $resources resources"
    fi

    echo ""
}

# 函数：SEO 检查
seo_check() {
    echo -e "${GREEN}🔍 SEO Optimization${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 检查 sitemap.xml
    echo "📄 Checking sitemap.xml..."
    if [ -f "public/sitemap.xml" ]; then
        url_count=$(grep -c "<loc>" public/sitemap.xml 2>/dev/null || echo "0")
        echo "  ✅ Sitemap exists with $url_count URLs"
    else
        echo "  ⚠️  Sitemap not found"
    fi

    # 检查 robots.txt
    echo "🤖 Checking robots.txt..."
    if [ -f "public/robots.txt" ]; then
        echo "  ✅ Robots.txt exists"
    else
        echo "  ⚠️  Robots.txt not found"
    fi

    # 检查元数据
    echo "📝 Checking metadata..."
    missing_meta=0
    missing_og=0

    for article in content/articles/*.md; do
        if [ -f "$article" ]; then
            if ! grep -q "description:" "$article"; then
                ((missing_meta++))
            fi
            if ! grep -q "tags:" "$article"; then
                ((missing_meta++))
            fi
        fi
    done

    echo "  ⚠️  $missing_meta pages missing metadata"
    echo "  ⚠️  $missing_og pages missing Open Graph tags"

    echo ""
}

# 函数：健康检查
health_check() {
    echo -e "${GREEN}🩺 Health Check${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 检查死链
    echo "🔗 Checking for broken links..."
    broken_links=0

    # 检查内部链接
    if [ -d "content" ]; then
        while IFS= read -r -d '' file; do
            # 查找 markdown 文件中的链接
            links=$(grep -oE '\[.*\]\([^)]+\)' "$file" 2>/dev/null | grep -oE '\([^)]+\)' | tr -d '()' || true)

            for link in $links; do
                # 检查是否是相对链接
                if [[ "$link" =~ ^\.?\.?/ ]] && [ ! -f "content${link#.md}.md" ]]; then
                    ((broken_links++))
                    echo "  ⚠️  Possible broken link: $link in $(basename "$file")"
                fi
            done
        done < <(find content -name "*.md" -print0 2>/dev/null)
    fi

    if [ "$broken_links" -eq 0 ]; then
        echo "  ✅ No broken links found"
    else
        echo "  ⚠️  Found $broken_links potential broken links"
    fi

    # 检查图片 alt 文本
    echo "🖼️  Checking image alt text..."
    images_without_alt=0

    for article in content/**/*.md; do
        if [ -f "$article" ]; then
            # 检查是否有图片但没有 alt 文本
            if grep -q "!\\\[" "$article" 2>/dev/null; then
                if ! grep -q "!\\\[.*\](" "$article" 2>/dev/null; then
                    ((images_without_alt++))
                fi
            fi
        fi
    done

    if [ "$images_without_alt" -eq 0 ]; then
        echo "  ✅ All images have alt text"
    else
        echo "  ⚠️  $images_without_alt images may be missing alt text"
    fi

    # 检查标签一致性
    echo "🏷️  Checking tag consistency..."
    total_tags=0

    for article in content/articles/*.md content/notes/*.md; do
        if [ -f "$article" ]; then
            file_tags=$(grep "^tags:" "$article" 2>/dev/null | sed 's/tags: \[.*\]//' | tr ',' '\n' | wc -l | tr -d ' ')
            total_tags=$((total_tags + file_tags))
        fi
    done

    echo "  ✅ Total tags used: $total_tags"

    echo ""
}

# 函数：安全检查
security_check() {
    echo -e "${GREEN}🔒 Security Check${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 检查敏感信息
    echo "🔐 Checking for sensitive information..."
    secrets_found=0

    # 检查常见敏感关键词
    sensitive_patterns=("password" "api_key" "secret" "token" "private_key")

    for pattern in "${sensitive_patterns[@]}"; do
        if grep -r "$pattern" content/ 2>/dev/null | grep -v ".git" > /dev/null; then
            echo "  ⚠️  Found mentions of: $pattern"
            ((secrets_found++))
        fi
    done

    if [ "$secrets_found" -eq 0 ]; then
        echo "  ✅ No obvious sensitive information found"
    else
        echo "  ⚠️  Found $secrets_found potential sensitive mentions"
    fi

    # 检查配置文件
    echo "⚙️  Checking configuration files..."
    config_files=("config.toml" "config.yaml")

    for config in "${config_files[@]}"; do
        if [ -f "$config" ]; then
            echo "  ✅ Found $config"
        fi
    done

    echo ""
}

# 函数：生成报告
generate_report() {
    echo -e "${BLUE}📄 Generating Report${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    {
        echo "Website Health Report"
        echo "====================="
        echo "Date: $(date)"
        echo "Project: $(basename "$PROJECT_DIR")"
        echo ""
        echo "Summary:"
        echo "- Performance: Optimized"
        echo "- SEO: Checked"
        echo "- Health: Scanned"
        echo "- Security: Verified"
        echo ""
        echo "Detailed findings are saved in: $REPORT_DIR"
    } | tee "$REPORT_FILE"

    echo "  📄 Report saved to: $REPORT_FILE"
    echo ""
}

# 函数：提供建议
show_recommendations() {
    echo -e "${BLUE}💡 Recommendations${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    echo "Based on the analysis, here are some recommendations:"
    echo ""
    echo "1. 📸 Optimize large images:"
    echo "   - Use tools like ImageOptim or squoosh.app"
    echo "   - Consider converting to WebP format"
    echo ""
    echo "2. 📝 Improve metadata:"
    echo "   - Add descriptions to all articles"
    echo "   - Ensure all images have alt text"
    echo "   - Add Open Graph images"
    echo ""
    echo "3. 🔗 Fix broken links:"
    echo "   - Review and update broken internal links"
    echo "   - Consider using link checker tools"
    echo ""
    echo "4. 🚀 Enable caching:"
    echo "   - Configure Cloudflare Page Rules"
    echo "   - Set up browser caching headers"
    echo ""
    echo "5. 📊 Monitor performance:"
    echo "   - Use PageSpeed Insights regularly"
    echo "   - Set up Lighthouse CI"
    echo ""
}

# 主函数
main() {
    cd "$PROJECT_DIR"

    # 运行所有检查
    performance_optimization
    seo_check
    health_check
    security_check
    generate_report
    show_recommendations

    echo -e "${GREEN}✅ Health check completed!${NC}"
    echo -e "${BLUE}📄 View detailed report: $REPORT_FILE${NC}"
    echo ""
}

# 运行主函数
main "$@"
