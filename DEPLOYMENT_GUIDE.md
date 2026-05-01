# Deployment Guide for Beginners

This guide will walk you through deploying your personal website step by step. Don't worry if you're new to this - I'll explain everything!

## Phase 1: Test Locally First

Before going online, let's make sure everything works on your computer.

### Step 1: Install Hugo

Hugo is the tool that builds your website.

**Option A: Using Homebrew (recommended for macOS)**
```bash
brew install hugo
```

**Option B: Manual installation**
1. Go to https://gohugo.io/installation/
2. Download the macOS installer
3. Follow the installation prompts

### Step 2: Test the Website

```bash
# Navigate to your project directory
cd /Users/add/xiaojunhong-website

# Start the development server
hugo server -D
```

Open your browser and go to: http://localhost:1313

You should see your website! If it works, great! If not, let me know.

### Step 3: Customize Content

Edit these files to make it yours:
- `config.toml` - Change site title, add your name
- `content/about/_index.md` - Update the about page
- `content/articles/welcome.md` - Edit or delete the welcome post

## Phase 2: Put Code on GitHub

GitHub is where your code lives and where Cloudflare will look for changes.

### Step 1: Create GitHub Account

If you don't have one:
1. Go to https://github.com/
2. Click "Sign up"
3. Follow the instructions

### Step 2: Create a New Repository

1. On GitHub, click the "+" → "New repository"
2. Name it: `xiaojunhong-website`
3. Make it "Public" (required for Cloudflare Pages free tier)
4. Don't initialize with README (we already have one)
5. Click "Create repository"

### Step 3: Push Your Code

```bash
# Go to your project directory
cd /Users/add/xiaojunhong-website

# Add all files
git add .

# Commit changes
git commit -m "Initial commit"

# Rename branch to main
git branch -M main

# Add GitHub repository (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/xiaojunhong-website.git

# Push to GitHub
git push -u origin main
```

## Phase 3: Connect Cloudflare Pages

Now we'll tell Cloudflare to automatically deploy your website.

### Step 1: Sign Up for Cloudflare

1. Go to https://dash.cloudflare.com/
2. Sign up for a free account
3. Verify your email

### Step 2: Connect GitHub to Cloudflare

1. In Cloudflare dashboard, go to "Workers & Pages"
2. Click "Create application"
3. Choose "Pages" tab
4. Click "Connect to Git"
5. Authorize GitHub if prompted
6. Select `xiaojunhong-website` repository
7. Click "Begin setup"

### Step 3: Configure Build Settings

Enter these settings:
- **Project name**: `xiaojunhong-website`
- **Production branch**: `main`
- **Build command**: `hugo`
- **Build output directory**: `public`
- **Root directory**: (leave empty)

Click "Save and Deploy"

Wait a minute... Your website is now online! Cloudflare will give you a URL like:
`https://xiaojunhong-website.pages.dev`

## Phase 4: Connect Your Domain

Now let's use your xiaojunhong.space domain.

### Step 1: Add Domain in Cloudflare Pages

1. In your Pages project, go to "Custom domains"
2. Click "Set up a custom domain"
3. Enter: `xiaojunhong.space`
4. Click "Continue"

Cloudflare will show you DNS records to add.

### Step 2: Configure Namecheap

1. Log in to Namecheap
2. Go to "Domain List" → find "xiaojunhong.space" → click "Manage"
3. Go to "Advanced DNS" tab
4. Click "Add New Record"

Add these records:

**Record 1:**
- Type: `CNAME`
- Name: `@`
- Value: `xiaojunhong-website.pages.dev`
- TTL: Automatic

**Record 2:**
- Type: `CNAME`
- Name: `www`
- Value: `xiaojunhong-website.pages.dev`
- TTL: Automatic

5. Save changes

### Step 3: Wait for DNS Propagation

This can take anywhere from 5 minutes to 24 hours (usually within 30 minutes).

You can check progress at: https://www.whatsmydns.net/

### Step 4: Verify

Once propagated, visit https://xiaojunhong.space and you should see your website!

## Phase 5: Update Your Website

Now the easy part! Whenever you want to add or update content:

### Create New Content

```bash
cd /Users/add/xiaojunhong-website

# Create new article
hugo new articles/my-new-article.md

# Edit the file
nano content/articles/my-new-article.md
```

### Publish Changes

```bash
# Save changes
git add .
git commit -m "Add new article"
git push
```

That's it! Cloudflare will automatically detect the push and rebuild your website.

## Troubleshooting

**Website doesn't load:**
- Check Cloudflare Pages deployment log for errors
- Make sure GitHub repository is public
- Verify DNS settings in Namecheap

**Build fails:**
- Check the build log in Cloudflare Pages
- Make sure Hugo is installed locally and builds without errors
- Test locally first: `hugo`

**Domain not working:**
- DNS propagation takes time (up to 24 hours)
- Check DNS records in Namecheap match what Cloudflare shows
- Use a DNS checker tool to verify propagation

**Images not showing:**
- Put images in `static/images/` folder
- Reference as `/images/filename.jpg` (note the leading slash)

## Next Steps

1. Customize the design in `layouts/_default/baseof.html`
2. Add your real content
3. Set up analytics (optional)
4. Configure social media links
5. Learn more Hugo features

## Need Help?

- Hugo Docs: https://gohugo.io/documentation/
- Cloudflare Pages: https://developers.cloudflare.com/pages/
- GitHub Guides: https://guides.github.com/

Remember: This is a learning process. Take it step by step, and don't hesitate to ask questions!