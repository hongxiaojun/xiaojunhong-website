# Cloudflare Pages 配置指南 - xiaojunhong.space

**准备状态**: ✅ GitHub 仓库已创建并推送
**仓库地址**: https://github.com/hongxiaojun/xiaojunhong-website
**下一步**: 配置 Cloudflare Pages 自动部署

---

## 🚀 自动部署配置 (推荐)

### 方式一：通过 Cloudflare Web 界面 (推荐新手)

**预计时间**: 5-10 分钟

#### Step 1: 登录 Cloudflare
1. 访问: https://dash.cloudflare.com/
2. 使用你的 Cloudflare 账户登录
3. 如果没有账户，先注册（免费）

#### Step 2: 创建 Pages 项目
1. 在左侧菜单找到 **"Workers & Pages"**
2. 点击 **"Create application"**
3. 选择 **"Pages"** 标签
4. 点击 **"Connect to Git"**

#### Step 3: 连接 GitHub
1. 如果首次使用，点击 **"Connect GitHub"**
2. 授权 Cloudflare 访问你的 GitHub
3. 找到并选择 **"xiaojunhong-website"** 仓库
4. 点击 **"Begin setup"**

#### Step 4: 配置构建设置
在设置页面填写以下信息：

| 设置项 | 值 | 说明 |
|--------|-----|------|
| **Project name** | `xiaojunhong-website` | 项目名称 |
| **Production branch** | `main` | 生产分支 |
| **Framework preset** | `Hugo` | 预设框架 |
| **Build command** | `hugo --minify` | 构建命令 |
| **Build output directory** | `public` | 输出目录 |
| **Root directory** | (留空) | 根目录 |
| **Environment variables** | (可选) | `HUGO_VERSION: 0.161.1` |

#### Step 5: 部署
1. 点击 **"Save and Deploy"**
2. 等待构建完成（通常 1-2 分钟）
3. 构建成功后会显示临时网址：
   ```
   https://xiaojunhong-website.pages.dev
   ```

#### Step 6: 验证部署
访问临时网址验证网站是否正常：
```
https://xiaojunhong-website.pages.dev
```

---

### 方式二：使用 Wrangler CLI (高级用户)

**预计时间**: 3-5 分钟

#### Step 1: 安装 Wrangler
```bash
brew install wrangler
```

#### Step 2: 认证
```bash
wrangler login
```

#### Step 3: 创建 Pages 项目
```bash
wrangler pages project create xiaojunhong-website \
  --production-branch=main \
  --compatibility-date=2026-05-01
```

#### Step 4: 部署
```bash
wrangler pages deploy public --project-name=xiaojunhong-website
```

---

## 🎯 下一步：配置自定义域名

### 准备工作
- ✅ Cloudflare Pages 项目已创建
- ✅ 域名: xiaojunhong.space (已在 Namecheap 购买)
- ⏳ 需要配置 DNS

### 配置步骤

#### Step 1: 在 Cloudflare Pages 添加自定义域名
1. 在你的 Pages 项目中，点击 **"Custom domains"**
2. 点击 **"Set up a custom domain"**
3. 输入域名: `xiaojunhong.space`
4. 点击 **"Continue"**
5. Cloudflare 会显示需要添加的 DNS 记录

#### Step 2: 在 Namecheap 配置 DNS
1. 登录 https://ap.www.namecheap.com/
2. 进入 **"Domain List"** → 找到 **"xiaojunhong.space"** → 点击 **"Manage"**
3. 点击 **"Advanced DNS"** 标签
4. 删除现有记录（如果有）
5. 添加以下记录：

**记录 1:**
- **Type**: `CNAME`
- **Name**: `@`
- **Value**: `xiaojunhong-website.pages.dev`
- **TTL**: Automatic

**记录 2:**
- **Type**: `CNAME`
- **Name**: `www`
- **Value**: `xiaojunhong-website.pages.dev`
- **TTL**: Automatic

6. 点击 **"Save All Changes"**

#### Step 3: 等待 DNS 生效
- 通常需要 5-30 分钟
- 可以使用 https://www.whatsmydns.net/ 检查状态

---

## 📋 配置清单

### Cloudflare Pages
- [ ] 账户已创建
- [ ] GitHub 已连接
- [ ] 项目已创建
- [ ] 构建配置正确
- [ ] 首次部署成功
- [ ] 临时网址可访问

### 自定义域名
- [ ] 自定义域名已添加
- [ ] DNS 记录已配置
- [ ] DNS 已生效
- [ ] HTTPS 证书已激活
- [ ] xiaojunhong.space 可访问

---

## 🔧 故障排除

### 构建失败
**问题**: Cloudflare Pages 构建失败

**解决方案**:
1. 检查构建日志中的错误信息
2. 确认构建命令是: `hugo --minify`
3. 确认输出目录是: `public`
4. 检查 Hugo 版本兼容性

### DNS 未生效
**问题**: 域名无法访问

**解决方案**:
1. 使用 DNS 检查工具验证: https://www.whatsmydns.net/
2. 确认 DNS 记录配置正确
3. 等待更长时间（最长 24 小时）
4. 清除浏览器 DNS 缓存

### HTTPS 证书问题
**问题**: 证书未激活

**解决方案**:
1. 在 Cloudflare Pages 中检查证书状态
2. 确认 DNS 已正确指向 Cloudflare
3. 等待证书自动签发（通常几分钟）

---

## 📞 需要帮助？

如果遇到问题：
1. 查看构建日志
2. 检查 DNS 状态
3. 查看 Cloudflare Pages 文档
4. 联系我获取支持

---

## 📊 预期结果

配置成功后：
- ✅ 网站可通过 https://xiaojunhong.space 访问
- ✅ HTTPS 证书自动生效
- ✅ 全球 CDN 加速
- ✅ 推送代码自动部署

---

**准备就绪！** 现在可以开始配置 Cloudflare Pages 了。
