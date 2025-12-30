#!/bin/bash
# Monitor the asset extraction progress

LOG_FILE="/Users/pa/PetSocietyMobile/tools/extraction_log.txt"
OUTPUT_DIR="/Users/pa/PetSocietyMobile/assets/sprites/extracted"

echo "═══════════════════════════════════════════════════════"
echo "  Asset Extraction Monitor"
echo "═══════════════════════════════════════════════════════"
echo ""

# Check if process is running
if pgrep -f "extract_assets.py" > /dev/null; then
    echo "✓ Extraction is RUNNING"
    echo ""
    
    # Show recent progress
    if [ -f "$LOG_FILE" ]; then
        echo "Recent progress (last 15 lines):"
        echo "────────────────────────────────────────────────"
        tail -15 "$LOG_FILE" | grep -E "\[.*\%\]" | tail -10
        echo ""
        
        # Extract stats from log
        SUCCESS=$(grep -o "Successful:[^0-9]*[0-9,]*" "$LOG_FILE" | tail -1 | grep -o "[0-9,]*" | head -1)
        IMAGES=$(grep -o "([0-9,]* images)" "$LOG_FILE" | tail -1 | grep -o "[0-9,]*")
        
        if [ ! -z "$SUCCESS" ]; then
            echo "Files processed so far: $SUCCESS"
        fi
        if [ ! -z "$IMAGES" ]; then
            echo "Assets extracted so far: $IMAGES"
        fi
    fi
else
    echo "✗ Extraction process NOT running"
    echo ""
    
    if [ -f "$LOG_FILE" ]; then
        echo "Final results from log:"
        echo "────────────────────────────────────────────────"
        tail -40 "$LOG_FILE" | grep -A 20 "EXTRACTION COMPLETE" || tail -20 "$LOG_FILE"
    fi
fi

echo ""
echo "Extracted files summary:"
echo "────────────────────────────────────────────────"

if [ -d "$OUTPUT_DIR" ]; then
    TOTAL_DIRS=$(find "$OUTPUT_DIR" -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
    TOTAL_PNG=$(find "$OUTPUT_DIR" -type f -name "*.png" 2>/dev/null | wc -l | tr -d ' ')
    TOTAL_SVG=$(find "$OUTPUT_DIR" -type f -name "*.svg" 2>/dev/null | wc -l | tr -d ' ')
    TOTAL_JPEG=$(find "$OUTPUT_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" \) 2>/dev/null | wc -l | tr -d ' ')
    
    echo "  Directories created: $TOTAL_DIRS"
    echo "  PNG files: $TOTAL_PNG"
    echo "  SVG files: $TOTAL_SVG"
    echo "  JPEG files: $TOTAL_JPEG"
    TOTAL_ASSETS=$((TOTAL_PNG + TOTAL_SVG + TOTAL_JPEG))
    echo "  TOTAL assets: $TOTAL_ASSETS"
else
    echo "  Output directory not found yet"
fi

echo ""
echo "To view full log: tail -f $LOG_FILE"
echo "═══════════════════════════════════════════════════════"

