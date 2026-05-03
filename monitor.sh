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
