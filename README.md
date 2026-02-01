# NeonFetch

A modern desktop downloader built with Electron, React, and yt-dlp. Download videos from YouTube and other supported platforms with a beautiful, easy-to-use interface.

![Version](https://img.shields.io/badge/version-0.0.1-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## 📚 Table of Contents

- [📥 Installation](#-installation)
- [🚀 Features](#-features)
- [📦 What's Bundled](#-whats-bundled)
- [✅ No Manual Setup Required](#-no-manual-setup-required)
- [🌐 Supported Platforms](#-supported-platforms)
- [🛠️ Development](#-development)
- [🔧 Configuration](#-configuration)
- [🔒 Security](#-security)
- [📝 Scripts](#-scripts)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)
- [🙏 Acknowledgments](#-acknowledgments)
- [📞 Support](#-support)

## 📥 Installation

### Platform-Specific Setup

#### Windows
1. Download `NeonFetch-0.0.1-portable.exe` from the `release` folder
2. Double-click the executable to launch
3. **No additional setup required** - all dependencies are bundled

#### Linux (AppImage)
1. Download `NeonFetch-0.0.1.AppImage` from the `release` folder
2. Make it executable: `chmod +x NeonFetch-0.0.1.AppImage`
3. **Install required system libraries:**
   ```bash
   # Arch Linux
   sudo pacman -S at-spi2-core gtk3 fuse2
   
   # Ubuntu/Debian
   sudo apt install libatk1.0-0 libgtk-3-0 libfuse2
   
   # Fedora
   sudo dnf install at-spi2-core gtk3 fuse
   ```
4. Run: `./NeonFetch-0.0.1.AppImage`

#### macOS
1. Download `NeonFetch-0.0.1.dmg` from the `release` folder
2. Open the DMG and drag to Applications
3. **No additional setup required** - all dependencies are bundled

### Running the App

1. Launch NeonFetch using the method above for your platform
2. Paste any supported video URL
3. Click **Download** and watch the progress
4. Videos are saved to your default download location

The app will automatically:
- Detect and use the bundled yt-dlp
- Configure ffmpeg for video/audio processing
- Use your existing yt-dlp config file if present (optional)

## 🚀 Features

- **Modern UI** - Clean, responsive interface built with React 19
- **Fully Portable** - No installation required, runs standalone
- **All Dependencies Bundled** - Includes yt-dlp, ffmpeg, and all necessary tools
- **Real-time Progress** - Live download progress and status updates
- **Zero Configuration** - Works out of the box, no manual setup needed

## 📦 What's Bundled

The portable executable includes everything you need:

- **yt-dlp** - The powerful video downloader
- **ffmpeg** - Video/audio processing and conversion
- **ffprobe** - Media file analysis
- **Electron Runtime** - Complete Chromium-based app environment
- **React UI** - All frontend assets and dependencies

**Package sizes:**
- Windows: ~220 MB (portable executable)
- Linux: ~300 MB (AppImage)
- macOS: ~250 MB (DMG)

## ✅ No Manual Setup Required

**Windows:** 100% ready to run with:
- ✅ All binaries included and pre-configured
- ✅ No Python installation needed
- ✅ No yt-dlp configuration needed
- ✅ No ffmpeg installation needed
- ✅ No PATH environment variable setup needed
- ✅ Works on any Windows PC without admin rights

**Linux:** Requires system libraries only (see setup instructions above)

**macOS:** 100% ready to run (all dependencies bundled)

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

- Node.js 18+ 
- npm 9+

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd yt-dlp-gui

# Install dependencies
npm install
```

### Development Mode

```bash
# Run the app in development mode with hot reload
npm run dev
```

This starts:
- Vite dev server on `http://localhost:5173`
- Electron app with DevTools open
- Hot module replacement for instant updates

### Building

```bash
# Build for production
npm run build

# Create platform-specific builds
npm run dist:win     # Windows portable executable
npm run dist:linux   # Linux AppImage
npm run dist:mac     # macOS DMG
npm run dist:all     # All platforms
```

The built executables will be generated in the `release` folder.

**Important:** Before building for Linux/macOS, update the binaries:
```bash
./update-binaries.sh
```

This ensures platform-specific binaries (yt-dlp, ffmpeg, ffprobe) are included.

### Project Structure

```
yt-dlp-gui/
├── src/                    # React frontend source
│   ├── App.tsx            # Main app component
│   ├── App.css            # Styles
│   └── main.tsx           # React entry point
├── electron/              # Electron main process
│   ├── main.ts            # Main process & IPC handlers
│   └── preload.ts         # Preload script for context bridge
├── resources/bin/         # Bundled binaries (yt-dlp, ffmpeg, etc.)
├── public/                # Static assets (logo, etc.)
├── dist/                  # Vite build output
├── electron-dist/         # Compiled Electron code
└── release/               # Built executables
```

## 🔧 Configuration

### Updating Bundled Binaries

To update yt-dlp and ffmpeg to their latest versions:

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
- Place them in `resources/bin/` for bundling
- Show current and new version numbers
- Automatically backup and restore on failure

**Note:** The `resources/bin/` folder contains both Windows (`.exe`) and Linux/macOS binaries. The correct ones are automatically selected during the build process.

After updating, rebuild the app for your target platform:
```bash
npm run dist:win     # For Windows
npm run dist:linux   # For Linux
npm run dist:mac     # For macOS
```

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

- **Context Isolation** - Enabled for security
- **Node Integration** - Disabled in renderer
- **Content Security Policy** - Enforced
- **Process Separation** - Main and renderer processes isolated
- **No Shell Execution** - Commands run directly, not through shell

## 📝 Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server with hot reload |
| `npm run build` | Build production assets (Vite + TypeScript) |
| `npm run dist:win` | Build portable Windows executable |
| `npm run dist:linux` | Build Linux AppImage |
| `npm run dist:mac` | Build macOS DMG |
| `npm run dist:all` | Build for all platforms |
| `npm run electron:prod` | Run production build locally |
| `npm run lint` | Run ESLint on codebase |

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
- [Electron](https://www.electronjs.org/) - Cross-platform desktop apps
- [React](https://react.dev/) - UI library
- [Vite](https://vitejs.dev/) - Next generation frontend tooling

## 📞 Support

For issues, questions, or contributions, please open an issue on GitHub.
