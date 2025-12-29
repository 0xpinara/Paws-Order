# Pet Society Asset Extraction Tools

This folder contains scripts to extract images from the original Pet Society SWF (Flash) files.

## Quick Start Guide

### Step 1: Install JPEXS Free Flash Decompiler

JPEXS is the **best tool** for extracting assets from Flash SWF files. It can work in GUI mode (click files one by one) OR command-line mode (automated batch extraction).

**Download:**
1. Go to: https://github.com/jindrapetrik/jpexs-decompiler/releases
2. Download `ffdec_21.1.0_macos.pkg` (or latest version)
3. Install it

**Verify installation:**
After installation, the jar file is typically at:
- `/Applications/JPEXS/ffdec.jar`

### Step 2: Install Java (if not already installed)

JPEXS requires Java to run.

```bash
# Check if Java is installed
java -version

# If not installed, use Homebrew:
brew install openjdk

# Or download from: https://www.java.com/download/
```

### Step 3: Run Batch Extraction

You have **two options**:

---

## Option A: Python Script (Recommended)

The Python script provides progress tracking, parallel processing, and resume capability.

```bash
cd /Users/pa/PetSocietyMobile/tools

# First, update the JPEXS_JAR_PATH in extract_assets.py if needed
# Then run:

# Test with 10 files first
python3 extract_assets.py --test

# If successful, run full extraction (this takes several hours!)
python3 extract_assets.py --parallel 4
```

**Script options:**
- `--test` - Only process 10 files (for testing)
- `--parallel 4` - Use 4 parallel processes (adjust based on your CPU)
- `--start 1000` - Start from file #1000 (for resuming)
- `--limit 500` - Only process 500 files

---

## Option B: Bash Script

A simpler bash script alternative:

```bash
cd /Users/pa/PetSocietyMobile/tools

# Make it executable
chmod +x batch_extract.sh

# Run it
./batch_extract.sh
```

---

## Option C: JPEXS GUI (Manual)

If you prefer a visual interface:

1. Open JPEXS Free Flash Decompiler
2. Go to `File` → `Open` 
3. Navigate to `/Users/pa/petsociety/static/assets/`
4. Select multiple SWF files (Cmd+A for all)
5. Click `File` → `Export selection...`
6. Choose `Images` and select output folder
7. Click Export

**Note:** This is slow for 25,000+ files. Use scripts for bulk extraction.

---

## After Extraction

Extracted images will be in: `/Users/pa/PetSocietyMobile/assets/sprites/extracted/`

### Organize the Images

The extracted images need to be organized into categories:

```
/assets/sprites/
├── pets/              # Pet body parts, colors, animations
├── furniture/         # Room furniture items
├── decorations/       # Wall decorations, rugs
├── food/              # Food items
├── clothing/          # Pet clothing/accessories
├── ui/                # UI elements, buttons
└── backgrounds/       # Room backgrounds
```

### Identify Asset Types

The original file names are random IDs. You may need to:
1. Look at the extracted images to identify what they are
2. Cross-reference with the XML data files in `/petsociety/static/data/`
3. Rename/reorganize files for easier use in Godot

---

## Estimated Time

- **25,000 files** with 4 parallel processes ≈ **2-4 hours**
- Storage needed: ~500MB - 1GB for extracted PNGs

---

## Troubleshooting

**"JPEXS not found"**
- Update `JPEXS_JAR_PATH` in `extract_assets.py` to the correct path
- Or copy `ffdec.jar` to `/Applications/JPEXS/`

**"Java not found"**
- Install Java: `brew install openjdk`

**"Permission denied"**
- Make sure scripts are executable: `chmod +x *.sh`

**Extraction fails on some files**
- Some files may be corrupted or not contain images
- The scripts will skip these and continue
