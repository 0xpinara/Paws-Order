#!/usr/bin/env python3
"""
Quick script to find and test JPEXS installation
"""
import os
import glob
import subprocess

def find_jpexs():
    """Find JPEXS jar file"""
    search_paths = [
        "/Applications/JPEXS/ffdec.jar",
        "/Applications/FFDec.app/Contents/Java/ffdec.jar",
        "/Applications/FFDec.app/Contents/MacOS/ffdec.jar",
        "/Applications/FFDec.app/Contents/Resources/Java/ffdec.jar",
        "/Applications/ffdec_24.1.1.jar",
        "/Applications/ffdec.jar",
        os.path.expanduser("~/Downloads/ffdec_24.1.1.jar"),
        os.path.expanduser("~/Downloads/ffdec/ffdec.jar"),
        os.path.expanduser("~/Downloads/ffdec_*.jar"),
        os.path.join(os.path.dirname(__file__), "ffdec.jar"),
    ]
    
    # Search all paths
    for path in search_paths:
        matches = glob.glob(path)
        for match in matches:
            if os.path.isfile(match) and match.endswith('.jar'):
                return match
            elif os.path.isdir(match) and match.endswith('.app'):
                # Check inside .app bundle
                inner_paths = [
                    os.path.join(match, "Contents", "Java", "ffdec.jar"),
                    os.path.join(match, "Contents", "Resources", "Java", "ffdec.jar"),
                    os.path.join(match, "Contents", "MacOS", "ffdec.jar"),
                ]
                for inner in inner_paths:
                    if os.path.exists(inner):
                        return inner
    
    # Search Applications folder
    apps_dir = "/Applications"
    if os.path.exists(apps_dir):
        try:
            for item in os.listdir(apps_dir):
                item_path = os.path.join(apps_dir, item)
                if "ffdec" in item.lower():
                    if item.endswith('.jar') and os.path.isfile(item_path):
                        return item_path
                    elif item.endswith('.app'):
                        bundle_jar = os.path.join(item_path, "Contents", "Java", "ffdec.jar")
                        if os.path.exists(bundle_jar):
                            return bundle_jar
        except PermissionError:
            pass
    
    return None

def test_jpexs(jar_path):
    """Test if JPEXS works"""
    try:
        result = subprocess.run(
            ["java", "-jar", jar_path, "-version"],
            capture_output=True,
            text=True,
            timeout=10
        )
        return result.returncode == 0, result.stdout + result.stderr
    except Exception as e:
        return False, str(e)

if __name__ == "__main__":
    print("=" * 60)
    print("Searching for JPEXS FFDec...")
    print("=" * 60)
    
    jar_path = find_jpexs()
    
    if jar_path:
        print(f"\n✓ Found JPEXS at:")
        print(f"  {jar_path}")
        print(f"\nTesting JPEXS...")
        
        success, output = test_jpexs(jar_path)
        if success:
            print("✓ JPEXS is working correctly!")
            if output:
                print(f"\nVersion info:\n{output[:200]}")
            print(f"\n✓ You're ready to extract assets!")
            print(f"\nRun: python3 extract_assets.py --test")
        else:
            print("✗ JPEXS found but failed to run")
            print(f"Error: {output}")
            print("\nMake sure Java is installed: java -version")
    else:
        print("\n✗ JPEXS not found!")
        print("\nPlease ensure:")
        print("  1. FFDec is installed in /Applications/")
        print("  2. Or download ffdec_24.1.1.jar and place it in:")
        print(f"     {os.path.dirname(__file__)}")
        print("\nDownload from: https://github.com/jindrapetrik/jpexs-decompiler/releases")

