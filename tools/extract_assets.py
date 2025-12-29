#!/usr/bin/env python3
"""
Pet Society Asset Batch Extractor
==================================
Automatically extracts all images from SWF files using JPEXS Free Flash Decompiler.

SETUP INSTRUCTIONS:
1. Install Java if not already installed:
   brew install openjdk
   # OR download from https://www.java.com/download/

2. Download JPEXS Free Flash Decompiler:
   https://github.com/jindrapetrik/jpexs-decompiler/releases
   
   Recommended: Download the ZIP version for Mac, extract it, and note the path to ffdec.jar

3. Update JPEXS_JAR_PATH below to point to your ffdec.jar location

4. Run this script:
   python3 extract_assets.py

USAGE:
   python3 extract_assets.py                    # Extract all assets
   python3 extract_assets.py --test             # Test with 10 files first
   python3 extract_assets.py --category pets    # Extract only 'pets' category
   python3 extract_assets.py --parallel 4       # Use 4 parallel processes
"""

import os
import sys
import subprocess
import shutil
import argparse
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
import time

# ============================================
# CONFIGURATION - UPDATE THESE PATHS!
# ============================================

# Path to JPEXS ffdec.jar - Will auto-detect if None
JPEXS_JAR_PATH = None

# Common locations to search for JPEXS:
JPEXS_SEARCH_PATHS = [
    "/Applications/ffdec_24.1.1/ffdec.jar",  # Your current installation
    "/Applications/JPEXS/ffdec.jar",
    "/Applications/FFDec.app/Contents/Java/ffdec.jar",  # macOS .app bundle
    "/Applications/FFDec.app/Contents/MacOS/ffdec.jar",
    "/Applications/ffdec_24.1.1.jar",
    "/Applications/ffdec.jar",
    os.path.expanduser("~/Downloads/ffdec_24.1.1.jar"),
    os.path.expanduser("~/Downloads/ffdec/ffdec.jar"),
    os.path.expanduser("~/Downloads/ffdec_*.jar"),
    "/usr/local/bin/ffdec.jar",
    os.path.expanduser("~/ffdec/ffdec.jar"),
    os.path.join(os.path.dirname(__file__), "ffdec.jar"),  # In tools folder
]

# Source and output directories
SOURCE_DIR = "/Users/pa/petsociety/static/assets"
OUTPUT_DIR = "/Users/pa/PetSocietyMobile/assets/sprites/extracted"

# ============================================
# HELPER FUNCTIONS
# ============================================

class Colors:
    """Terminal colors for pretty output"""
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    END = '\033[0m'
    BOLD = '\033[1m'

def print_header():
    print(f"""
{Colors.CYAN}╔══════════════════════════════════════════════════════════════════╗
║           Pet Society Asset Batch Extractor                       ║
║                                                                    ║
║   Extracts PNG images from Flash SWF files automatically          ║
╚══════════════════════════════════════════════════════════════════╝{Colors.END}
""")

def find_jpexs():
    """Find JPEXS jar file automatically"""
    # If explicit path is set and exists, use it
    if JPEXS_JAR_PATH and os.path.exists(JPEXS_JAR_PATH):
        return JPEXS_JAR_PATH
    
    # Search in common locations
    import glob
    for search_path in JPEXS_SEARCH_PATHS:
        # Handle glob patterns
        matches = glob.glob(search_path)
        for match in matches:
            if os.path.isfile(match) and match.endswith('.jar'):
                return match
            # Check if it's a directory (like .app bundle)
            elif os.path.isdir(match):
                # Look inside .app bundles
                if match.endswith('.app'):
                    # Common locations inside .app bundles
                    inner_paths = [
                        os.path.join(match, "Contents", "Java", "ffdec.jar"),
                        os.path.join(match, "Contents", "Resources", "Java", "ffdec.jar"),
                        os.path.join(match, "Contents", "MacOS", "ffdec.jar"),
                    ]
                    for inner in inner_paths:
                        if os.path.exists(inner):
                            return inner
    
    # Last resort: search in Applications folder
    apps_dir = "/Applications"
    if os.path.exists(apps_dir):
        for item in os.listdir(apps_dir):
            item_path = os.path.join(apps_dir, item)
            # Check if it's an ffdec jar file
            if "ffdec" in item.lower() and item.endswith('.jar'):
                return item_path
            # Check if it's an .app bundle
            elif item.endswith('.app') and "ffdec" in item.lower():
                bundle_jar = os.path.join(item_path, "Contents", "Java", "ffdec.jar")
                if os.path.exists(bundle_jar):
                    return bundle_jar
    
    return None

def check_java():
    """Check if Java is installed"""
    # Check standard java first
    try:
        result = subprocess.run(["java", "-version"], 
                              capture_output=True, text=True, timeout=5)
        return True
    except (FileNotFoundError, subprocess.TimeoutExpired):
        pass
    
    # Check Homebrew's openjdk
    brew_java = "/opt/homebrew/opt/openjdk/bin/java"
    if os.path.exists(brew_java):
        try:
            result = subprocess.run([brew_java, "-version"], 
                                  capture_output=True, text=True, timeout=5)
            return True
        except (FileNotFoundError, subprocess.TimeoutExpired):
            pass
    
    return False

def extract_single_swf(args):
    """Extract images from a single SWF file"""
    swf_path, output_subdir, jpexs_path = args
    
    try:
        # Create output directory
        os.makedirs(output_subdir, exist_ok=True)
        
        # Run JPEXS to extract images
        # JPEXS syntax: -export <itemtypes> <outdirectory> <infile_or_directory>
        # Use java from PATH (which should include Homebrew's openjdk)
        java_cmd = "java"
        # Try to use Homebrew's java if available
        if os.path.exists("/opt/homebrew/opt/openjdk/bin/java"):
            java_cmd = "/opt/homebrew/opt/openjdk/bin/java"
        
        cmd = [
            java_cmd, "-jar", jpexs_path,
            "-export", "image",
            output_subdir,
            swf_path
        ]
        
        result = subprocess.run(
            cmd, 
            capture_output=True, 
            text=True, 
            timeout=60  # 60 second timeout per file
        )
        
        # Count extracted files
        extracted_count = len(list(Path(output_subdir).glob("*.png")))
        extracted_count += len(list(Path(output_subdir).glob("*.jpg")))
        
        if result.returncode == 0 and extracted_count > 0:
            return (True, os.path.basename(swf_path), extracted_count, None)
        elif extracted_count == 0:
            # Remove empty directory
            try:
                shutil.rmtree(output_subdir)
            except:
                pass
            return (False, os.path.basename(swf_path), 0, "No images found")
        else:
            return (False, os.path.basename(swf_path), 0, result.stderr[:100])
            
    except subprocess.TimeoutExpired:
        return (False, os.path.basename(swf_path), 0, "Timeout")
    except Exception as e:
        return (False, os.path.basename(swf_path), 0, str(e)[:100])

def main():
    parser = argparse.ArgumentParser(description='Extract images from Pet Society SWF files')
    parser.add_argument('--test', action='store_true', help='Test mode: only process 10 files')
    parser.add_argument('--parallel', type=int, default=4, help='Number of parallel processes (default: 4)')
    parser.add_argument('--start', type=int, default=0, help='Start from file index (for resuming)')
    parser.add_argument('--limit', type=int, default=None, help='Limit number of files to process')
    parser.add_argument('--source', type=str, default=SOURCE_DIR, help='Source directory with SWF files')
    parser.add_argument('--output', type=str, default=OUTPUT_DIR, help='Output directory for extracted images')
    parser.add_argument('--yes', '-y', action='store_true', help='Skip confirmation prompt')
    args = parser.parse_args()
    
    print_header()
    
    # Check Java
    print(f"{Colors.BLUE}Checking requirements...{Colors.END}")
    if not check_java():
        print(f"\n{Colors.RED}✗ Java is not installed!{Colors.END}")
        print("  Install Java with: brew install openjdk")
        print("  Or download from: https://www.java.com/download/")
        sys.exit(1)
    print(f"  {Colors.GREEN}✓ Java is installed{Colors.END}")
    
    # Find JPEXS
    jpexs_path = find_jpexs()
    if not jpexs_path:
        print(f"\n{Colors.RED}✗ JPEXS Free Flash Decompiler not found!{Colors.END}")
        print(f"\n  Please download from:")
        print(f"  {Colors.CYAN}https://github.com/jindrapetrik/jpexs-decompiler/releases{Colors.END}")
        print(f"\n  After downloading, either:")
        print(f"  1. Place ffdec.jar in one of these locations:")
        for p in [JPEXS_JAR_PATH] + JPEXS_ALT_PATHS[:3]:
            print(f"     {p}")
        print(f"  2. Or edit JPEXS_JAR_PATH in this script")
        sys.exit(1)
    print(f"  {Colors.GREEN}✓ JPEXS found at: {jpexs_path}{Colors.END}")
    
    # Check source directory
    source_dir = args.source
    if not os.path.exists(source_dir):
        print(f"\n{Colors.RED}✗ Source directory not found: {source_dir}{Colors.END}")
        sys.exit(1)
    print(f"  {Colors.GREEN}✓ Source directory found{Colors.END}")
    
    # Get list of files
    all_files = sorted([f for f in os.listdir(source_dir) if os.path.isfile(os.path.join(source_dir, f))])
    total_files = len(all_files)
    print(f"\n{Colors.YELLOW}Found {total_files:,} asset files to process{Colors.END}")
    
    # Apply limits
    if args.test:
        all_files = all_files[:10]
        print(f"{Colors.MAGENTA}TEST MODE: Processing only 10 files{Colors.END}")
    else:
        if args.start > 0:
            all_files = all_files[args.start:]
            print(f"{Colors.MAGENTA}Starting from file #{args.start}{Colors.END}")
        if args.limit:
            all_files = all_files[:args.limit]
            print(f"{Colors.MAGENTA}Limited to {args.limit} files{Colors.END}")
    
    files_to_process = len(all_files)
    
    # Create output directory
    output_dir = args.output
    os.makedirs(output_dir, exist_ok=True)
    print(f"  {Colors.GREEN}✓ Output directory ready: {output_dir}{Colors.END}")
    
    # Confirm
    print(f"\n{Colors.BOLD}Ready to extract {files_to_process:,} files using {args.parallel} parallel processes{Colors.END}")
    if not args.test and not args.yes:
        print(f"{Colors.YELLOW}This may take several hours depending on your system.{Colors.END}")
        try:
            response = input(f"\nProceed? (y/n): ").strip().lower()
            if response != 'y':
                print("Cancelled.")
                sys.exit(0)
        except (EOFError, KeyboardInterrupt):
            print("\nCancelled (non-interactive mode). Use --yes to skip confirmation.")
            sys.exit(0)
    
    # Prepare extraction tasks
    tasks = []
    for filename in all_files:
        swf_path = os.path.join(source_dir, filename)
        output_subdir = os.path.join(output_dir, filename)
        tasks.append((swf_path, output_subdir, jpexs_path))
    
    # Progress tracking
    start_time = time.time()
    success_count = 0
    fail_count = 0
    empty_count = 0
    total_images = 0
    
    print(f"\n{Colors.BLUE}Starting extraction...{Colors.END}")
    print("-" * 60)
    
    # Process files in parallel
    with ThreadPoolExecutor(max_workers=args.parallel) as executor:
        futures = {executor.submit(extract_single_swf, task): task for task in tasks}
        
        for i, future in enumerate(as_completed(futures), 1):
            success, filename, count, error = future.result()
            
            # Update progress
            progress = (i / files_to_process) * 100
            elapsed = time.time() - start_time
            rate = i / elapsed if elapsed > 0 else 0
            eta = (files_to_process - i) / rate if rate > 0 else 0
            
            if success:
                success_count += 1
                total_images += count
                status = f"{Colors.GREEN}✓{Colors.END}"
                detail = f"{count} images"
            else:
                if "No images" in str(error):
                    empty_count += 1
                    status = f"{Colors.YELLOW}○{Colors.END}"
                    detail = "no images"
                else:
                    fail_count += 1
                    status = f"{Colors.RED}✗{Colors.END}"
                    detail = str(error)[:30]
            
            # Print progress line
            eta_str = f"{int(eta//60)}m {int(eta%60)}s" if eta > 0 else "..."
            print(f"\r[{progress:5.1f}%] {status} {filename[:25]:<25} {detail:<20} ETA: {eta_str}    ", end="")
    
    # Final summary
    elapsed_total = time.time() - start_time
    print(f"\n\n{Colors.CYAN}{'='*60}{Colors.END}")
    print(f"{Colors.BOLD}EXTRACTION COMPLETE{Colors.END}")
    print(f"{Colors.CYAN}{'='*60}{Colors.END}")
    print(f"\n  Files processed:  {files_to_process:,}")
    print(f"  {Colors.GREEN}Successful:       {success_count:,} files ({total_images:,} images){Colors.END}")
    print(f"  {Colors.YELLOW}Empty (no images): {empty_count:,} files{Colors.END}")
    print(f"  {Colors.RED}Failed:           {fail_count:,} files{Colors.END}")
    print(f"\n  Time elapsed:     {int(elapsed_total//60)}m {int(elapsed_total%60)}s")
    print(f"  Output location:  {output_dir}")
    
    print(f"\n{Colors.MAGENTA}NEXT STEPS:{Colors.END}")
    print("  1. Review the extracted images")
    print("  2. Organize them into categories (pets, furniture, ui, etc.)")
    print("  3. Import into Godot project")
    print(f"\n{Colors.CYAN}Pro tip: Use 'python3 extract_assets.py --start X' to resume from file X{Colors.END}")

if __name__ == "__main__":
    main()
