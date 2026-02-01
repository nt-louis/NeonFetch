import { app, BrowserWindow, ipcMain, nativeImage } from "electron";
import path from "path";
import { spawn } from "child_process";
import fs from "fs";

// Keep a global reference to avoid GC closing the window.
let mainWindow: BrowserWindow | null = null;

// Resolve the bundled binary path for dev vs packaged app.
function getBundledBinPath(name: string) {
  const ext = process.platform === "win32" ? ".exe" : "";
  const base = app.isPackaged
    ? path.join(process.resourcesPath, "bin")
    : path.join(__dirname, "..", "resources", "bin");
  return {
    base,
    full: path.join(base, `${name}${ext}`),
  };
}

// Create the main application window.
function createWindow() {
  mainWindow = new BrowserWindow({
    width: 900,
    height: 650,
    icon: nativeImage.createFromPath(path.join(__dirname, "../public/logo.svg")),
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });

  // Vite dev server (dev) vs built files (prod)
  if (!app.isPackaged) {
    mainWindow.loadURL("http://localhost:5173");
    mainWindow.webContents.openDevTools({ mode: "detach" });
  } else {
    mainWindow.loadFile(path.join(__dirname, "../dist/index.html"));
  }
}

// App lifecycle
app.whenReady().then(createWindow);

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") app.quit();
});

// Start a download using yt-dlp (bundled or system).
ipcMain.handle("ytdlp:start", async (_evt, args: { url: string; ytdlpPath?: string }) => {
  const url = args.url.trim();
  if (!url) throw new Error("URL is empty.");

  const bundled = getBundledBinPath("yt-dlp");
  const bin =
    args.ytdlpPath?.trim() ||
    (fs.existsSync(bundled.full) ? bundled.full : "yt-dlp");

  return new Promise<{ ok: true }>((resolve, reject) => {
    // Important: do NOT pass flags so your config file is used automatically.
    const child = spawn(bin, [url], {
      windowsHide: true,
      shell: false, // safer than shell strings
      env: {
        ...process.env,
        PATH: fs.existsSync(bundled.base)
          ? `${bundled.base}${path.delimiter}${process.env.PATH ?? ""}`
          : process.env.PATH,
      },
    });

    // Forward progress/output to renderer.
    const send = (type: "log" | "error" | "done", data: string) => {
      mainWindow?.webContents.send("ytdlp:event", { type, data });
    };

    child.stdout.on("data", (buf) => send("log", buf.toString()));
    child.stderr.on("data", (buf) => send("log", buf.toString())); // yt-dlp progress is often stderr

    child.on("error", (err) => {
      send("error", String(err));
      reject(err);
    });

    child.on("close", (code) => {
      if (code === 0) {
        send("done", "✅ Finished.");
        resolve({ ok: true });
      } else {
        send("error", `❌ yt-dlp exited with code ${code}`);
        reject(new Error(`yt-dlp exited with code ${code}`));
      }
    });
  });
});
