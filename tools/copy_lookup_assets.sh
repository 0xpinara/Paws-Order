#!/bin/bash
# Convert symlinks in lookup directory to actual files
# This ensures Godot can load the assets properly

LOOKUP_DIR="/Users/pa/PetSocietyMobile/assets/sprites/lookup"
TEMP_DIR="/tmp/godot_asset_copy"

echo "Converting symlinks to actual files for Godot..."
echo "This may take a few minutes..."

cd "$LOOKUP_DIR"

# Count symlinks
total=$(find . -type l | wc -l | tr -d ' ')
echo "Found $total symlinks to convert"

# Create temp directory for batch processing
mkdir -p "$TEMP_DIR"

# Process in batches to avoid memory issues
count=0
for link in $(find . -type l | head -1000); do  # Process first 1000 as test
    if [ -L "$link" ]; then
        target=$(readlink -f "$link" 2>/dev/null || readlink "$link" 2>/dev/null)
        
        # If target exists, copy it
        if [ -f "$target" ]; then
            # Remove symlink
            rm "$link"
            # Copy actual file
            cp "$target" "$link"
            count=$((count + 1))
            
            if [ $((count % 100)) -eq 0 ]; then
                echo "  Processed $count files..."
            fi
        fi
    fi
done

echo ""
echo "✅ Converted $count symlinks to actual files"
echo "Note: Only processed first 1000 files as a test."
echo "To convert all files, edit this script to remove the 'head -1000' limit."

rm -rf "$TEMP_DIR"

