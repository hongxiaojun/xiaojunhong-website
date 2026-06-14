#!/bin/bash

# WebP Conversion Script using cwebp (Google's WebP encoder)
# High-quality conversion with automatic quality adjustment

set -e

COVER_DIR="static/images/article-covers"
BACKUP_DIR="$COVER_DIR/png-backup"
LOG_FILE="webp-conversion-cwebp.log"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== WebP Conversion Script (cwebp) ===${NC}"
echo "This script converts PNG images to WebP format using Google's cwebp encoder."
echo ""

# Check if cwebp is installed
if ! command -v cwebp &> /dev/null; then
    echo -e "${RED}Error: cwebp is not installed.${NC}"
    echo ""
    echo "Please install it using:"
    echo "  brew install webp"
    echo ""
    echo "Or run this script after installation completes:"
    echo "  ./convert-to-webp-cwebp.sh"
    exit 1
fi

echo -e "${GREEN}✓ cwebp found: $(which cwebp)${NC}"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Check if backup exists
if [ ! -d "$BACKUP_DIR/original_png" ]; then
    echo -e "${YELLOW}Creating backup of original PNG files...${NC}"
    mkdir -p "$BACKUP_DIR/original_png"
    cp "$COVER_DIR"/*.png "$BACKUP_DIR/original_png/" 2>/dev/null || true
    echo -e "${GREEN}✓ Backup created at $BACKUP_DIR/original_png${NC}"
else
    echo -e "${GREEN}✓ Backup already exists at $BACKUP_DIR/original_png${NC}"
fi

echo ""
echo "Conversion started at $(date)" > "$LOG_FILE"

# Count total PNG files
total_files=$(find "$COVER_DIR" -maxdepth 1 -name "*.png" -type f | wc -l | tr -d ' ')
echo -e "${BLUE}Found $total_files PNG files to convert${NC}"
echo ""

# Convert each PNG to WebP
converted=0
failed=0
total_original=0
total_webp=0

for img in "$COVER_DIR"/*.png; do
    if [ -f "$img" ]; then
        filename=$(basename "$img")
        webp_file="${img%.png}.webp"

        echo -ne "${BLUE}Converting: $filename${NC} ... "

        # Get original file size
        original_size=$(stat -f%z "$img" 2>/dev/null || stat -c%s "$img" 2>/dev/null)

        # Convert using cwebp with quality 85 (good balance between size and quality)
        if cwebp -q 85 "$img" -o "$webp_file" >/dev/null 2>&1; then
            # Get WebP file size
            webp_size=$(stat -f%z "$webp_file" 2>/dev/null || stat -c%s "$webp_file" 2>/dev/null)

            # Calculate compression ratio
            if [ "$original_size" -gt 0 ]; then
                compression_ratio=$(echo "scale=2; (1 - $webp_size / $original_size) * 100" | bc)
                saved_bytes=$((original_size - webp_size))

                echo -e "${GREEN}✓${NC} $(numfmt --to=iec-i --suffix=B $original_size 2>/dev/null || echo $original_size) → $(numfmt --to=iec-i --suffix=B $webp_size 2>/dev/null || echo $webp_size) (${compression_ratio}% saved)"

                echo "✓ $filename: $original_size → $webp_size (${compression_ratio}%)" >> "$LOG_FILE"
            fi

            ((converted++))
            total_original=$((total_original + original_size))
            total_webp=$((total_webp + webp_size))
        else
            echo -e "${RED}✗ Failed${NC}"
            echo "✗ Failed to convert: $filename" >> "$LOG_FILE"
            ((failed++))
        fi
    fi
done

echo ""
echo -e "${GREEN}=== Conversion Complete ===${NC}"
echo "Converted: $converted / $total_files files"
if [ $failed -gt 0 ]; then
    echo -e "${RED}Failed: $failed files${NC}"
fi
echo ""
echo "Total size before: $(numfmt --to=iec-i --suffix=B $total_original 2>/dev/null || echo ${total_original}B)"
echo "Total size after:  $(numfmt --to=iec-i --suffix=B $total_webp 2>/dev/null || echo ${total_webp}B)"

if [ "$total_original" -gt 0 ]; then
    total_savings=$((total_original - total_webp))
    total_percent=$(echo "scale=2; (1 - $total_webp / $total_original) * 100" | bc)
    echo -e "${GREEN}Total saved:       $(numfmt --to=iec-i --suffix=B $total_savings 2>/dev/null || echo ${total_savings}B) (${total_percent}%)${NC}"
fi

echo ""
echo "Log saved to: $LOG_FILE"
echo "PNG backup saved to: $BACKUP_DIR/original_png"
echo ""
echo -e "${GREEN}✓ WebP conversion completed successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. Test the website to ensure WebP images display correctly"
echo "2. If everything looks good, you can deploy to production"
echo "3. Original PNG files are backed up and can be restored if needed"
