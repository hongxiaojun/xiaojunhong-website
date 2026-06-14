#!/bin/bash

# WebP Conversion Script for Article Cover Images
# Converts PNG images to WebP format for better compression

set -e

COVER_DIR="static/images/article-covers"
BACKUP_DIR="$COVER_DIR/png-backup"
LOG_FILE="webp-conversion.log"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting WebP conversion...${NC}"
echo "Conversion started at $(date)" > "$LOG_FILE"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Check if backup exists
if [ ! -d "$BACKUP_DIR/png" ]; then
    echo -e "${YELLOW}Creating backup of original PNG files...${NC}"
    cp -r "$COVER_DIR" "$BACKUP_DIR/png"
    echo "Backup created at $BACKUP_DIR/png" >> "$LOG_FILE"
else
    echo -e "${GREEN}Backup already exists at $BACKUP_DIR/png${NC}"
fi

# Count total PNG files
total_files=$(find "$COVER_DIR" -maxdepth 1 -name "*.png" -type f | wc -l | tr -d ' ')
echo -e "${BLUE}Found $total_files PNG files to convert${NC}"

# Convert each PNG to WebP
converted=0
failed=0

for img in "$COVER_DIR"/*.png; do
    if [ -f "$img" ]; then
        filename=$(basename "$img")
        webp_file="${img%.png}.webp"

        echo -e "${BLUE}Converting: $filename${NC}"

        # Get original file size
        original_size=$(stat -f%z "$img" 2>/dev/null || stat -c%s "$img" 2>/dev/null)

        # Convert using ffmpeg
        if ffmpeg -i "$img" -c:v libwebp -quality 85 -preset picture "$webp_file" -y 2>/dev/null; then
            # Get WebP file size
            webp_size=$(stat -f%z "$webp_file" 2>/dev/null || stat -c%s "$webp_file" 2>/dev/null)

            # Calculate compression ratio
            if [ "$original_size" -gt 0 ]; then
                compression_ratio=$(echo "scale=2; (1 - $webp_size / $original_size) * 100" | bc)
                echo -e "${GREEN}✓ $filename: $(numfmt --to=iec-i --suffix=B $original_size 2>/dev/null || echo $original_size) → $(numfmt --to=iec-i --suffix=B $webp_size 2>/dev/null || echo $webp_size) (${compression_ratio}% reduction)${NC}"
                echo "✓ $filename: $original_size → $webp_size (${compression_ratio}%)" >> "$LOG_FILE"
            fi

            ((converted++))
        else
            echo -e "${YELLOW}✗ Failed to convert: $filename${NC}"
            echo "✗ Failed to convert: $filename" >> "$LOG_FILE"
            ((failed++))
        fi
    fi
done

# Calculate total size before and after
total_original=$(du -sb "$COVER_DIR"/*.png 2>/dev/null | awk '{sum+=$1} END {print sum}' || echo "0")
total_webp=$(du -sb "$COVER_DIR"/*.webp 2>/dev/null | awk '{sum+=$1} END {print sum}' || echo "0")

echo ""
echo -e "${GREEN}=== Conversion Complete ===${NC}"
echo "Converted: $converted / $total_files files"
echo "Failed: $failed files"
echo ""
echo "Total size before: $(numfmt --to=iec-i --suffix=B $total_original 2>/dev/null || echo ${total_original}B)"
echo "Total size after:  $(numfmt --to=iec-i --suffix=B $total_webp 2>/dev/null || echo ${total_webp}B)"

if [ "$total_original" -gt 0 ]; then
    total_savings=$(echo "scale=2; (1 - $total_webp / $total_original) * 100" | bc)
    total_saved_bytes=$((total_original - total_webp))
    echo "Total saved:       $(numfmt --to=iec-i --suffix=B $total_saved_bytes 2>/dev/null || echo ${total_saved_bytes}B) (${total_savings}%)"
fi

echo ""
echo "Log saved to: $LOG_FILE"
echo "PNG backup saved to: $BACKUP_DIR/png"
echo ""
echo -e "${GREEN}WebP conversion completed successfully!${NC}"
