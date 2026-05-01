#!/bin/bash

# Deployment script for xiaojunhong-website
# This script builds the site and helps with deployment

set -e

echo "🚀 Deploying xiaojunhong.space..."
echo ""

# Check if Hugo is installed
if ! command -v hugo &> /dev/null; then
    echo "❌ Hugo is not installed. Please run: brew install hugo"
    exit 1
fi

# Clean previous build
echo "🧹 Cleaning previous build..."
rm -rf public/

# Build the site
echo "🔨 Building site..."
hugo

# Check if build was successful
if [ -d "public" ]; then
    echo "✅ Build successful!"
    echo ""
    echo "📊 Build statistics:"
    echo "   Files: $(find public -type f | wc -l)"
    echo "   Size: $(du -sh public | cut -f1)"
    echo ""

    # Check if git repo exists
    if [ -d ".git" ]; then
        echo "📦 Ready to deploy!"
        echo ""
        echo "Next steps:"
        echo "1. Review the build: open public/index.html"
        echo "2. Commit changes: git add . && git commit -m 'Update site'"
        echo "3. Push to GitHub: git push"
        echo ""
        echo "Cloudflare Pages will automatically deploy your changes."
    else
        echo "⚠️  Git repository not initialized."
        echo "Run: git init"
    fi
else
    echo "❌ Build failed. Please check for errors."
    exit 1
fi
