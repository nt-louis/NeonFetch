/// <reference types="vite/client" />

declare global {
  interface Window {
    ytdlp: {
      start: (url: string, ytdlpPath?: string) => Promise<{ ok: true }>;
      onEvent: (cb: (evt: { type: "log" | "error" | "done"; data: string }) => void) => () => void;
    };
  }
}

export {};