#!/bin/bash
# ============================================
# Pet Society Asset Batch Extractor
# ============================================
# This script automatically extracts PNG images
# from ALL SWF files using JPEXS command line
# ============================================

# CONFIGURATION - UPDATE THESE PATHS
JPEXS_JAR="/Applications/JPEXS/ffdec.jar"
# Alternative paths to try:
# JPEXS_JAR="$HOME/Downloads/ffdec/ffdec.jar"
# JPEXS_JAR="/usr/local/bin/ffdec.jar"

SOURCE_DIR="/Users/pa/petsociety/static/assets"
OUTPUT_DIR="/Users/pa/PetSocietyMobile/assets/sprites/extracted"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "============================================"
echo "Pet Society Asset Batch Extractor"
echo "============================================"
echo ""

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo -e "${RED}ERROR: Java is not installed!${NC}"
    echo "Please install Java first:"
    echo "  brew install openjdk"
    echo "  OR download from https://www.java.com/download/"
    exit 1
fi

echo -e "${GREEN}✓ Java is installed${NC}"

# Check if JPEXS exists
if [ ! -f "$JPEXS_JAR" ]; then
    echo -e "${RED}ERROR: JPEXS not found at $JPEXS_JAR${NC}"
    echo ""
    echo "Please download JPEXS Free Flash Decompiler:"
    echo "  https://github.com/jindrapetrik/jpexs-decompiler/releases"
    echo ""
    echo "After downloading, update JPEXS_JAR path in this script"
    echo "Common locations:"
    echo "  /Applications/JPEXS/ffdec.jar"
    echo "  ~/Downloads/ffdec_*/ffdec.jar"
    exit 1
fi

echo -e "${GREEN}✓ JPEXS found${NC}"

# Check source directory
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}ERROR: Source directory not found: $SOURCE_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Source directory found${NC}"

# Create output directory
mkdir -p "$OUTPUT_DIR"
echo -e "${GREEN}✓ Output directory ready: $OUTPUT_DIR${NC}"

# Count files
TOTAL_FILES=$(ls -1 "$SOURCE_DIR" | wc -l | tr -d ' ')
echo ""
echo -e "${YELLOW}Found $TOTAL_FILES asset files to process${NC}"
echo ""

# Ask for confirmation
read -p "Start extraction? This may take a while. (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Starting extraction..."
echo "============================================"

# Process counter
COUNT=0
SUCCESS=0
FAILED=0

# Process each SWF file
for SWF_FILE in "$SOURCE_DIR"/*; do
    if [ -f "$SWF_FILE" ]; then
        COUNT=$((COUNT + 1))
        FILENAME=$(basename "$SWF_FILE")
        FILE_OUTPUT="$OUTPUT_DIR/$FILENAME"
        
        # Progress indicator
        PERCENT=$((COUNT * 100 / TOTAL_FILES))
        printf "\r[%3d%%] Processing: %-30s" "$PERCENT" "$FILENAME"
        
        # Create output subdirectory
        mkdir -p "$FILE_OUTPUT"
        
        # Extract images using JPEXS
        java -jar "$JPEXS_JAR" -export image "$FILE_OUTPUT" "$SWF_FILE" > /dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            SUCCESS=$((SUCCESS + 1))
        else
            FAILED=$((FAILED + 1))
        fi
        
        # Optional: Stop after X files for testing
        # if [ $COUNT -ge 100 ]; then
        #     break
        # fi
    fi
done

echo ""
echo ""
echo "============================================"
echo "EXTRACTION COMPLETE!"
echo "============================================"
echo -e "Total files:     $COUNT"
echo -e "${GREEN}Successful:      $SUCCESS${NC}"
echo -e "${RED}Failed:          $FAILED${NC}"
echo ""
echo "Extracted images are in:"
echo "  $OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "  1. Review extracted images"
echo "  2. Organize into folders (pets, furniture, ui, etc.)"
echo "  3. Import into Godot project"

