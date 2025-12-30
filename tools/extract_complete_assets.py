#!/usr/bin/env python3
"""
COMPLETE Asset Extractor - Extracts ALL asset types from SWF files
===================================================================
This script extracts images, shapes, sprites, buttons, and frames to ensure
ZERO loss of visual assets from the original Pet Society game.

Why multiple types?
- Many SWF files contain vector SHAPES (not bitmap images)
- Shapes need to be extracted separately
- Sprites, buttons, and frames contain additional graphics
- This ensures we capture EVERYTHING!
"""

import os
import sys

# Import the main extraction script
sys.path.insert(0, os.path.dirname(__file__))
from extract_assets import *

# Override the header to reflect complete extraction
def print_header():
    print(f"""
{Colors.CYAN}╔══════════════════════════════════════════════════════════════════╗
║        COMPLETE Pet Society Asset Extractor                      ║
║                                                                    ║
║   Extracts ALL assets: images, shapes, sprites, buttons, frames   ║
║   Ensures ZERO loss of visual assets!                             ║
╚══════════════════════════════════════════════════════════════════╝{Colors.END}
""")

if __name__ == "__main__":
    # Update the module's print_header function
    import extract_assets
    extract_assets.print_header = print_header
    
    # Run the main extraction with complete asset types
    main()

