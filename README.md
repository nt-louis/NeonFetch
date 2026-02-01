# NeonFetch

A modern desktop downloader built with Tauri, React, and yt-dlp. Download videos from YouTube and other supported platforms with a beautiful, easy-to-use interface.

![Version](https://img.shields.io/badge/version-0.0.1-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## 📚 Table of Contents

- [📥 Installation](#-installation)
- [🚀 Features](#-features)
- [📦 What's Included](#-whats-included)
- [✅ Minimal Setup Required](#-minimal-setup-required)
- [🌐 Supported Platforms](#-supported-platforms)
- [🛠️ Development](#-development)
- [🔧 Configuration](#-configuration)
- [🔒 Security](#-security)
- [📝 Scripts](#-scripts)
- [🔧 Troubleshooting](#-troubleshooting)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)
- [🙏 Acknowledgments](#-acknowledgments)
- [📞 Support](#-support)

## 📥 Installation

### Platform-Specific Setup

#### Windows
1. Download the Windows build from [GitHub Releases](https://github.com/zepro2004/yt-dlp-gui/releases/latest)
2. Double-click the executable to launch
3. If running from source/building locally, download binaries: `./update-binaries.ps1`

#### Linux (AppImage)
1. Download the AppImage from [GitHub Releases](https://github.com/zepro2004/yt-dlp-gui/releases/latest)
2. Make it executable: `chmod +x NeonFetch-0.0.1.AppImage`
3. If running from source/building locally, download binaries: `./update-binaries.sh`
4. **Install required system libraries:**
   ```bash
   # Arch Linux
   sudo pacman -S at-spi2-core gtk3 fuse2
   
   # Ubuntu/Debian
   sudo apt install libatk1.0-0 libgtk-3-0 libfuse2
   
   # Fedora
   sudo dnf install at-spi2-core gtk3 fuse
   ```
5. Run: `./NeonFetch-0.0.1.AppImage`

#### macOS
1. Download the macOS build from [GitHub Releases](https://github.com/zepro2004/yt-dlp-gui/releases/latest)
2. Open the DMG and drag to Applications
3. If running from source/building locally, download binaries: `./update-binaries.sh`

### Running the App

1. Launch NeonFetch using the method above for your platform
2. Paste any supported video URL
3. Click **Download** and watch the progress
4. Videos are saved to your default download location

The app will automatically:
- Detect and use the downloaded yt-dlp
- Configure ffmpeg for video/audio processing
- Use your existing yt-dlp config file if present (optional)

## 🚀 Features

- **Modern UI** - Clean, responsive interface built with React 19
- **Lightning Fast** - Tauri's Rust backend provides instant startup and low memory usage
- **Tiny Footprint** - ~10-15 MB installers (vs 200-300 MB with Electron)
- **Fully Portable** - Installers available for Windows, Linux, and macOS
- **Easy Binary Setup** - Download yt-dlp/ffmpeg with one script per platform
- **Real-time Progress** - Live download progress and status updates streamed from Rust backend
- **Secure by Design** - Rust's memory safety + Tauri's security model
- **Native Performance** - Uses system WebView instead of bundled Chromium

## 📦 What's Included

The app includes everything except the media tools, which are downloaded via scripts:

- **yt-dlp** - Downloaded via `update-binaries.*`
- **ffmpeg** - Downloaded via `update-binaries.*`
- **ffprobe** - Downloaded via `update-binaries.*`
- **Tauri Runtime** - Lightweight Rust-based app runtime
- **React UI** - All frontend assets and dependencies

**Package sizes:**
- Windows: ~10-15 MB (installer/portable)
- Linux: ~15-20 MB (AppImage)
- macOS: ~10-15 MB (DMG)

## ✅ Minimal Setup Required

Run the binary download script once. After that, the app works normally.

## 🌐 Supported Platforms

Thanks to yt-dlp, NeonFetch supports downloads from:
- YouTube (videos, playlists, live streams)
- Vimeo
- Twitch
- Twitter/X
- TikTok
- Reddit
- And [1000+ other sites](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md)

## 🛠️ Development

### Prerequisites

#### Required for All Platforms:
- Node.js 18+ 
- npm 9+
- **Rust 1.77.2+** (Install from [rustup.rs](https://rustup.rs/))
  ```bash
  # Install Rust
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  
  # Verify installation
  rustc --version
  cargo --version
  ```

#### Platform-Specific System Dependencies:

**Windows:**
- Microsoft C++ Build Tools (from Visual Studio Installer)
- WebView2 (usually pre-installed on Windows 10/11)

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install libwebkit2gtk-4.1-dev \
  build-essential \
  curl \
  wget \
  file \
  libxdo-dev \
  libssl-dev \
  libayatana-appindicator3-dev \
  librsvg2-dev
```

**Linux (Arch):**
```bash
sudo pacman -Syu
sudo pacman -S webkit2gtk-4.1 base-devel curl wget file openssl appmenu-gtk-module gtk3 libappindicator-gtk3 librsvg libvips
```

**Linux (Fedora):**
```bash
sudo dnf check-update
sudo dnf install webkit2gtk4.1-devel openssl-devel curl wget file libappindicator-gtk3-devel librsvg2-devel
sudo dnf group install "C Development Tools and Libraries"
```

**macOS:**
- Xcode Command Line Tools:
  ```bash
  xcode-select --install
  ```

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd yt-dlp-gui

# Install Node.js dependencies
npm install

# First build will compile Rust dependencies (may take a few minutes)
# This happens automatically when you run npm run dev or npm run build
```

**Note:** The first time you run the app, Rust will compile all dependencies. This can take 2-5 minutes but subsequent builds will be much faster due to caching.

### Development Mode

```bash
# Run the app in development mode with hot reload
npm run dev
```

This starts:
- Vite dev server on `http://localhost:5173`
- Tauri app with DevTools available
- Hot module replacement for instant updates

**Important:** Before building production installers, download/update binaries:

**Windows:**
```powershell
.\update-binaries.ps1
```

**Linux/macOS:**
```bash
chmod +x update-binaries.sh
./update-binaries.sh
```

This downloads yt-dlp, ffmpeg, and ffprobe to `resources/bin/`. These binaries are bundled into your app as configured in `tauri.conf.json` under `bundle.resources`.

**Note:** For development (`npm run dev`), the app will attempt to use system-installed binaries if the `resources/bin/` folder is empty.

### Building

```bash
# Build frontend only (creates dist/ folder)
npm run build

# Build complete Tauri app with installers
npm run dist:win     # Windows: MSI installer
npm run dist:linux   # Linux: AppImage
npm run dist:mac     # macOS: DMG
npm run dist:all     # Builds all available bundles for current platform
```

**Build Process:**
1. `npm run build` - Vite compiles React app to `dist/`
2. Tauri builds Rust backend and bundles everything together
3. MSI installer is created in `src-tauri/target/release/bundle/msi/`

**Build Output Locations:**
- Windows (MSI): `src-tauri/target/release/bundle/msi/`
- Linux (AppImage): `src-tauri/target/release/bundle/appimage/`
- macOS (DMG): `src-tauri/target/release/bundle/dmg/`

**Build Times:**
- First build: 5-10 minutes (compiles all Rust dependencies)
- Subsequent builds: 1-2 minutes (only recompiles changed code)
- Frontend-only rebuilds: ~5 seconds

### Project Structure

```
yt-dlp-gui/
├── src/                    # React frontend source
│   ├── App.tsx            # Main app component
│   ├── App.css            # Styles
│   └── main.tsx           # React entry point
├── src-tauri/             # Tauri Rust backend
│   ├── src/
│   │   ├── main.rs        # Rust entry point
│   │   └── lib.rs         # Tauri commands & IPC handlers
│   ├── Cargo.toml         # Rust dependencies
│   └── tauri.conf.json    # Tauri configuration
├── resources/bin/         # Downloaded binaries (yt-dlp, ffmpeg, etc.)
├── public/                # Static assets (logo, etc.)
├── dist/                  # Vite build output
└── release/               # Built executables
```

## 🔧 Configuration

### Downloading/Updating Binaries

You must download the binaries once before first run. To update later:

**Windows:**
```powershell
.\update-binaries.ps1
```

**Linux/macOS:**
```bash
chmod +x update-binaries.sh
./update-binaries.sh
```

The script will:
- Download the latest yt-dlp from GitHub releases
- Download the latest ffmpeg and ffprobe static builds
- Place them in `resources/bin/` for bundling via Tauri
- Show current and new version numbers
- Automatically backup and restore on failure

**Note:** The `resources/bin/` folder contains both Windows (`.exe`) and Linux/macOS binaries. Tauri's build process automatically includes only platform-specific binaries in each installer.

After updating, rebuild the app for your target platform:
```bash
npm run dist:win     # For Windows
npm run dist:linux   # For Linux
npm run dist:mac     # For macOS
```

### Tauri Configuration

The app's Tauri settings are in [`src-tauri/tauri.conf.json`](src-tauri/tauri.conf.json):
- **Window settings** - Size (900x650), title, resizability
- **Bundle resources** - Includes `resources/bin/*` for yt-dlp, ffmpeg, ffprobe
- **Build targets** - MSI/NSIS for Windows, AppImage for Linux, DMG for macOS
- **App identifier** - `com.neonfetch.app`

Rust dependencies are managed in [`src-tauri/Cargo.toml`](src-tauri/Cargo.toml):
- `tauri` - Core framework (v2.9.5)
- `tauri-plugin-shell` - For spawning yt-dlp process
- `tauri-plugin-log` - Development logging

### yt-dlp Config (Optional)

NeonFetch respects your existing yt-dlp configuration. Place a config file in:
- Windows: `%APPDATA%\yt-dlp\config.txt`
- Linux/Mac: `~/.config/yt-dlp/config`

Sample configs are included in the repository:
- [ytdlp-config/config.txt](ytdlp-config/config.txt) (Windows)
- [ytdlp-config/config-linux.txt](ytdlp-config/config-linux.txt) (Linux)

Copy the one you want to the correct location above and rename it to `config` (Linux/Mac) or `config.txt` (Windows).

If no config exists, NeonFetch uses sensible defaults.

## 🔒 Security

- **Rust Backend** - Memory-safe, secure backend with no JavaScript vulnerabilities
- **IPC Isolation** - Frontend and backend communicate only through explicit commands
- **Content Security Policy** - Enforced by default
- **No Node.js Access** - Frontend has no direct system access
- **Command Allowlisting** - Only approved Tauri commands can be invoked

## 📝 Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start Tauri development server with hot reload |
| `npm run build` | Build production assets (Vite + TypeScript) |
| `npm run dist:win` | Build Windows MSI installer |
| `npm run dist:linux` | Build Linux AppImage |
| `npm run dist:mac` | Build macOS DMG |
| `npm run dist:all` | Build for all platforms |
| `npm run tauri` | Run Tauri CLI commands |
| `npm run lint` | Run ESLint on codebase |

## 🔧 Troubleshooting

### Build Issues

**"Rust compiler not found"**
```bash
# Install Rust from https://rustup.rs/
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env  # Or restart your terminal
```

**Linux: "Package webkit2gtk-4.1 not found"**
```bash
# Ubuntu/Debian
sudo apt install libwebkit2gtk-4.1-dev

# Arch
sudo pacman -S webkit2gtk-4.1

# Fedora
sudo dnf install webkit2gtk4.1-devel
```

**Windows: "MSVC not found" or linking errors**
- Install [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022)
- Select "Desktop development with C++" workload

**First build is very slow**
- This is normal! Rust compiles all dependencies from source
- First build: 5-10 minutes
- Subsequent builds: 1-2 minutes (thanks to caching)

### Runtime Issues

**"yt-dlp not found"**
- Run `./update-binaries.ps1` (Windows) or `./update-binaries.sh` (Linux/macOS)
- Rebuild the app: `npm run dist:win` (or appropriate platform)

**macOS: "App is damaged and can't be opened"**
```bash
# Remove quarantine attribute
xattr -cr /Applications/NeonFetch.app
```

**Linux: AppImage won't run**
```bash
# Make executable
chmod +x NeonFetch-*.AppImage

# Install FUSE if needed
sudo apt install libfuse2  # Ubuntu/Debian
sudo pacman -S fuse2       # Arch
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - The powerful video downloader
- [FFmpeg](https://ffmpeg.org/) - Multimedia framework
- [Tauri](https://tauri.app/) - Lightweight, secure desktop apps with Rust
- [React](https://react.dev/) - UI library
- [Vite](https://vitejs.dev/) - Next generation frontend tooling

## 📞 Support

For issues, questions, or contributions, please open an issue on GitHub.
