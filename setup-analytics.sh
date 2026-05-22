#!/bin/bash

# Analytics System Setup Script
# This script helps deploy the real analytics system

set -e  # Exit on error

echo "🚀 Setting up Real Analytics System for xiaojunhong.space"
echo "=================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    echo -e "${YELLOW}⚠️  Wrangler CLI not found${NC}"
    echo "Installing Wrangler CLI..."
    npm install -g wrangler
fi

echo -e "${GREEN}✅ Wrangler CLI is installed${NC}"

# Check if logged in to Cloudflare
echo ""
echo "📝 Checking Cloudflare authentication..."
if ! wrangler whoami &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not logged in to Cloudflare${NC}"
    echo "Please login to continue..."
    wrangler login
else
    echo -e "${GREEN}✅ Already logged in to Cloudflare${NC}"
    wrangler whoami
fi

# Navigate to workers directory
echo ""
echo "📁 Changing to workers directory..."
cd workers/analytics-api || exit 1

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
npm install

# Create D1 database
echo ""
echo "🗄️  Creating D1 database..."
DB_OUTPUT=$(wrangler d1 create xiaojunhong-analytics 2>&1)
echo "$DB_OUTPUT"

# Extract database ID
DATABASE_ID=$(echo "$DB_OUTPUT" | grep -oP 'database_id = "\K[^"]+')

if [ -z "$DATABASE_ID" ]; then
    echo -e "${RED}❌ Failed to create database or extract database_id${NC}"
    echo "Please create manually: wrangler d1 create xiaojunhong-analytics"
    exit 1
fi

echo -e "${GREEN}✅ Database created with ID: $DATABASE_ID${NC}"

# Update wrangler.toml with database ID
echo ""
echo "🔧 Updating wrangler.toml configuration..."
sed -i.bak "s/database_id = \"YOUR_DATABASE_ID\"/database_id = \"$DATABASE_ID\"/" wrangler.toml
echo -e "${GREEN}✅ Configuration updated${NC}"

# Create database schema (local)
echo ""
echo "🏗️  Creating database schema (local)..."
wrangler d1 execute xiaojunhong-analytics --file=schema.sql --local
echo -e "${GREEN}✅ Local database schema created${NC}"

# Deploy to production
echo ""
echo "🚀 Deploying to production..."
npm run deploy
echo -e "${GREEN}✅ Workers deployed successfully${NC}"

# Create database schema (production)
echo ""
echo "🏗️  Creating database schema (production)..."
wrangler d1 execute xiaojunhong-analytics --file=schema.sql
echo -e "${GREEN}✅ Production database schema created${NC}"

# Get Workers URL
echo ""
echo "🔗 Getting Workers URL..."
WORKERS_URL=$(wrangler deployments list 2>&1 | grep -oP 'https://[^\s]+\.workers\.dev' | head -1)

if [ -z "$WORKERS_URL" ]; then
    WORKERS_URL="https://xiaojunhong-analytics.your-subdomain.workers.dev"
    echo -e "${YELLOW}⚠️  Could not auto-detect Workers URL${NC}"
else
    echo -e "${GREEN}✅ Workers URL: $WORKERS_URL${NC}"
fi

# Update frontend configuration
echo ""
echo "🔧 Updating frontend analytics configuration..."
cd ../..
sed -i.bak "s|https://xiaojunhong-analytics.your-worker.workers.dev|$WORKERS_URL|g" layouts/partials/analytics.html
echo -e "${GREEN}✅ Frontend configuration updated${NC}"

# Test the deployment
echo ""
echo "🧪 Testing deployment..."
sleep 3
curl -s "$WORKERS_URL/api/health" && echo -e "${GREEN}✅ API health check passed${NC}" || echo -e "${RED}❌ API health check failed${NC}"

# Cleanup backup files
echo ""
echo "🧹 Cleaning up backup files..."
rm -f workers/analytics-api/wrangler.toml.bak
rm -f layouts/partials/analytics.html.bak

echo ""
echo "=================================================="
echo -e "${GREEN}🎉 Analytics system setup complete!${NC}"
echo ""
echo "📝 Next steps:"
echo "1. Test the analytics: Visit your website and check browser console"
echo "2. Monitor data: Use the query commands in ANALYTICS_SETUP_GUIDE.md"
echo "3. Update custom domain (optional): Configure Workers custom domain"
echo ""
echo "🔗 Workers URL: $WORKERS_URL"
echo "📚 Setup guide: ANALYTICS_SETUP_GUIDE.md"
echo ""
echo "✨ Your website now has real analytics!"