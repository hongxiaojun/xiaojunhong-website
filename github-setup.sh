#!/bin/bash

# GitHub repository setup script
# This script helps initialize and push your code to GitHub

echo "🔧 Setting up GitHub repository..."
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "❌ Git repository not initialized. Please run: git init"
    exit 1
fi

# Check if remote already exists
if git remote get-url origin &> /dev/null; then
    echo "⚠️  Git remote 'origin' already exists."
    echo "Current remote: $(git remote get-url origin)"
    echo ""
    read -p "Do you want to update it? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Keeping existing remote."
        exit 0
    fi
fi

# Prompt for GitHub username
echo "Please provide your GitHub username:"
read -p "GitHub username: " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo "❌ GitHub username is required."
    exit 1
fi

# Set remote URL
REMOTE_URL="https://github.com/${GITHUB_USERNAME}/xiaojunhong-website.git"
git remote add origin $REMOTE_URL 2>/dev/null || git remote set-url origin $REMOTE_URL

echo ""
echo "✅ Git remote configured: $REMOTE_URL"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Create repository on GitHub:"
echo "   - Go to: https://github.com/new"
echo "   - Name: xiaojunhong-website"
echo "   - Make it PUBLIC (required for Cloudflare Pages free tier)"
echo "   - Don't initialize with README"
echo ""
echo "2. Push your code:"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "3. Connect to Cloudflare Pages (see DEPLOYMENT_GUIDE.md)"
