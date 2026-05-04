# 网站统计功能配置指南

## 已添加的统计功能

### 1. 页面访问统计
- **位置**: 每个页面底部
- **功能**: 显示页面浏览次数
- **实现**: 使用 localStorage 进行前端统计

### 2. 文章阅读次数
- **位置**: 文章页面元数据区域
- **功能**: 显示文章被阅读的次数
- **样式**: 眼睛图标 + 阅读次数

### 3. 播客播放次数
- **位置**: 播客页面播放器下方
- **功能**: 统计播客被播放的次数
- **触发**: 用户点击播放按钮时计数

### 4. 网站总统计
- **位置**: 主页、文章页、播客页底部
- **包含**:
  - 总访客数
  - 总页面浏览量
  - 播客总播放次数
  - 网站上线天数

## 当前实现方式

目前所有统计都是基于 **localStorage** 的演示版本，数据仅存储在用户浏览器中。

### 演示数据生成
```javascript
// 生成随机演示数据
const baseVisitors = 1250;
const baseViews = 4500;
const basePlays = 890;
```

## 生产环境配置

### 方案 1: Cloudflare Web Analytics (推荐)

1. **获取追踪代码**:
   - 登录 Cloudflare Dashboard
   - 选择你的域名
   - 进入 "Analytics & Logs" → "Web Analytics"
   - 添加网站并获取追踪令牌

2. **配置代码**:
   编辑 `layouts/partials/analytics.html`:
   ```html
   <!-- 替换 YOUR_CLOUDFLARE_ANALYTICS_TOKEN -->
   <script defer src='https://static.cloudflareinsights.com/beacon.min.js'
   data-cf-beacon='{"token": "YOUR_CLOUDFLARE_ANALYTICS_TOKEN"}'></script>
   ```

### 方案 2: 自建后端 API

如果需要精确的统计数据，可以创建简单的 API：

1. **创建 Cloudflare Worker**:
   ```javascript
   // worker.js
   export default {
     async fetch(request, env) {
       const url = new URL(request.url);

       if (url.pathname === '/api/pageview') {
         // 处理页面浏览统计
         const data = await request.json();
         await env.PAGES.put(data.path, JSON.stringify({
           views: (currentViews || 0) + 1
         }));
         return new Response(JSON.stringify({ success: true }));
       }

       if (url.pathname === '/api/stats') {
         // 返回统计数据
         return new Response(JSON.stringify({
           visitors: 1250,
           views: 4500,
           plays: 890
         }));
       }
     }
   };
   ```

2. **配置 KV 存储**:
   ```bash
   wrangler kv:namespace create STATISTICS
   ```

3. **更新前端代码**:
   在 `layouts/partials/analytics.html` 中启用 API 调用：
   ```javascript
   // 取消注释 fetch 调用
   fetch('/api/pageview', {
       method: 'POST',
       headers: { 'Content-Type': 'application/json' },
       body: JSON.stringify({ path: path })
   });
   ```

### 方案 3: 第三方服务

#### Google Analytics
```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

#### 百度统计
```html
<script>
var _hmt = _hmt || [];
(function() {
  var hm = document.createElement("script");
  hm.src = "https://hm.baidu.com/hm.js?YOUR_SITE_ID";
  var s = document.getElementsByTagName("script")[0];
  s.parentNode.insertBefore(hm, s);
})();
</script>
```

## 自定义统计组件

### 添加新的统计项

1. 在 `layouts/partials/visitor-stats.html` 中添加新的统计卡片:
   ```html
   <div class="stat-card">
       <div class="stat-icon">📊</div>
       <div class="stat-content">
           <div class="stat-number" data-custom-stat>Loading...</div>
           <div class="stat-label">Custom Stat</div>
       </div>
   </div>
   ```

2. 在 JavaScript 中添加更新逻辑:
   ```javascript
   const customEl = document.querySelector('[data-custom-stat]');
   if (customEl) customEl.textContent = formatNumber(customValue);
   ```

### 修改统计样式

所有样式都包含在各自的 partial 文件中，可以直接修改：

- `layouts/partials/analytics.html` - 页面分析样式
- `layouts/partials/stats.html` - 阅读次数样式
- `layouts/partials/podcast-stats.html` - 播客统计样式
- `layouts/partials/visitor-stats.html` - 访客统计样式

## 隐私保护建议

1. **匿名化数据**: 不收集用户个人信息
2. **本地存储**: 使用 localStorage 缓存，减少服务器请求
3. ** aggregated**: 只显示聚合数据，不显示个人行为
4. **合规性**: 遵守 GDPR 和其他隐私法规

## 性能优化

1. **异步加载**: 所有统计脚本都是异步加载
2. **本地缓存**: 使用 localStorage 减少网络请求
3. **懒加载**: 统计数据延迟 30 秒更新一次
4. **CDN**: 使用 Cloudflare CDN 加速

## 故障排除

### 统计数据不更新
- 检查浏览器是否支持 localStorage
- 清除浏览器缓存和 localStorage
- 检查控制台是否有 JavaScript 错误

### 样式问题
- 检查 CSS 变量是否正确定义
- 确认主题切换功能正常
- 检查响应式断点是否生效

### API 调用失败
- 检查 Cloudflare Worker 是否正确部署
- 确认 KV 存储已绑定
- 检查 API 路径配置是否正确

## 未来改进

- [ ] 添加实时在线人数统计
- [ ] 实现热门文章排行榜
- [ ] 添加地理位置统计
- [ ] 集成搜索关键词分析
- [ ] 添加导出报表功能
- [ ] 实现数据可视化图表