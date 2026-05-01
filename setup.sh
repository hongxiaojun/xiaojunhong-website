#!/bin/bash

# Setup script for xiaojunhong.space personal website
# This script helps beginners get started with the project

set -e  # Exit on any error

echo "🎯 Setting up xiaojunhong.space website..."
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed."
    echo "Please install Homebrew first:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Check if Hugo is installed
if ! command -v hugo &> /dev/null; then
    echo "📦 Installing Hugo..."
    brew install hugo
    echo "✅ Hugo installed successfully!"
else
    echo "✅ Hugo is already installed: $(hugo version)"
fi

echo ""
echo "🚀 Starting local development server..."
echo "Your website will be available at: http://localhost:1313"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start Hugo server
hugo server -D
