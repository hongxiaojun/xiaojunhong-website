#!/bin/bash

# Temporary PNG Optimization Script
# Uses macOS built-in sips tool to reduce PNG file sizes

set -e

COVER_DIR="static/images/article-covers"
BACKUP_DIR="$COVER_DIR/before-optimization"

echo "Starting PNG optimization..."
echo "Optimization started at $(date)" > "png-optimization.log"

# Create backup
mkdir -p "$BACKUP_DIR"
if [ ! -d "$BACKUP_DIR/original" ]; then
    echo "Creating backup..."
    cp -r "$COVER_DIR" "$BACKUP_DIR/original"
fi

# Count files
total_files=$(find "$COVER_DIR" -maxdepth 1 -name "*.png" -type f | wc -l | tr -d ' ')
echo "Found $total_files PNG files to optimize"

# Calculate total size before
total_before=$(du -sb "$COVER_DIR"/*.png 2>/dev/null | awk '{sum+=$1} END {print sum}' || echo "0")

# Optimize each file
optimized=0
for img in "$COVER_DIR"/*.png; do
    if [ -f "$img" ]; then
        filename=$(basename "$img")
        echo "Optimizing: $filename"

        # Get original size
        original_size=$(stat -f%z "$img" 2>/dev/null || stat -c%s "$img" 2>/dev/null)

        # Use sips to optimize (remove metadata, reduce color depth if possible)
        sips -s format png -s formatOptions 80 "$img" --out "$img.tmp" >/dev/null 2>&1

        if [ -f "$img.tmp" ]; then
            # Get optimized size
            optimized_size=$(stat -f%z "$img.tmp" 2>/dev/null || stat -c%s "$img.tmp" 2>/dev/null)

            # Only replace if smaller
            if [ "$optimized_size" -lt "$original_size" ]; then
                mv "$img.tmp" "$img"
                savings=$((original_size - optimized_size))
                percent=$(echo "scale=2; (1 - $optimized_size / $original_size) * 100" | bc)
                echo "  ✓ Saved $(numfmt --to=iec-i --suffix=B $savings 2>/dev/null || echo $savings) (${percent}%)"
            else
                rm "$img.tmp"
                echo "  - No improvement"
            fi
        fi

        ((optimized++))
    fi
done

# Calculate total size after
total_after=$(du -sb "$COVER_DIR"/*.png 2>/dev/null | awk '{sum+=$1} END {print sum}' || echo "0")

echo ""
echo "=== Optimization Complete ==="
echo "Optimized: $optimized / $total_files files"
echo "Total size before: $(numfmt --to=iec-i --suffix=B $total_before 2>/dev/null || echo ${total_before}B)"
echo "Total size after:  $(numfmt --to=iec-i --suffix=B $total_after 2>/dev/null || echo ${total_after}B)"

if [ "$total_before" -gt 0 ]; then
    total_savings=$((total_before - total_after))
    total_percent=$(echo "scale=2; (1 - $total_after / $total_before) * 100" | bc)
    echo "Total saved:       $(numfmt --to=iec-i --suffix=B $total_savings 2>/dev/null || echo ${total_savings}B) (${total_percent}%)"
fi

echo ""
echo "PNG optimization completed!"
