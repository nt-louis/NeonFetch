use std::env;
use tauri::{AppHandle, Emitter, Manager};

#[tauri::command]
async fn ytdlp_start(
    app: AppHandle,
    url: String,
    ytdlp_path: Option<String>,
) -> Result<bool, String> {
    let url = url.trim();
    if url.is_empty() {
        return Err("URL is empty".to_string());
    }

    // Determine yt-dlp binary path
    let bin_path = if let Some(custom_path) = ytdlp_path {
        custom_path
    } else {
        // Try to use bundled binary first, fall back to system yt-dlp
        let resource_dir = app
            .path()
            .resource_dir()
            .map_err(|e| format!("Failed to get resource dir: {}", e))?;

        let bin_name = if cfg!(target_os = "windows") {
            "yt-dlp.exe"
        } else {
            "yt-dlp"
        };

        let bundled_path = resource_dir.join("bin").join(bin_name);

        if bundled_path.exists() {
            bundled_path.to_string_lossy().to_string()
        } else {
            "yt-dlp".to_string()
        }
    };

    // Spawn yt-dlp process with proper environment
    let mut cmd = tauri_plugin_shell::ShellExt::shell(&app)
        .command(&bin_path);
    
    // Ensure we inherit system PATH for system binary lookups
    if !bin_path.contains("\\") && !bin_path.contains("/") {
        // It's a simple command name, ensure PATH is available
        if let Ok(path) = env::var("PATH") {
            cmd = cmd.env("PATH", path);
        }
    }
    
    let (mut rx, _child) = cmd
        .args([url])
        .spawn()
        .map_err(|e| format!("Failed to spawn yt-dlp: {}", e))?;

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
        .invoke_handler(tauri::generate_handler![ytdlp_start])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

