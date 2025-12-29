#!/bin/bash
# Quick script to check extraction progress

LOG_FILE="/Users/pa/PetSocietyMobile/tools/extraction_log.txt"
OUTPUT_DIR="/Users/pa/PetSocietyMobile/assets/sprites/extracted"

echo "Extraction Progress Checker"
echo "=========================="
echo ""

# Check if process is running
if pgrep -f "extract_assets.py" > /dev/null; then
    echo "✓ Extraction is running"
    echo ""
    # Show last 20 lines of log
    if [ -f "$LOG_FILE" ]; then
        echo "Recent log output:"
        echo "------------------"
        tail -20 "$LOG_FILE"
    fi
else
    echo "✗ Extraction process not found (may have finished)"
    if [ -f "$LOG_FILE" ]; then
        echo ""
        echo "Last log entries:"
        echo "------------------"
        tail -30 "$LOG_FILE"
    fi
fi

echo ""
echo "Extracted files so far:"
echo "----------------------"
if [ -d "$OUTPUT_DIR" ]; then
    TOTAL_DIRS=$(find "$OUTPUT_DIR" -mindepth 1 -type d | wc -l | tr -d ' ')
    TOTAL_IMAGES=$(find "$OUTPUT_DIR" -type f \( -name "*.png" -o -name "*.jpg" \) | wc -l | tr -d ' ')
    echo "  Directories created: $TOTAL_DIRS"
    echo "  Images extracted: $TOTAL_IMAGES"
else
    echo "  Output directory not found yet"
fi

