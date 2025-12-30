#!/bin/bash
# Restart complete asset extraction for all files

echo "Starting COMPLETE asset extraction (all types: images, shapes, sprites, buttons, frames)"
echo "This will ensure ZERO loss of visual assets!"
echo ""
echo "Press Ctrl+C to cancel, or wait 5 seconds to start..."
sleep 5

cd /Users/pa/PetSocietyMobile/tools
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

python3 extract_assets.py --yes --parallel 4
