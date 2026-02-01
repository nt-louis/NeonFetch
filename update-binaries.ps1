#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Updates yt-dlp and ffmpeg binaries in the resources/bin folder
.DESCRIPTION
    Downloads the latest versions of yt-dlp and ffmpeg from official sources
    and places them in resources/bin/ for bundling with the application.
#>

$ErrorActionPreference = "Stop"

# Configuration
$BinDir = "$PSScriptRoot/resources/bin"
$TempDir = "$PSScriptRoot/temp-downloads"

# Colors for output
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

Write-Info "==================================="
Write-Info "  Binary Update Script"
Write-Info "==================================="
Write-Host ""

# Create directories if they don't exist
if (-not (Test-Path $BinDir)) {
    New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
    Write-Info "Created directory: $BinDir"
}

if (-not (Test-Path $TempDir)) {
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
}

# Clean temp directory
Write-Info "Cleaning temporary directory..."
Remove-Item -Path "$TempDir/*" -Recurse -Force -ErrorAction SilentlyContinue

# ===========================
# Update yt-dlp
# ===========================
Write-Info "`n[1/2] Updating yt-dlp..."
try {
    $ytdlpUrl = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
    $ytdlpPath = "$BinDir/yt-dlp.exe"
    
    # Get current version
    $currentVersion = "Not installed"
    if (Test-Path $ytdlpPath) {
        $currentVersion = & $ytdlpPath --version 2>$null
    }
    Write-Info "  Current version: $currentVersion"
    
    # Get latest version from GitHub API
    Write-Info "  Checking for latest version..."
    $apiUrl = "https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest"
    $release = Invoke-WebRequest -Uri $apiUrl -UseBasicParsing | ConvertFrom-Json
    $latestVersion = $release.tag_name -replace '^v', ''  # Remove 'v' prefix if present
    
    Write-Info "  Latest version available: $latestVersion"
    
    # Compare versions
    if ($currentVersion -eq $latestVersion) {
        Write-Success "  ✓ yt-dlp is already up to date"
    } else {
        Write-Info "  New version available! Downloading..."
        
        # Backup old version
        if (Test-Path $ytdlpPath) {
            Copy-Item $ytdlpPath "$ytdlpPath.bak" -Force
        }
        
        Invoke-WebRequest -Uri $ytdlpUrl -OutFile $ytdlpPath -UseBasicParsing
        
        # Verify download
        if (Test-Path $ytdlpPath) {
            $newVersion = & $ytdlpPath --version
            Write-Success "  ✓ yt-dlp updated from $currentVersion to $newVersion"
            Remove-Item "$ytdlpPath.bak" -ErrorAction SilentlyContinue
        } else {
            throw "Failed to download yt-dlp"
        }
    }
} catch {
    Write-Error "  ✗ Failed to update yt-dlp: $_"
    
    # Restore backup if it exists
    if (Test-Path "$ytdlpPath.bak") {
        Move-Item "$ytdlpPath.bak" $ytdlpPath -Force
        Write-Warning "  Restored previous version"
    }
}

# ===========================
# Update FFmpeg
# ===========================
Write-Info "`n[2/2] Updating ffmpeg suite..."
try {
    $ffmpegZip = "$TempDir/ffmpeg.zip"
    $ffmpegExtract = "$TempDir/ffmpeg-extracted"
    $ffmpegExe = "$BinDir/ffmpeg.exe"
    
    # Get current version
    $currentVersion = "Not installed"
    if (Test-Path $ffmpegExe) {
        $versionOutput = & $ffmpegExe -version 2>$null | Select-Object -First 1
        if ($versionOutput -match "ffmpeg version (\S+)") {
            $currentVersion = $matches[1]
        }
    }
    Write-Info "  Current ffmpeg version: $currentVersion"
    
    # Check latest version from gyan.dev API
    Write-Info "  Checking for latest version..."
    $gyanApi = "https://www.gyan.dev/ffmpeg/builds/git-full.json"
    
    try {
        $latestInfo = Invoke-WebRequest -Uri $gyanApi -UseBasicParsing | ConvertFrom-Json
        $latestVersion = $latestInfo.version
        Write-Info "  Latest version available: $latestVersion"
        
        # Compare versions (simple string comparison for now)
        if ($currentVersion -eq $latestVersion) {
            Write-Success "  ✓ ffmpeg suite is already up to date"
            return
        }
    } catch {
        Write-Warning "  ⚠ Could not check for latest version, proceeding with download..."
    }
    
    # Use gyan.dev builds (regularly updated, trusted source)
    $ffmpegUrl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
    
    Write-Info "  New version available! Downloading from: gyan.dev"
    Write-Info "  This may take a minute (file is ~80MB)..."
    Invoke-WebRequest -Uri $ffmpegUrl -OutFile $ffmpegZip -UseBasicParsing
    
    Write-Info "  Extracting archive..."
    Expand-Archive -Path $ffmpegZip -DestinationPath $ffmpegExtract -Force
    
    # Find the bin directory (it's nested in a versioned folder)
    $ffmpegBinPath = Get-ChildItem -Path $ffmpegExtract -Recurse -Directory -Filter "bin" | Select-Object -First 1
    
    if ($ffmpegBinPath) {
        # Copy executables
        $executables = @("ffmpeg.exe", "ffplay.exe", "ffprobe.exe")
        
        foreach ($exe in $executables) {
            $sourcePath = Join-Path $ffmpegBinPath.FullName $exe
            $destPath = Join-Path $BinDir $exe
            
            if (Test-Path $sourcePath) {
                # Backup old version
                if (Test-Path $destPath) {
                    Copy-Item $destPath "$destPath.bak" -Force
                }
                
                Copy-Item $sourcePath $destPath -Force
                
                # Get new version
                if ($exe -eq "ffmpeg.exe") {
                    $newVersion = & $destPath -version 2>$null | Select-Object -First 1
                    if ($newVersion -match "ffmpeg version (\S+)") {
                        Write-Success "  ✓ $exe updated to version: $($matches[1])"
                    } else {
                        Write-Success "  ✓ $exe updated successfully"
                    }
                } else {
                    Write-Success "  ✓ $exe updated successfully"
                }
                
                # Remove backup
                Remove-Item "$destPath.bak" -ErrorAction SilentlyContinue
            } else {
                Write-Warning "  ⚠ $exe not found in archive"
            }
        }
    } else {
        throw "Could not find bin directory in ffmpeg archive"
    }
} catch {
    Write-Error "  ✗ Failed to update ffmpeg: $_"
    
    # Restore backups
    $executables = @("ffmpeg.exe", "ffplay.exe", "ffprobe.exe")
    foreach ($exe in $executables) {
        $backupPath = "$BinDir/$exe.bak"
        if (Test-Path $backupPath) {
            Move-Item $backupPath "$BinDir/$exe" -Force
        }
    }
    Write-Warning "  Restored previous versions"
}

# Clean up
Write-Info "`nCleaning up temporary files..."
Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue

# Summary
Write-Info "`n==================================="
Write-Success "Update complete!"
Write-Info "==================================="
Write-Info "`nBinaries location: $BinDir"
Write-Info "Next steps:"
Write-Info "  1. Test the binaries: npm run dev"
Write-Info "  2. Build the app: npm run dist:win"
Write-Info "`nThe updated binaries will be bundled in your next build.`n"
