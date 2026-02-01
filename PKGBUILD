# Maintainer: NeonFetch Contributors
pkgname=neonfetch
pkgver=0.0.3
pkgrel=1
pkgdesc="A modern desktop downloader built with Tauri, React, and yt-dlp"
arch=('x86_64')
url="https://github.com/zepro2004/yt-dlp-gui"
license=('MIT')
depends=('webkit2gtk' 'yt-dlp' 'ffmpeg')
makedepends=('npm' 'cargo' 'rust' 'libvips' 'imagemagick' 'patchelf')
source=()
md5sums=()

build() {
    cd "$startdir"
    npm install
    npm run build
    # Build with Tauri which properly embeds frontend assets
    # Will fail at AppImage bundling on Arch, but binary is built correctly before that
    npm exec tauri build -- --bundles deb,rpm || true
}

package() {
    cd "$startdir"
    
    # Install binary from Tauri's build output
    install -Dm755 "src-tauri/target/release/neonfetch" "$pkgdir/usr/bin/neonfetch"
    
    # Install desktop file
    install -Dm644 /dev/stdin "$pkgdir/usr/share/applications/neonfetch.desktop" <<EOF
[Desktop Entry]
Name=NeonFetch
Comment=Modern desktop downloader with yt-dlp
Exec=neonfetch
Icon=neonfetch
Type=Application
Categories=Network;AudioVideo;
Terminal=false
EOF
    
    # Install icon
    install -Dm644 "src-tauri/icons/128x128.png" "$pkgdir/usr/share/pixmaps/neonfetch.png"
    install -Dm644 "src-tauri/icons/icon.png" "$pkgdir/usr/share/icons/hicolor/256x256/apps/neonfetch.png"
}
