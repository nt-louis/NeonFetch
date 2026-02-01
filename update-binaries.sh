#!/bin/bash
# Update yt-dlp and ffmpeg binaries (Linux/macOS version)

set -e

# Configuration
BIN_DIR="$(dirname "$0")/resources/bin"
TEMP_DIR="$(dirname "$0")/temp-downloads"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}===================================${NC}"
echo -e "${CYAN}  Binary Update Script${NC}"
echo -e "${CYAN}===================================${NC}"
echo ""

# Create directories
mkdir -p "$BIN_DIR"
mkdir -p "$TEMP_DIR"

# Clean temp directory
echo -e "${CYAN}Cleaning temporary directory...${NC}"
rm -rf "$TEMP_DIR"/*

# ===========================
# Update yt-dlp
# ===========================
echo -e "\n${CYAN}[1/2] Updating yt-dlp...${NC}"

YTDLP_PATH="$BIN_DIR/yt-dlp"

# Get current version
CURRENT_VERSION="Not installed"
if [ -f "$YTDLP_PATH" ]; then
    CURRENT_VERSION=$($YTDLP_PATH --version 2>/dev/null || echo "unknown")
fi
echo -e "  Current version: $CURRENT_VERSION"

# Get latest version from GitHub API
echo -e "  Checking for latest version..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')
echo -e "  Latest version available: $LATEST_VERSION"

# Compare versions
if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo -e "  ${GREEN}✓ yt-dlp is already up to date${NC}"
else
    echo -e "  New version available! Downloading..."
    
    # Backup old version
    if [ -f "$YTDLP_PATH" ]; then
        cp "$YTDLP_PATH" "$YTDLP_PATH.bak"
    fi
    
    echo -e "  Downloading latest yt-dlp..."
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o "$YTDLP_PATH"
    chmod +x "$YTDLP_PATH"
    
    if [ -f "$YTDLP_PATH" ]; then
        NEW_VERSION=$($YTDLP_PATH --version)
        echo -e "  ${GREEN}✓ yt-dlp updated from $CURRENT_VERSION to $NEW_VERSION${NC}"
        rm -f "$YTDLP_PATH.bak"
    else
        echo -e "  ${RED}✗ Failed to download yt-dlp${NC}"
        [ -f "$YTDLP_PATH.bak" ] && mv "$YTDLP_PATH.bak" "$YTDLP_PATH"
    fi
fi

# ===========================
# Update FFmpeg
# ===========================
echo -e "\n${CYAN}[2/2] Updating ffmpeg suite...${NC}"

# Get current version
CURRENT_VERSION="Not installed"
if [ -f "$BIN_DIR/ffmpeg" ]; then
    CURRENT_VERSION=$($BIN_DIR/ffmpeg -version 2>/dev/null | head -n1 | grep -oP 'version \K[^ ]+' || echo "unknown")
fi
echo -e "  Current ffmpeg version: $CURRENT_VERSION"

echo -e "  Checking for latest version..."

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - use homebrew or download static builds
    echo -e "  ${YELLOW}For macOS, please use Homebrew:${NC}"
    echo -e "  ${YELLOW}  brew install ffmpeg${NC}"
    echo -e "  ${YELLOW}Then copy binaries to $BIN_DIR:${NC}"
    echo -e "  ${YELLOW}  cp /opt/homebrew/bin/ffmpeg $BIN_DIR/${NC}"
    echo -e "  ${YELLOW}  cp /opt/homebrew/bin/ffplay $BIN_DIR/${NC}"
    echo -e "  ${YELLOW}  cp /opt/homebrew/bin/ffprobe $BIN_DIR/${NC}"
else
    # Linux - download static builds from johnvansickle.com
    # Try to get latest version info
    LATEST_VERSION=$(curl -s "https://api.github.com/repos/FFmpeg/FFmpeg/releases/latest" | grep -oP '"tag_name": "n\K[^"]+' || echo "unknown")
    echo -e "  Latest version available: $LATEST_VERSION"
    
    # Compare versions
    if [ "$CURRENT_VERSION" != "unknown" ] && [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
        echo -e "  ${GREEN}✓ ffmpeg suite is already up to date${NC}"
    else
        echo -e "  New version available! Downloading..."
        FFMPEG_URL="https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz"
        FFMPEG_ARCHIVE="$TEMP_DIR/ffmpeg.tar.xz"
        
        echo -e "  Downloading ffmpeg static build from johnvansickle.com..."
        echo -e "  This may take a minute (file is ~80MB)..."
        curl -L "$FFMPEG_URL" -o "$FFMPEG_ARCHIVE"
        
        echo -e "  Extracting archive..."
        tar -xf "$FFMPEG_ARCHIVE" -C "$TEMP_DIR"
        
        # Find the extracted directory
        FFMPEG_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "ffmpeg-*-amd64-static" | head -n 1)
        
        if [ -d "$FFMPEG_DIR" ]; then
            for exe in ffmpeg ffplay ffprobe; do
                if [ -f "$FFMPEG_DIR/$exe" ]; then
                    [ -f "$BIN_DIR/$exe" ] && cp "$BIN_DIR/$exe" "$BIN_DIR/$exe.bak"
                    cp "$FFMPEG_DIR/$exe" "$BIN_DIR/"
                    chmod +x "$BIN_DIR/$exe"
                    
                    if [ "$exe" = "ffmpeg" ]; then
                        NEW_VERSION=$($BIN_DIR/$exe -version 2>/dev/null | head -n1 | grep -oP 'version \K[^ ]+')
                        echo -e "  ${GREEN}✓ $exe updated to version: $NEW_VERSION${NC}"
                    else
                        echo -e "  ${GREEN}✓ $exe updated successfully${NC}"
                    fi
                    
                    rm -f "$BIN_DIR/$exe.bak"
                fi
            done
        else
            echo -e "  ${RED}✗ Failed to extract ffmpeg${NC}"
        fi
    fi
fi

# Clean up
echo -e "\n${CYAN}Cleaning up temporary files...${NC}"
rm -rf "$TEMP_DIR"

# Summary
echo -e "\n${CYAN}===================================${NC}"
echo -e "${GREEN}Update complete!${NC}"
echo -e "${CYAN}===================================${NC}"
echo -e "\nBinaries location: $BIN_DIR"
echo -e "Next steps:"
echo -e "  1. Test the binaries: npm run dev"
echo -e "  2. Build the app: npm run dist:win"
echo -e "\nThe updated binaries will be bundled in your next build.\n"
