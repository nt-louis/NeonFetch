# NeonFetch

A modern desktop downloader built with Tauri, React, and yt-dlp. Download videos from YouTube and 1000+ other platforms with a beautiful, easy-to-use interface.

![Version](https://img.shields.io/badge/version-0.0.3-blue)
![License](https://img.shields.io/badge/license-MIT-green)

> **Prerequisites:** Install `yt-dlp` and `ffmpeg` system-wide (in `PATH`). NeonFetch does not bundle them.

## Quick Start

### Installation

Download from [GitHub Releases](https://github.com/zepro2004/yt-dlp-gui/releases/latest) for Windows, Linux, or macOS.

**Before launching:**
```bash
# Install yt-dlp
pip install yt-dlp

# Install ffmpeg
# Arch Linux: sudo pacman -S ffmpeg
# Debian/Ubuntu: sudo apt install ffmpeg
# Fedora: sudo dnf install ffmpeg
# Windows: choco install ffmpeg
# macOS: brew install ffmpeg
```

### Usage

1. Launch NeonFetch
2. Paste a video URL
3. Click **Download** and watch progress

## 🚀 Features

- **Modern UI** – Clean, responsive React interface
- **Lightweight** – 10-15 MB install built with Tauri and Rust
- **Real-time Progress** – Live streaming of download status
- **Multi-platform** – Windows, Linux, macOS support
- **Secure** – Rust backend with memory safety
- **System Integration** – Uses system `yt-dlp` and `ffmpeg`

## Development

### Setup

```bash
# Install Node.js 18+, Rust 1.77.2+, and build tools
# See: https://github.com/tauri-apps/tauri/wiki/Dev-Environment-Setup

git clone <repo>
cd yt-dlp-gui
npm install
```

### Commands

```bash
npm run dev         # Dev server with hot reload
npm run build       # Build frontend
npm run dist:win    # Build Windows MSI
npm run dist:linux  # Build all Linux packages (Arch, Debian, RPM)
npm run dist:mac    # Build macOS DMG
npm run lint        # Lint code
```

### Linux Build Notes

Build all Linux packages at once:
```bash
npm run dist:linux          # Creates .pkg.tar.zst (Arch), .deb (Debian), and .rpm (Fedora)
```

Install the appropriate package for your distribution:

**Arch Linux:**
```bash
sudo pacman -U neonfetch-0.0.3-1-x86_64.pkg.tar.zst
```

**Debian/Ubuntu:**
```bash
sudo dpkg -i src-tauri/target/release/bundle/deb/neonfetch_*.deb
```

**Fedora/RHEL:**
```bash
sudo rpm -i src-tauri/target/release/bundle/rpm/neonfetch-*.rpm
```

### Project Structure

```
yt-dlp-gui/
├── src/                 # React frontend
├── src-tauri/           # Rust backend + Tauri config
├── public/              # Static assets
└── dist/                # Built output
```

## Configuration

### yt-dlp Config (Optional)

Place your yt-dlp config in the standard location:
- **Windows:** `%APPDATA%\yt-dlp\config.txt`
- **Linux/Mac:** `~/.config/yt-dlp/config`

Sample configs are in `ytdlp-config/` directory.

## Troubleshooting

**"yt-dlp not found"**
- Verify: `yt-dlp --version` in terminal
- Restart NeonFetch after installing

**Windows: Build fails with MSVC error**
- Install [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/) with C++ workload

**Linux: Installation**
```bash
# Arch Linux
sudo pacman -U neonfetch-0.0.3-1-x86_64.pkg.tar.zst

# Debian/Ubuntu
sudo dpkg -i neonfetch_0.0.3_amd64.deb

# Fedora/RHEL
sudo rpm -i neonfetch-0.0.3-1.x86_64.rpm
```

## License

MIT

## Acknowledgments

- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- [FFmpeg](https://ffmpeg.org/)
- [Tauri](https://tauri.app/)
- [React](https://react.dev/)

