#!/usr/bin/env python3
"""
Organize extracted assets for Godot project
Creates a hash-based lookup system compatible with original game
"""

import os
import sys
import shutil
import json
from pathlib import Path
from collections import defaultdict

# Paths
EXTRACTED_DIR = "/Users/pa/PetSocietyMobile/assets/sprites/extracted"
GODOT_ASSETS_DIR = "/Users/pa/PetSocietyMobile/assets/sprites"

def find_best_asset_file(asset_dir):
    """Find the best quality PNG/JPEG asset file in a directory"""
    asset_path = Path(asset_dir)
    
    # Priority: images/ > sprites/ > buttons/ > frames/
    for subdir in ["images", "sprites", "buttons", "frames"]:
        subdir_path = asset_path / subdir
        if subdir_path.exists():
            # Get PNG files first
            png_files = list(subdir_path.glob("*.png"))
            if png_files:
                # Prefer largest file (better quality)
                png_files.sort(key=lambda x: x.stat().st_size, reverse=True)
                return png_files[0], "png"
            
            # Then JPEG
            jpeg_files = list(subdir_path.glob("*.jpg")) + list(subdir_path.glob("*.jpeg"))
            if jpeg_files:
                jpeg_files.sort(key=lambda x: x.stat().st_size, reverse=True)
                return jpeg_files[0], "jpg"
    
    return None, None

def create_asset_lookup():
    """Create a lookup system for assets by SWF filename"""
    print("=" * 70)
    print("Creating Asset Lookup System for Godot")
    print("=" * 70)
    
    extracted_path = Path(EXTRACTED_DIR)
    godot_assets = Path(GODOT_ASSETS_DIR)
    
    # Create organized structure in Godot assets
    lookup_dir = godot_assets / "lookup"  # Assets organized by filename for hash lookup
    lookup_dir.mkdir(parents=True, exist_ok=True)
    
    # Also create categorized folders for common assets
    categories_dir = godot_assets / "categorized"
    categories_dir.mkdir(parents=True, exist_ok=True)
    
    # Asset lookup: filename -> best asset path
    asset_lookup = {}
    stats = {
        "total": 0,
        "with_png": 0,
        "with_jpg": 0,
        "no_assets": 0
    }
    
    print(f"\nScanning {len(list(extracted_path.iterdir()))} asset directories...\n")
    
    asset_dirs = sorted([d for d in extracted_path.iterdir() if d.is_dir()])
    total = len(asset_dirs)
    
    for idx, asset_dir in enumerate(asset_dirs, 1):
        asset_name = asset_dir.name
        stats["total"] += 1
        
        # Find best asset
        best_file, file_type = find_best_asset_file(asset_dir)
        
        if not best_file:
            stats["no_assets"] += 1
            continue
        
        if file_type == "png":
            stats["with_png"] += 1
        elif file_type == "jpg":
            stats["with_jpg"] += 1
        
        # Create symlink in lookup directory (organized by filename)
        lookup_file = lookup_dir / f"{asset_name}.{file_type}"
        
        try:
            # Remove old symlink if exists
            if lookup_file.exists() or lookup_file.is_symlink():
                lookup_file.unlink()
            
            # Create symlink to original file
            lookup_file.symlink_to(os.path.relpath(best_file, lookup_file.parent))
            
            # Store in lookup
            asset_lookup[asset_name] = {
                "path": f"res://assets/sprites/lookup/{asset_name}.{file_type}",
                "original_path": str(best_file),
                "type": file_type,
                "size": best_file.stat().st_size
            }
            
        except Exception as e:
            print(f"  Error with {asset_name}: {e}")
            continue
        
        # Progress update
        if idx % 2500 == 0:
            print(f"  Processed {idx}/{total} ({idx*100//total}%)...")
    
    # Save lookup JSON
    lookup_json = godot_assets / "asset_lookup.json"
    with open(lookup_json, 'w') as f:
        json.dump(asset_lookup, f, indent=2)
    
    # Print summary
    print(f"\n{'=' * 70}")
    print("Asset Lookup System Created!")
    print(f"{'=' * 70}\n")
    
    print(f"Total asset directories: {stats['total']}")
    print(f"Assets with PNG files:   {stats['with_png']}")
    print(f"Assets with JPEG files:  {stats['with_jpg']}")
    print(f"Assets with no images:   {stats['no_assets']}")
    print(f"Total usable assets:     {stats['with_png'] + stats['with_jpg']}")
    print(f"\nLookup file: {lookup_json}")
    print(f"Lookup directory: {lookup_dir}")
    print(f"\n✅ Asset lookup system ready for Godot!")
    
    return True

if __name__ == "__main__":
    create_asset_lookup()

