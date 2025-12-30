#!/usr/bin/env python3
"""
Organize extracted assets by category for Godot project
Creates organized structure and mapping files
"""

import os
import sys
import shutil
import json
from pathlib import Path
from collections import defaultdict

# Paths
EXTRACTED_DIR = "/Users/pa/PetSocietyMobile/assets/sprites/extracted"
ORGANIZED_DIR = "/Users/pa/PetSocietyMobile/assets/sprites/organized"
GODOT_ASSETS_DIR = "/Users/pa/PetSocietyMobile/assets"

# Category mappings - we'll organize by filename patterns and subdirectory types
CATEGORIES = {
    "pets": ["pet", "animal", "body", "head", "ear", "eye", "mouth", "tail"],
    "furniture": ["furniture", "sofa", "chair", "table", "bed", "desk", "shelf", "cabinet"],
    "food": ["food", "cake", "pizza", "burger", "drink", "meal", "snack"],
    "clothing": ["shirt", "pants", "hat", "shoe", "dress", "costume", "accessory"],
    "decorations": ["decoration", "picture", "frame", "rug", "curtain", "lamp"],
    "plants": ["plant", "tree", "flower", "bush"],
    "toys": ["toy", "ball", "doll", "game"],
    "ui": ["button", "icon", "menu", "ui", "panel", "dialog"],
    "backgrounds": ["background", "room", "wall", "floor"],
    "effects": ["effect", "sparkle", "particle", "smoke"]
}

def find_best_asset_in_dir(asset_dir):
    """Find the best quality asset file in a directory"""
    asset_path = Path(asset_dir)
    
    # Priority order: PNG images > SVG shapes > other
    for subdir in ["images", "sprites", "buttons", "frames", "shapes"]:
        subdir_path = asset_path / subdir
        if subdir_path.exists():
            # Get PNG files first
            png_files = list(subdir_path.glob("*.png"))
            if png_files:
                # Prefer larger files (better quality)
                png_files.sort(key=lambda x: x.stat().st_size, reverse=True)
                return png_files[0]
            
            # Then SVG files
            svg_files = list(subdir_path.glob("*.svg"))
            if svg_files:
                return svg_files[0]
            
            # Then JPEG
            jpeg_files = list(subdir_path.glob("*.jpg")) + list(subdir_path.glob("*.jpeg"))
            if jpeg_files:
                jpeg_files.sort(key=lambda x: x.stat().st_size, reverse=True)
                return jpeg_files[0]
    
    return None

def categorize_asset(asset_name, asset_dir):
    """Try to categorize an asset based on filename and content"""
    asset_name_lower = asset_name.lower()
    
    # Check filename patterns
    for category, keywords in CATEGORIES.items():
        for keyword in keywords:
            if keyword in asset_name_lower:
                return category
    
    # Check if it's in images/ subdirectory (likely UI or decoration)
    if (Path(asset_dir) / "images").exists():
        return "ui"
    
    # Default to misc
    return "misc"

def organize_assets():
    """Organize extracted assets into categories"""
    print("=" * 60)
    print("Organizing Assets for Godot Project")
    print("=" * 60)
    
    extracted_path = Path(EXTRACTED_DIR)
    organized_path = Path(ORGANIZED_DIR)
    
    if not extracted_path.exists():
        print(f"Error: Extracted directory not found: {EXTRACTED_DIR}")
        return False
    
    # Create organized directory structure
    organized_path.mkdir(parents=True, exist_ok=True)
    
    for category in CATEGORIES.keys():
        (organized_path / category).mkdir(exist_ok=True)
    (organized_path / "misc").mkdir(exist_ok=True)
    
    # Mapping file: original_filename -> organized_path
    asset_mapping = {}
    category_counts = defaultdict(int)
    
    print(f"\nScanning {EXTRACTED_DIR}...")
    
    # Process each extracted asset directory
    asset_dirs = [d for d in extracted_path.iterdir() if d.is_dir()]
    total = len(asset_dirs)
    
    print(f"Found {total} asset directories to organize\n")
    
    for idx, asset_dir in enumerate(asset_dirs, 1):
        asset_name = asset_dir.name
        
        # Find best asset file
        best_asset = find_best_asset_in_dir(asset_dir)
        
        if not best_asset:
            continue
        
        # Categorize
        category = categorize_asset(asset_name, asset_dir)
        
        # Copy to organized location
        dest_dir = organized_path / category
        dest_file = dest_dir / f"{asset_name}{best_asset.suffix}"
        
        try:
            # Use symlink to save space (or copy for actual files)
            if dest_file.exists():
                # If already exists, skip or create numbered version
                counter = 1
                while dest_file.exists():
                    dest_file = dest_dir / f"{asset_name}_{counter}{best_asset.suffix}"
                    counter += 1
            
            # Create symlink (faster, uses less space)
            if not dest_file.exists():
                dest_file.symlink_to(best_asset)
            
            # Store mapping
            asset_mapping[asset_name] = {
                "category": category,
                "organized_path": str(dest_file.relative_to(organized_path)),
                "original_path": str(best_asset),
                "file_type": best_asset.suffix
            }
            
            category_counts[category] += 1
            
            if idx % 1000 == 0:
                print(f"  Processed {idx}/{total} ({idx*100//total}%)...")
                
        except Exception as e:
            print(f"  Error processing {asset_name}: {e}")
            continue
    
    # Save mapping file
    mapping_file = organized_path / "asset_mapping.json"
    with open(mapping_file, 'w') as f:
        json.dump(asset_mapping, f, indent=2)
    
    # Print summary
    print(f"\n{'=' * 60}")
    print("Organization Complete!")
    print(f"{'=' * 60}\n")
    
    print("Assets organized by category:")
    for category, count in sorted(category_counts.items(), key=lambda x: x[1], reverse=True):
        print(f"  {category:15s}: {count:6d} assets")
    
    total_organized = sum(category_counts.values())
    print(f"\n  {'TOTAL':15s}: {total_organized:6d} assets")
    print(f"\nMapping file saved to: {mapping_file}")
    print(f"Organized assets in: {organized_path}")
    
    return True

def copy_to_godot():
    """Copy organized assets to Godot project structure"""
    print("\n" + "=" * 60)
    print("Copying Assets to Godot Project")
    print("=" * 60)
    
    organized_path = Path(ORGANIZED_DIR)
    godot_assets = Path(GODOT_ASSETS_DIR)
    
    # Create Godot asset structure
    godot_sprites = godot_assets / "sprites"
    godot_sprites.mkdir(parents=True, exist_ok=True)
    
    # Map categories to Godot folders
    godot_category_map = {
        "pets": "pet",
        "furniture": "items",
        "food": "items",
        "clothing": "items",
        "decorations": "items",
        "plants": "items",
        "toys": "items",
        "ui": "ui",
        "backgrounds": "rooms",
        "effects": "effects",
        "misc": "items"
    }
    
    # Copy each category
    for category_dir in organized_path.iterdir():
        if not category_dir.is_dir() or category_dir.name == "misc":
            continue
        
        godot_folder = godot_category_map.get(category_dir.name, "items")
        dest_dir = godot_sprites / godot_folder
        dest_dir.mkdir(parents=True, exist_ok=True)
        
        # Copy all files (follow symlinks)
        for asset_file in category_dir.iterdir():
            if asset_file.is_file() or asset_file.is_symlink():
                dest_file = dest_dir / asset_file.name
                if not dest_file.exists():
                    if asset_file.is_symlink():
                        # Copy the actual file, not the symlink
                        shutil.copy2(asset_file.readlink() if asset_file.readlink().is_absolute() else asset_file, dest_file)
                    else:
                        shutil.copy2(asset_file, dest_file)
    
    print(f"\nAssets copied to: {godot_sprites}")
    print("Godot project structure ready!")

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--copy-godot":
        copy_to_godot()
    else:
        if organize_assets():
            print("\nTo copy to Godot project, run: python3 organize_assets.py --copy-godot")

