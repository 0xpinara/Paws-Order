#!/bin/bash
# Helper script to setup JPEXS on macOS

echo "========================================="
echo "JPEXS Setup Helper for macOS"
echo "========================================="
echo ""

# Check Java
echo "Checking Java installation..."
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    echo "✓ Java found: $JAVA_VERSION"
else
    echo "✗ Java not found!"
    echo ""
    echo "Please install Java first:"
    echo "  brew install openjdk"
    echo "  OR download from: https://www.java.com/download/"
    exit 1
fi

echo ""
echo "JPEXS Setup Options:"
echo ""
echo "Option 1: Download JAR file (Recommended)"
echo "  1. Go to: https://github.com/jindrapetrik/jpexs-decompiler/releases"
echo "  2. Download 'ffdec_X.X.X.jar' (latest version)"
echo "  3. Save it to this folder: $(pwd)"
echo "  4. Rename it to 'ffdec.jar'"
echo ""
echo "Option 2: Use GUI version"
echo "  1. Download 'ffdec_X.X.X_macos.dmg' or .pkg"
echo "  2. Install it"
echo "  3. Find ffdec.jar in the installed app bundle"
echo ""

# Check if ffdec.jar already exists
if [ -f "ffdec.jar" ]; then
    echo "✓ Found ffdec.jar in current directory"
    echo ""
    echo "Testing JPEXS..."
    java -jar ffdec.jar -version 2>&1 | head -5
    echo ""
    echo "If you see version info above, JPEXS is working!"
else
    echo "ℹ ffdec.jar not found in current directory"
    echo ""
    echo "After downloading, run this script again to verify."
fi

