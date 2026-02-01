import { useEffect, useMemo, useRef, useState } from "react";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import "./App.css";

type YtdlpEvent = { type: "log" | "error" | "done"; data: string };

export default function App() {
  // User input + download state
  const [url, setUrl] = useState("");
  const [running, setRunning] = useState(false);
  const [log, setLog] = useState<string>("");

  const logRef = useRef<HTMLTextAreaElement | null>(null);

  useEffect(() => {
    // Subscribe to log/progress events from the main process.
    const unlisten = listen<YtdlpEvent>("ytdlp:event", (event) => {
      const evt = event.payload;
      setLog((prev) => prev + evt.data);
      if (evt.type === "done" || evt.type === "error") {
        setRunning(false);
      }
    });
    return () => {
      unlisten.then((fn) => fn());
    };
  }, []);

  useEffect(() => {
    // Auto-scroll log output to the latest line.
    if (logRef.current) {
      logRef.current.scrollTop = logRef.current.scrollHeight;
    }
  }, [log]);

  const canDownload = useMemo(() => url.trim().length > 0 && !running, [url, running]);

  // Trigger yt-dlp run for the provided URL.
  const startDownload = async () => {
    const u = url.trim();
    if (!u) return;
    setLog("");
    setRunning(true);

    try {
      await invoke("ytdlp_start", { url: u, ytdlpPath: undefined });
    } catch (e: unknown) {
      const message = e instanceof Error ? e.message : String(e);
      setLog((prev) => prev + `\n${message}\n`);
      setRunning(false);
    }
  };

  return (
    <div className="app-shell">
      <header className="app-header">
        <div className="brand">
          <img src="./logo.svg" alt="NeonFetch logo" className="brand-logo" />
          <p className="app-kicker">Desktop downloader</p>
          <h1>NeonFetch</h1>
        </div>
        <span className={running ? "status-pill is-live" : "status-pill"}>
          {running ? "Running" : "Idle"}
        </span>
      </header>

      <section className="panel">
        <div className="panel-title">
          <h2>Queue a link</h2>
          <p>Paste a video URL and stream progress below.</p>
        </div>

        <div className="input-row">
          <input
            className="url-input"
            placeholder="Paste a video URL…"
            value={url}
            onChange={(e) => setUrl(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter" && canDownload) startDownload();
            }}
            disabled={running}
          />
          <button className="primary-btn" onClick={startDownload} disabled={!canDownload}>
            {running ? "Downloading…" : "Download"}
          </button>
        </div>
      </section>

      <section className="panel log-panel">
        <div className="panel-title">
          <h2>Live output</h2>
          <p>yt-dlp uses your existing config automatically.</p>
        </div>

        <div className="log-wrap">
          <textarea
            ref={logRef}
            value={log}
            readOnly
            className="log-output"
            placeholder="Logs will appear here…"
          />
        </div>
      </section>
    </div>
  );
}
