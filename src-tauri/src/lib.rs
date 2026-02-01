use std::env;
use tauri::{AppHandle, Emitter};

#[derive(Clone, Debug)]
struct YtdlpCandidate {
    source: &'static str,
    path: String,
}

fn is_path_lookup(bin_path: &str) -> bool {
    !bin_path.contains('\\') && !bin_path.contains('/')
}

fn build_ytdlp_candidates(_app: &AppHandle) -> Result<Vec<YtdlpCandidate>, String> {
    let mut candidates: Vec<YtdlpCandidate> = Vec::new();

    candidates.push(YtdlpCandidate {
        source: "system",
        path: "yt-dlp".to_string(),
    });

    Ok(candidates)
}

async fn run_capture_first_line(
    app: &AppHandle,
    bin_path: &str,
    args: &[&str],
) -> Result<String, String> {
    let mut cmd = tauri_plugin_shell::ShellExt::shell(app).command(bin_path);

    // Ensure we inherit system PATH for system binary lookups.
    if is_path_lookup(bin_path) {
        if let Ok(path) = env::var("PATH") {
            cmd = cmd.env("PATH", path);
        }
    }

    let (mut rx, _child) = cmd
        .args(args)
        .spawn()
        .map_err(|e| format!("{}: {}", bin_path, e))?;

    let mut out = String::new();
    let mut last_err: Option<String> = None;
    let mut exit_code: Option<i32> = None;

    while let Some(event) = rx.recv().await {
        match event {
            tauri_plugin_shell::process::CommandEvent::Stdout(line) => {
                out.push_str(&String::from_utf8_lossy(&line));
            }
            tauri_plugin_shell::process::CommandEvent::Stderr(line) => {
                out.push_str(&String::from_utf8_lossy(&line));
            }
            tauri_plugin_shell::process::CommandEvent::Error(err) => {
                last_err = Some(err);
            }
            tauri_plugin_shell::process::CommandEvent::Terminated(payload) => {
                exit_code = payload.code;
                break;
            }
            _ => {}
        }
    }

    if let Some(err) = last_err {
        return Err(err);
    }

    if exit_code != Some(0) {
        return Err(format!(
            "{} exited with code {:?}. Output: {}",
            bin_path,
            exit_code,
            out.trim()
        ));
    }

    let first = out
        .lines()
        .map(|l| l.trim())
        .find(|l| !l.is_empty())
        .unwrap_or("");

    if first.is_empty() {
        return Err(format!("{} produced no output", bin_path));
    }

    Ok(first.to_string())
}

#[tauri::command]
async fn ytdlp_get_info(app: AppHandle) -> Result<serde_json::Value, String> {
    let candidates = build_ytdlp_candidates(&app)?;

    for candidate in candidates {
        match run_capture_first_line(&app, &candidate.path, &["--version"]).await {
            Ok(version) => {
                return Ok(serde_json::json!({
                    "found": true,
                    "version": version,
                    "source": candidate.source,
                    "path": candidate.path,
                }));
            }
            Err(e) => {
                // Keep this simple: surface a non-throwing "not found" state to the UI.
                return Ok(serde_json::json!({
                    "found": false,
                    "source": candidate.source,
                    "path": candidate.path,
                    "error": e,
                }));
            }
        }
    }

    Ok(serde_json::json!({
        "found": false,
        "source": "system",
        "path": "yt-dlp",
        "error": "No yt-dlp candidates available",
    }))
}

#[tauri::command]
async fn ytdlp_start(
    app: AppHandle,
    url: String,
) -> Result<bool, String> {
    let url = url.trim();
    if url.is_empty() {
        return Err("URL is empty".to_string());
    }

    let candidates = build_ytdlp_candidates(&app)?;

    // Spawn yt-dlp from system PATH.
    let mut last_err: Option<String> = None;
    let mut spawned: Option<_> = None;

    for candidate in candidates {
        let bin_path = &candidate.path;
        let mut cmd = tauri_plugin_shell::ShellExt::shell(&app).command(bin_path);

        // Ensure we inherit system PATH for system binary lookups.
        if is_path_lookup(bin_path) {
            if let Ok(path) = env::var("PATH") {
                cmd = cmd.env("PATH", path);
            }
        }

        match cmd.args([url]).spawn() {
            Ok((rx, child)) => {
                spawned = Some((rx, child));
                break;
            }
            Err(e) => {
                last_err = Some(format!("{} ({}): {}", bin_path, candidate.source, e));
            }
        }
    }

    let (mut rx, _child) = spawned.ok_or_else(|| {
        format!(
            "Failed to spawn yt-dlp with any candidate. Last error: {}",
            last_err.unwrap_or_else(|| "unknown error".to_string())
        )
    })?;

    // Stream output to frontend
    let app_clone = app.clone();
    tauri::async_runtime::spawn(async move {
        while let Some(event) = rx.recv().await {
            match event {
                tauri_plugin_shell::process::CommandEvent::Stdout(line) => {
                    let _ = app_clone.emit(
                        "ytdlp:event",
                        serde_json::json!({
                            "type": "log",
                            "data": String::from_utf8_lossy(&line)
                        }),
                    );
                }
                tauri_plugin_shell::process::CommandEvent::Stderr(line) => {
                    let _ = app_clone.emit(
                        "ytdlp:event",
                        serde_json::json!({
                            "type": "log",
                            "data": String::from_utf8_lossy(&line)
                        }),
                    );
                }
                tauri_plugin_shell::process::CommandEvent::Error(err) => {
                    let _ = app_clone.emit(
                        "ytdlp:event",
                        serde_json::json!({
                            "type": "error",
                            "data": err
                        }),
                    );
                }
                tauri_plugin_shell::process::CommandEvent::Terminated(payload) => {
                    if payload.code == Some(0) {
                        let _ = app_clone.emit(
                            "ytdlp:event",
                            serde_json::json!({
                                "type": "done",
                                "data": "✅ Finished."
                            }),
                        );
                    } else {
                        let _ = app_clone.emit(
                            "ytdlp:event",
                            serde_json::json!({
                                "type": "error",
                                "data": format!("❌ yt-dlp exited with code {:?}", payload.code)
                            }),
                        );
                    }
                    break;
                }
                _ => {}
            }
        }
    });

    Ok(true)
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .setup(|app| {
            if cfg!(debug_assertions) {
                app.handle().plugin(
                    tauri_plugin_log::Builder::default()
                        .level(log::LevelFilter::Info)
                        .build(),
                )?;
            }
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![ytdlp_get_info, ytdlp_start])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
