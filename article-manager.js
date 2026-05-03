#!/usr/bin/env node

/**
 * 文章管理工具
 * 用法: node article-manager.js
 * 然后在浏览器打开 http://localhost:3000
 */

const fs = require('fs');
const path = require('path');
const http = require('http');
const crypto = require('crypto');

const CONFIG = {
    port: 3000,
    articlesDir: path.join(__dirname, 'content/articles'),
    maxFeatured: 6
};

// 文章缓存
let articlesCache = null;
let cacheTime = null;

// 扫描所有文章
function scanArticles() {
    // 如果缓存有效，直接返回
    if (articlesCache && cacheTime && Date.now() - cacheTime < 5000) {
        return articlesCache;
    }

    const articles = [];
    const files = fs.readdirSync(CONFIG.articlesDir)
        .filter(f => f.endsWith('.md') && f !== '_index.md');

    files.forEach(file => {
        const filePath = path.join(CONFIG.articlesDir, file);
        const content = fs.readFileSync(filePath, 'utf-8');
        const { frontMatter, contentStart } = parseFrontMatter(content);

        articles.push({
            id: file.replace('.md', ''),
            file: file,
            path: filePath,
            title: frontMatter.title || file,
            date: frontMatter.date || '',
            featured: frontMatter.featured === true,
            description: frontMatter.description || '',
            tags: frontMatter.tags || [],
            readingTime: frontMatter.readingTime || 0,
            content: content
        });
    });

    // 按日期排序
    articles.sort((a, b) => new Date(b.date) - new Date(a.date));

    articlesCache = articles;
    cacheTime = Date.now();

    return articles;
}

// 解析 front matter
function parseFrontMatter(content) {
    const lines = content.split('\n');
    let frontMatter = {};
    let contentStart = 0;

    if (lines[0] === '---') {
        for (let i = 1; i < lines.length; i++) {
            if (lines[i] === '---') {
                contentStart = i + 1;
                break;
            }

            // 解析 YAML 格式
            const match = lines[i].match(/^([\w-]+):\s*(.+)$/);
            if (match) {
                let value = match[2];

                // 处理布尔值
                if (value === 'true') value = true;
                if (value === 'false') value = false;

                // 处理数组
                if (typeof value === 'string' && value.startsWith('[') && value.endsWith(']')) {
                    value = value.slice(1, -1).split(',').map(s => s.trim().replace(/"/g, ''));
                }

                frontMatter[match[1]] = value;
            }
        }
    }

    return { frontMatter, contentStart };
}

// 更新文章的 featured 状态
function updateFeaturedStatus(articleId, featured) {
    const articles = scanArticles();
    const article = articles.find(a => a.id === articleId);

    if (!article) {
        return { success: false, error: '文章不存在' };
    }

    // 检查置顶数量限制
    if (featured) {
        const featuredCount = articles.filter(a => a.featured).length;
        if (featuredCount >= CONFIG.maxFeatured) {
            return {
                success: false,
                error: `最多只能置顶 ${CONFIG.maxFeatured} 篇文章，当前已有 ${featuredCount} 篇`
            };
        }
    }

    try {
        const lines = article.content.split('\n');
        let featuredLineFound = false;
        let insertIndex = -1;

        // 查找 featured 行
        for (let i = 1; i < lines.length; i++) {
            if (lines[i] === '---') {
                insertIndex = i;
                break;
            }

            if (lines[i].match(/^featured:\s*(true|false)/)) {
                lines[i] = `featured: ${featured}`;
                featuredLineFound = true;
                break;
            }
        }

        // 如果没有找到 featured 行，添加它
        if (!featuredLineFound && insertIndex > 0) {
            lines.splice(insertIndex, 0, `featured: ${featured}`);
        }

        // 写回文件
        fs.writeFileSync(article.path, lines.join('\n'), 'utf-8');

        // 清除缓存
        articlesCache = null;
        cacheTime = null;

        return { success: true };
    } catch (error) {
        return { success: false, error: error.message };
    }
}

// HTTP 服务器
function createServer() {
    return http.createServer((req, res) => {
        // 设置 CORS
        res.setHeader('Access-Control-Allow-Origin', '*');
        res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
        res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

        if (req.method === 'OPTIONS') {
            res.writeHead(200);
            res.end();
            return;
        }

        // 处理 API 请求
        if (req.url === '/api/articles') {
            const articles = scanArticles();
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({
                success: true,
                articles: articles.map(a => ({
                    id: a.id,
                    title: a.title,
                    date: a.date,
                    featured: a.featured,
                    description: a.description,
                    tags: a.tags,
                    readingTime: a.readingTime
                })),
                stats: {
                    total: articles.length,
                    featured: articles.filter(a => a.featured).length,
                    latest: articles.slice(0, 2).length
                }
            }));
            return;
        }

        if (req.url === '/api/toggle' && req.method === 'POST') {
            let body = '';
            req.on('data', chunk => body += chunk);
            req.on('end', () => {
                try {
                    const { articleId, featured } = JSON.parse(body);
                    const result = updateFeaturedStatus(articleId, featured);

                    res.writeHead(200, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify(result));
                } catch (error) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ success: false, error: error.message }));
                }
            });
            return;
        }

        // 返回管理页面
        if (req.url === '/' || req.url === '/admin') {
            const htmlPath = path.join(__dirname, 'static', 'article-admin.html');

            // 如果管理页面不存在，创建一个
            if (!fs.existsSync(htmlPath)) {
                createAdminPage(htmlPath);
            }

            fs.readFile(htmlPath, (err, data) => {
                if (err) {
                    res.writeHead(500);
                    res.end('Error loading admin page');
                    return;
                }
                res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
                res.end(data);
            });
            return;
        }

        // 404
        res.writeHead(404);
        res.end('Not found');
    });
}

// 创建管理页面
function createAdminPage(filePath) {
    const html = `<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>文章管理 - xiaojunhong.space</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container { max-width: 1200px; margin: 0 auto; }
        .header {
            background: white;
            padding: 30px;
            border-radius: 12px;
            margin-bottom: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .header h1 { font-size: 28px; color: #333; margin-bottom: 10px; }
        .header p { color: #666; font-size: 14px; }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 20px;
        }
        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            border-radius: 8px;
            color: white;
        }
        .stat-card h3 { font-size: 14px; opacity: 0.9; margin-bottom: 5px; }
        .stat-card .number { font-size: 32px; font-weight: bold; }
        .filter-bar {
            background: white;
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .filter-buttons { display: flex; gap: 10px; }
        .filter-btn {
            padding: 8px 16px;
            border: 2px solid #e0e0e0;
            background: white;
            color: #666;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.2s;
        }
        .filter-btn:hover { border-color: #667eea; color: #667eea; }
        .filter-btn.active {
            background: #667eea;
            border-color: #667eea;
            color: white;
        }
        .article-list {
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .article-item {
            display: flex;
            align-items: center;
            padding: 20px;
            border-bottom: 1px solid #f0f0f0;
            transition: background-color 0.2s;
        }
        .article-item:hover { background-color: #f9f9f9; }
        .article-item:last-child { border-bottom: none; }
        .article-item.featured {
            background: linear-gradient(135deg, #fff5e6 0%, #fff 100%);
        }
        .featured-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 4px 12px;
            background: linear-gradient(135deg, #ffa500 0%, #ff8c00 100%);
            color: white;
            font-size: 12px;
            font-weight: 600;
            border-radius: 12px;
            margin-right: 15px;
        }
        .article-info { flex: 1; }
        .article-title {
            font-size: 16px;
            font-weight: 500;
            color: #333;
            margin-bottom: 5px;
        }
        .article-meta {
            font-size: 13px;
            color: #999;
            display: flex;
            gap: 15px;
        }
        .toggle-btn {
            padding: 8px 20px;
            border: 2px solid #667eea;
            background: white;
            color: #667eea;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.2s;
        }
        .toggle-btn:hover {
            background: #667eea;
            color: white;
        }
        .toggle-btn.featured {
            background: #ffa500;
            border-color: #ffa500;
            color: white;
        }
        .toggle-btn.featured:hover {
            background: #ff8c00;
            border-color: #ff8c00;
        }
        .success-message {
            position: fixed;
            top: 20px;
            right: 20px;
            background: #4caf50;
            color: white;
            padding: 15px 25px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            display: none;
            align-items: center;
            gap: 10px;
            z-index: 1000;
            animation: slideIn 0.3s ease;
        }
        @keyframes slideIn {
            from { transform: translateX(400px); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        .loading {
            text-align: center;
            padding: 40px;
            color: #999;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📚 文章管理</h1>
            <p>管理首页置顶文章，点击按钮即可切换置顶状态</p>
            <div class="stats">
                <div class="stat-card">
                    <h3>全部文章</h3>
                    <div class="number" id="totalCount">0</div>
                </div>
                <div class="stat-card">
                    <h3>置顶文章</h3>
                    <div class="number" id="featuredCount">0</div>
                </div>
                <div class="stat-card">
                    <h3>最新文章</h3>
                    <div class="number" id="latestCount">0</div>
                </div>
            </div>
        </div>

        <div class="filter-bar">
            <div class="filter-buttons">
                <button class="filter-btn active" data-filter="all">全部文章</button>
                <button class="filter-btn" data-filter="featured">置顶文章</button>
                <button class="filter-btn" data-filter="non-featured">未置顶</button>
            </div>
        </div>

        <div class="article-list" id="articleList">
            <div class="loading">加载中...</div>
        </div>
    </div>

    <div class="success-message" id="successMessage">
        <span>✓</span>
        <span id="messageText">操作成功</span>
    </div>

    <script>
        let articles = [];
        let currentFilter = 'all';

        // 加载文章列表
        async function loadArticles() {
            try {
                const response = await fetch('/api/articles');
                const data = await response.json();

                if (data.success) {
                    articles = data.articles;
                    updateStats(data.stats);
                    renderArticles();
                }
            } catch (error) {
                console.error('Failed to load articles:', error);
                document.getElementById('articleList').innerHTML =
                    '<div class="loading">加载失败，请确保服务器正在运行</div>';
            }
        }

        // 更新统计信息
        function updateStats(stats) {
            document.getElementById('totalCount').textContent = stats.total;
            document.getElementById('featuredCount').textContent = stats.featured;
            document.getElementById('latestCount').textContent = stats.latest;
        }

        // 渲染文章列表
        function renderArticles() {
            const container = document.getElementById('articleList');
            let filtered = articles;

            if (currentFilter === 'featured') {
                filtered = articles.filter(a => a.featured);
            } else if (currentFilter === 'non-featured') {
                filtered = articles.filter(a => !a.featured);
            }

            if (filtered.length === 0) {
                container.innerHTML = '<div class="loading">没有找到文章</div>';
                return;
            }

            container.innerHTML = filtered.map(article => \`
                <div class="article-item \${article.featured ? 'featured' : ''}">
                    \${article.featured ? '<span class="featured-badge">⭐ 置顶</span>' : ''}
                    <div class="article-info">
                        <div class="article-title">\${article.title}</div>
                        <div class="article-meta">
                            <span>📅 \${article.date}</span>
                            \${article.description ? \`<span>📝 \${article.description.substring(0, 50)}...</span>\` : ''}
                            \${article.readingTime ? \`<span>⏱️ \${article.readingTime} min</span>\` : ''}
                        </div>
                    </div>
                    <button class="toggle-btn \${article.featured ? 'featured' : ''}"
                            onclick="toggleFeatured('\${article.id}', \${!article.featured})">
                        \${article.featured ? '取消置顶' : '设为置顶'}
                    </button>
                </div>
            \`).join('');
        }

        // 切换置顶状态
        async function toggleFeatured(articleId, featured) {
            try {
                const response = await fetch('/api/toggle', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ articleId, featured })
                });

                const result = await response.json();

                if (result.success) {
                    // 更新本地数据
                    const article = articles.find(a => a.id === articleId);
                    if (article) {
                        article.featured = featured;
                    }

                    showMessage(featured ? '已设为置顶' : '已取消置顶');
                    updateStats({
                        total: articles.length,
                        featured: articles.filter(a => a.featured).length,
                        latest: Math.min(2, articles.length)
                    });
                    renderArticles();
                } else {
                    alert('操作失败：' + result.error);
                }
            } catch (error) {
                console.error('Toggle failed:', error);
                alert('操作失败：' + error.message);
            }
        }

        // 显示成功消息
        function showMessage(text) {
            const message = document.getElementById('successMessage');
            document.getElementById('messageText').textContent = text;
            message.style.display = 'flex';

            setTimeout(() => {
                message.style.display = 'none';
            }, 2000);
        }

        // 过滤按钮
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                document.querySelectorAll('.filter-btn').forEach(b =>
                    b.classList.remove('active'));
                btn.classList.add('active');
                currentFilter = btn.dataset.filter;
                renderArticles();
            });
        });

        // 页面加载时获取文章
        loadArticles();
    </script>
</body>
</html>`;

    fs.writeFileSync(filePath, html, 'utf-8');
}

// 启动服务器
function start() {
    const server = createServer();

    server.listen(CONFIG.port, () => {
        console.log(`
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   📚 文章管理工具已启动！                                      ║
║                                                               ║
║   在浏览器中打开: http://localhost:${CONFIG.port}                   ║
║                                                               ║
║   按Ctrl+C停止服务器                                          ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
        `);
    });

    server.on('error', (error) => {
        if (error.code === 'EADDRINUSE') {
            console.error(`❌ 端口 ${CONFIG.port} 已被占用，请关闭其他使用该端口的程序`);
        } else {
            console.error('❌ 服务器启动失败:', error.message);
        }
        process.exit(1);
    });
}

// 运行
start();
