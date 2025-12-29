#!/usr/bin/env python3
"""Quick test to verify JPEXS setup"""
import subprocess
import os

JPEXS_PATH = "/Applications/ffdec_24.1.1/ffdec.jar"

print("=" * 60)
print("Testing JPEXS Setup")
print("=" * 60)
print()

# Test Java
print("1. Checking Java...")
try:
    result = subprocess.run(["java", "-version"], capture_output=True, text=True, timeout=5)
    print("   ✓ Java is installed")
    print(f"   {result.stderr.splitlines()[0]}")
except Exception as e:
    print(f"   ✗ Java error: {e}")
    exit(1)

print()

# Test JPEXS exists
print("2. Checking JPEXS jar file...")
if os.path.exists(JPEXS_PATH):
    print(f"   ✓ Found: {JPEXS_PATH}")
else:
    print(f"   ✗ Not found: {JPEXS_PATH}")
    exit(1)

print()

# Test JPEXS runs
print("3. Testing JPEXS...")
try:
    result = subprocess.run(
        ["java", "-jar", JPEXS_PATH, "-version"],
        capture_output=True,
        text=True,
        timeout=10
    )
    if result.returncode == 0:
        print("   ✓ JPEXS is working!")
        if result.stdout:
            print(f"   {result.stdout.strip()[:100]}")
    else:
        print(f"   ✗ JPEXS returned error code: {result.returncode}")
        print(f"   {result.stderr[:200]}")
except Exception as e:
    print(f"   ✗ Error running JPEXS: {e}")
    exit(1)

print()
print("=" * 60)
print("✓ Everything is ready!")
print("=" * 60)
print()
print("Next step: Run the extraction script:")
print("  python3 extract_assets.py --test")
print()

