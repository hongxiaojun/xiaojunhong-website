#!/bin/bash

# Automated WebP Conversion with Wait
# This script waits for brew installation to complete, then runs WebP conversion

echo "=== Automated WebP Conversion Setup ==="
echo ""
echo "This script will:"
echo "1. Wait for brew install webp to complete (if running)"
echo "2. Run the WebP conversion automatically"
echo ""

# Check if brew install is running
if ps aux | grep -v grep | grep "brew install webp" > /dev/null; then
    echo "📦 Waiting for brew install webp to complete..."
    echo ""

    # Wait for brew to finish (check every 10 seconds)
    while ps aux | grep -v grep | grep "brew install webp" > /dev/null; do
        echo "⏳ Still installing... (waiting 10 seconds)"
        sleep 10
    done

    echo "✅ Brew installation completed!"
    echo ""

    # Give it a moment to finalize
    sleep 2
fi

# Check if cwebp is now available
if command -v cwebp &> /dev/null; then
    echo "✅ cwebp is now available: $(which cwebp)"
    echo ""
    echo "🚀 Starting WebP conversion..."
    echo ""

    # Run the conversion script
    ./convert-to-webp-cwebp.sh
else
    echo "❌ cwebp is still not available."
    echo ""
    echo "You may need to:"
    echo "1. Check if brew installation completed successfully"
    echo "2. Run: brew install webp"
    echo "3. Then run: ./convert-to-webp-cwebp.sh"
    exit 1
fi
