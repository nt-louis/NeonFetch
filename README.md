# NeonFetch

A modern desktop downloader built with Electron, React, and yt-dlp. Download videos from YouTube and other supported platforms with a beautiful, easy-to-use interface.

![Version](https://img.shields.io/badge/version-0.0.1-blue)
![License](https://img.shields.io/badge/license-MIT-green)

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
- **ffplay** - Media player capabilities
- **ffprobe** - Media file analysis
- **Electron Runtime** - Complete Chromium-based app environment
- **React UI** - All frontend assets and dependencies

**Total package size:** ~220 MB (portable)

## ✅ No Manual Setup Required

The portable version is **100% ready to run** with:

- ✅ All binaries included and pre-configured
- ✅ No Python installation needed
- ✅ No yt-dlp configuration needed
- ✅ No ffmpeg installation needed
- ✅ No PATH environment variable setup needed
- ✅ Works on any Windows PC without admin rights

Simply download and double-click `NeonFetch-0.0.1-portable.exe` to start!

## 🎯 Usage

### Running the Portable Version

1. Download `NeonFetch-0.0.1-portable.exe` from the `release` folder
2. Double-click the executable to launch
3. Paste any supported video URL
4. Click **Download** and watch the progress
5. Videos are saved to your default download location

The app will automatically:
- Detect and use the bundled yt-dlp
- Configure ffmpeg for video/audio processing
- Use your existing yt-dlp config file if present (optional)

### Supported Platforms

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

# Create portable Windows executable
npm run dist:win
```

The portable executable will be generated in the `release` folder.

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
- Download the latest ffmpeg, ffplay, and ffprobe
- Place them in `resources/bin/` for bundling
- Show current and new version numbers
- Automatically backup and restore on failure

After updating, rebuild the app:
```bash
npm run dist:win
```

### yt-dlp Config (Optional)

NeonFetch respects your existing yt-dlp configuration. Place a `yt-dlp.conf` file in:
- Windows: `%APPDATA%\yt-dlp\config.txt`
- Linux/Mac: `~/.config/yt-dlp/config`

Example config:
```
# Default output location
-o ~/Downloads/%(title)s.%(ext)s

# Preferred format
-f bestvideo+bestaudio

# Embed metadata
--embed-metadata
--embed-thumbnail
```

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

---

**Made with ❤️ using Electron + React + yt-dlp**
