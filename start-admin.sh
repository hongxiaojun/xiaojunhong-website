#!/bin/bash

echo "🚀 启动文章管理工具..."
echo ""

# 检查 Node.js 是否安装
if ! command -v node &> /dev/null; then
    echo "❌ 错误：未找到 Node.js"
    echo "请先安装 Node.js: brew install node"
    exit 1
fi

# 检查端口是否被占用
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "⚠️  端口 3000 已被占用"
    echo "正在尝试关闭现有进程..."
    lsof -ti:3000 | xargs kill -9 2>/dev/null
    sleep 1
fi

# 启动管理工具
echo "📡 启动服务器..."
node article-manager.js &
SERVER_PID=$!

# 等待服务器启动
sleep 2

# 检查服务器是否成功启动
if curl -s http://localhost:3000 > /dev/null; then
    echo ""
    echo "✅ 服务器启动成功！"
    echo ""
    echo "🌐 在浏览器中打开: http://localhost:3000"
    echo ""

    # 自动打开浏览器
    if command -v open &> /dev/null; then
        echo "📱 正在自动打开浏览器..."
        open http://localhost:3000
    fi

    echo ""
    echo "📋 使用说明:"
    echo "  - 点击按钮来置顶/取消置顶文章"
    echo "  - 按 Ctrl+C 停止服务器"
    echo ""
    echo "💡 服务器 PID: $SERVER_PID"
    echo ""

    # 等待用户中断
    wait $SERVER_PID
else
    echo "❌ 服务器启动失败"
    echo "请检查错误信息"
    kill $SERVER_PID 2>/dev/null
    exit 1
fi
