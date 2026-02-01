import { contextBridge, ipcRenderer } from "electron";

// Payload for progress/log events from the main process.
type YtdlpEvent = { type: "log" | "error" | "done"; data: string };

// Expose a minimal, safe API to the renderer.
contextBridge.exposeInMainWorld("ytdlp", {
  start: (url: string, ytdlpPath?: string) => ipcRenderer.invoke("ytdlp:start", { url, ytdlpPath }),
  onEvent: (cb: (evt: YtdlpEvent) => void) => {
    // Subscribe to streaming output from yt-dlp.
    const handler = (_: unknown, payload: YtdlpEvent) => cb(payload);
    ipcRenderer.on("ytdlp:event", handler);
    return () => ipcRenderer.removeListener("ytdlp:event", handler);
  },
});