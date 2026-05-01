# xiaojunhong.space

A personal website built with Hugo and hosted on Cloudflare Pages.

## Project Structure

```
xiaojunhong-website/
├── archetypes/          # Content templates for new articles/notes
├── assets/             # CSS, JS, images
├── content/            # Your content (Markdown files)
│   ├── articles/       # Blog posts and tutorials
│   ├── notes/          # Quick notes and thoughts
│   └── about/          # About page
├── layouts/            # HTML templates
│   ├── partials/       # Reusable components (header, footer)
│   └── _default/       # Default templates
├── static/             # Static files (images, favicon, etc.)
└── config.toml         # Hugo configuration
```

## Getting Started

### Prerequisites

1. Install Hugo (extended version):
   ```bash
   # On macOS
   brew install hugo

   # Or download from https://gohugo.io/installation/
   ```

2. Install Git (if not already installed)

### Local Development

1. Preview the website locally:
   ```bash
   hugo server -D
   ```

2. Open your browser to `http://localhost:1313`

3. Edit content and see changes in real-time

### Creating New Content

1. Create a new article:
   ```bash
   hugo new articles/my-article-title.md
   ```

2. Create a new note:
   ```bash
   hugo new notes/my-note-title.md
   ```

3. Edit the created markdown file with your content

4. Remove `draft: true` from the front matter when ready to publish

### Building for Production

```bash
hugo
```

This generates the site in the `public/` directory.

## Deployment to Cloudflare Pages

### First Time Setup

1. **Create a GitHub repository**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/yourusername/xiaojunhong-website.git
   git push -u origin main
   ```

2. **Connect to Cloudflare Pages**
   - Go to https://dash.cloudflare.com/
   - Navigate to Workers & Pages
   - Click "Create application" → "Pages" → "Connect to Git"
   - Select your repository
   - Configure build settings:
     - Build command: `hugo`
     - Build output directory: `public`
     - Root directory: (leave empty)
   - Click "Save and Deploy"

3. **Configure Your Domain**
   - In Cloudflare Pages project, go to "Custom domains"
   - Add `xiaojunhong.space`
   - Follow the DNS instructions

### Configure Namecheap DNS

1. Log in to Namecheap
2. Go to Domain List → xiaojunhong.space → Manage
3. Go to "Advanced DNS"
4. Delete existing records
5. Add these records:
   - Type: CNAME | Name: @ | Value: xiaojunhong.pages.dev
   - Type: CNAME | Name: www | Value: xiaojunhong.pages.dev
6. Save changes

### Automatic Deployments

After initial setup:
- Every git push to main triggers automatic deployment
- Preview deployments available for pull requests
- Zero-downtime deployments

## Content Management

### Front Matter Template

Articles use this format:
```yaml
---
title: "Article Title"
date: 2026-05-01
draft: false
description: "Brief description for listing pages"
readingTime: 5  # Optional: reading time in minutes
---
```

### Writing Content

- Use Markdown for formatting
- Images go in `static/images/`
- Reference images as `![alt text](/images/filename.jpg)`

## Customization

### Styling

Edit CSS in `layouts/_default/baseof.html` in the `<style>` block.

### Navigation

Edit menu items in `config.toml` under `[menu.main]`.

### Site Configuration

Edit `config.toml` to change:
- Site title and description
- Language settings
- Build options
- Menu structure

## Resources

- [Hugo Documentation](https://gohugo.io/documentation/)
- [Cloudflare Pages Guide](https://developers.cloudflare.com/pages/)
- [Markdown Guide](https://www.markdownguide.org/)

## License

© 2026 Xiaojun Hong. All rights reserved.