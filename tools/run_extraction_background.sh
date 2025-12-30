#!/bin/bash
# Run asset extraction in complete background mode (no windows, no GUI)

echo "Starting asset extraction in HEADLESS background mode..."
echo "No GUI windows will open - all output goes to log file"
echo ""

cd /Users/pa/PetSocietyMobile/tools
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# Kill any existing extraction processes
pkill -f "extract_assets.py" 2>/dev/null
sleep 1

# Run in background with nohup, redirecting all output to log
# The script now uses -Djava.awt.headless=true to prevent GUI windows
nohup python3 extract_assets.py --yes --parallel 4 > extraction_log.txt 2>&1 &

# Get the process ID
EXTRACTION_PID=$!

echo "✓ Extraction started in background (PID: $EXTRACTION_PID)"
echo ""
echo "Monitor progress with:"
echo "  ./monitor_extraction.sh"
echo ""
echo "View live log with:"
echo "  tail -f extraction_log.txt"
echo ""
echo "Check if still running:"
echo "  pgrep -f extract_assets.py"
echo ""
echo "Stop extraction:"
echo "  pkill -f extract_assets.py"
echo ""
echo "The extraction will run completely in the background with no windows."
echo "It uses Java headless mode to prevent GUI creation."

