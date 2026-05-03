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
