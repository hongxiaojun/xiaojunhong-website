# 🎯 真实统计系统部署指南

本指南将帮助您部署和配置基于 Cloudflare Workers + D1 的真实网站统计系统。

## 📋 系统概述

统计系统包含以下组件：
- **Cloudflare Workers API**: 处理统计数据的记录和查询
- **Cloudflare D1 数据库**: 存储真实的访问和播放数据
- **前端统计代码**: 替换所有假数据为真实API调用

## 🚀 部署步骤

### 第一步：安装 Wrangler CLI

```bash
# 使用 npm 安装
npm install -g wrangler

# 或使用 yarn
yarn global add wrangler

# 验证安装
wrangler --version
```

### 第二步：登录 Cloudflare

```bash
wrangler login
```

这会打开浏览器让您授权访问 Cloudflare 账户。

### 第三步：创建 D1 数据库

```bash
# 创建数据库
wrangler d1 create xiaojunhong-analytics

# 记下返回的 database_id，更新到 wrangler.toml 中
```

**重要**: 复制返回的 `database_id`，然后编辑 `workers/analytics-api/wrangler.toml`：

```toml
[[d1_databases]]
binding = "DB"
database_name = "xiaojunhong-analytics"
database_id = "YOUR_DATABASE_ID"  # 替换为实际的 database_id
```

### 第四步：初始化数据库结构

```bash
# 进入 API 目录
cd workers/analytics-api

# 安装依赖
npm install

# 执行数据库结构脚本
wrangler d1 execute xiaojunhong-analytics --file=schema.sql --local
```

### 第五步：本地测试

```bash
# 启动本地开发服务器
npm run dev
```

测试本地 API：
```bash
# 健康检查
curl http://localhost:8787/api/health

# 测试统计记录
curl -X POST http://localhost:8787/api/track/pageview \
  -H "Content-Type: application/json" \
  -d '{"path":"/test","title":"Test Page","type":"article","sessionId":"test123"}'
```

### 第六步：部署到生产环境

```bash
# 部署 Workers
npm run deploy

# 在生产数据库中创建表结构
wrangler d1 execute xiaojunhong-analytics --file=schema.sql
```

### 第七步：获取 Workers URL

部署完成后，Wrangler 会返回一个 URL，例如：
```
https://xiaojunhong-analytics.your-subdomain.workers.dev
```

### 第八步：更新前端配置

编辑 `layouts/partials/analytics.html`，替换 API URL：

```javascript
const ANALYTICS_API = 'https://xiaojunhong-analytics.your-subdomain.workers.dev';
```

## 📊 API 端点说明

### 1. 页面浏览统计
```http
POST /api/track/pageview
Content-Type: application/json

{
  "path": "/articles/my-article",
  "title": "My Article Title",
  "type": "article",
  "sessionId": "session_xyz"
}
```

### 2. 播客播放统计
```http
POST /api/track/podcast
Content-Type: application/json

{
  "path": "/podcasts/my-podcast",
  "sessionId": "session_xyz",
  "duration": 120,
  "completed": false
}
```

### 3. 获取页面统计
```http
GET /api/stats/page?path=/articles/my-article
```

### 4. 获取总体统计
```http
GET /api/stats/total
```

### 5. 获取播客统计
```http
GET /api/stats/podcast?path=/podcasts/my-podcast
```

## 🔒 隐私保护

本统计系统采用隐私友好设计：

- **IP 地址哈希化**: 使用 SHA-256 哈希 IP 地址，不存储原始 IP
- **无跨站追踪**: 仅收集本站访问数据
- **会话控制**: 同一会话短时间内不重复计数
- **数据最小化**: 仅收集必要的统计数据

## 🧪 测试验证

部署后测试：

```bash
# 1. 测试健康检查
curl https://your-worker.workers.dev/api/health

# 2. 测试页面浏览记录
curl -X POST https://your-worker.workers.dev/api/track/pageview \
  -H "Content-Type: application/json" \
  -d '{"path":"/test","title":"Test","type":"page","sessionId":"test123"}'

# 3. 测试统计查询
curl https://your-worker.workers.dev/api/stats/page?path=/test
curl https://your-worker.workers.dev/api/stats/total
```

## 📈 数据库查询

查看数据库内容：

```bash
# 查看页面列表
wrangler d1 execute xiaojunhong-analytics --command="SELECT * FROM pages LIMIT 10"

# 查看访问记录
wrangler d1 execute xiaojunhong-analytics --command="SELECT * FROM page_views ORDER BY created_at DESC LIMIT 10"

# 查看总体统计
wrangler d1 execute xiaojunhong-analytics --command="SELECT COUNT(*) as total_views FROM page_views"
```

## 🛠️ 故障排除

### 问题：CORS 错误
**解决**: 在 `wrangler.toml` 中确保 CORS_ORIGIN 设置正确

### 问题：数据库未找到
**解决**: 检查 `database_id` 是否正确设置

### 问题：统计不更新
**解决**:
1. 检查浏览器控制台错误
2. 验证 API URL 是否正确
3. 确认 Workers 已成功部署

## 📝 维护和监控

定期维护任务：

```bash
# 每月清理旧数据（保留最近 90 天）
wrangler d1 execute xiaojunhong-analytics --command="
  DELETE FROM page_views WHERE created_at < datetime('now', '-90 days');
  DELETE FROM podcast_plays WHERE created_at < datetime('now', '-90 days');
"

# 生成统计报告
wrangler d1 execute xiaojunhong-analytics --command="
  SELECT
    DATE(created_at) as date,
    COUNT(*) as views,
    COUNT(DISTINCT ip_hash) as unique_visitors
  FROM page_views
  GROUP BY DATE(created_at)
  ORDER BY date DESC
  LIMIT 30
"
```

## 🎉 完成部署

部署完成后，您的网站将具有：

- ✅ 真实的文章阅读次数统计
- ✅ 真实的网站总访问量统计
- ✅ 真实的播客播放次数统计
- ✅ 访客数量和页面浏览量统计
- ✅ 隐私友好的数据收集

所有假随机数据都已替换为真实的数据库统计！

---

**需要帮助？** 查看：
- [Cloudflare Workers 文档](https://developers.cloudflare.com/workers/)
- [Cloudflare D1 文档](https://developers.cloudflare.com/d1/)