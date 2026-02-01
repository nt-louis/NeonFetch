import { useEffect, useMemo, useRef, useState } from "react";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import "./App.css";

type YtdlpEvent = { type: "log" | "error" | "done"; data: string };

type YtdlpInfo = {
  found: boolean;
  version?: string;
  source: "system" | string;
  path: string;
  error?: string;
};

export default function App() {
  // User input + download state
  const [url, setUrl] = useState("");
  const [running, setRunning] = useState(false);
  const [log, setLog] = useState<string>("");

  const [ytdlpInfo, setYtdlpInfo] = useState<YtdlpInfo | null>(null);
  const [ytdlpInfoLoading, setYtdlpInfoLoading] = useState(false);
  const [ytdlpInfoError, setYtdlpInfoError] = useState<string | null>(null);
  const [hasSearched, setHasSearched] = useState(false);

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

  const refreshYtdlpInfo = async () => {
    setYtdlpInfoLoading(true);
    setYtdlpInfoError(null);
    setHasSearched(true);
    try {
      const info = await invoke<YtdlpInfo>("ytdlp_get_info");
      setYtdlpInfo(info);
    } catch (e: unknown) {
      const message = e instanceof Error ? e.message : String(e);
      setYtdlpInfo(null);
      setYtdlpInfoError(message);
    } finally {
      setYtdlpInfoLoading(false);
    }
  };

  useEffect(() => {
    refreshYtdlpInfo();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const canDownload = useMemo(
    () => url.trim().length > 0 && !running && ytdlpInfo?.found,
    [url, running, ytdlpInfo?.found]
  );

  // Trigger yt-dlp run for the provided URL.
  const startDownload = async () => {
    const u = url.trim();
    if (!u) return;
    setLog("");
    setRunning(true);

    try {
      await invoke("ytdlp_start", { url: u });
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
        <div className="header-right">
          <span className={running ? "status-pill is-live" : "status-pill"}>
            {running ? "Running" : "Idle"}
          </span>
          <div className="meta-pill" aria-live="polite">
            <span className="meta-label">yt-dlp</span>
            <span className="meta-value">
              {ytdlpInfoLoading
                ? "Checking…"
                : ytdlpInfo
                  ? ytdlpInfo.found
                    ? `${ytdlpInfo.version} (${ytdlpInfo.source})`
                    : "⚠️ Not found"
                  : "Unavailable"}
            </span>
            <button
              type="button"
              className="meta-action"
              onClick={refreshYtdlpInfo}
              disabled={ytdlpInfoLoading}
              title={
                ytdlpInfo?.found
                  ? `yt-dlp found at: ${ytdlpInfo.path}`
                  : ytdlpInfo?.error
                    ? `yt-dlp not found. Error: ${ytdlpInfo.error}\n\nTips:\n• First time? Try restarting the app after installing yt-dlp\n• Verify yt-dlp is in your system PATH\n• You can check by opening a terminal and typing: yt-dlp --version`
                    : ytdlpInfoError ?? "Refresh"
              }
            >
              Refresh
            </button>
          </div>
        </div>
      </header>

      <section className="panel">
        <div className="panel-title">
          <h2>Queue a link</h2>
          <p>Paste a video URL and stream progress below.</p>
        </div>

        {hasSearched && !ytdlpInfo?.found && (
          <div
            style={{
              padding: "12px 16px",
              marginBottom: "12px",
              backgroundColor: "#1e293b",
              borderLeft: "4px solid #ef4444",
              borderRadius: "4px",
              fontSize: "14px",
              lineHeight: "1.5",
              color: "#f1f5f9",
            }}
          >
            <strong>⚠️ yt-dlp not found</strong>
            <p style={{ margin: "8px 0 0 0" }}>
              Please install yt-dlp first. You can install it via:
            </p>
            <ul style={{ margin: "6px 0 0 20px", paddingLeft: 0 }}>
              <li>
                <code style={{ backgroundColor: "#334155", color: "#fbbf24", padding: "2px 6px", borderRadius: "2px" }}>
                  pip install yt-dlp
                </code>
              </li>
              <li>Or download from: https://github.com/yt-dlp/yt-dlp/releases</li>
            </ul>
            <p style={{ margin: "8px 0 0 0" }}>
              After installing, restart this app and click Refresh above.
            </p>
          </div>
        )}

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
          <button
            className="primary-btn"
            onClick={startDownload}
            disabled={!canDownload}
            title={
              !ytdlpInfo?.found
                ? "yt-dlp is not found. Install it, restart the app, and try again."
                : ""
            }
          >
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
