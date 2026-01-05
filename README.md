# quick

Minimal QuickShell config for Hyprland.

## Features

- **Bar** - Top bar with workspaces, system stats, volume, network, bluetooth, battery
- **Launcher** - App launcher with system commands (reboot, shutdown, etc.)
- **Clipboard** - Clipboard history manager (requires `cliphist`)
- **Tools** - Screenshot, OCR, color picker, YouTube downloader

## Dependencies

```
quickshell
cliphist
wl-copy
grim
slurp
hyprpicker
tesseract
yt-dlp
```

## Install

```bash
git clone https://github.com/0xdilo/quick ~/Git/quick
quickshell -p ~/Git/quick
```

## Keybinds

Add to your `hyprland.conf`:

```
bind = $mod, D, exec, quickshell msg -p ~/Git/quick shell toggleLauncherIpc
bind = $mod, V, exec, quickshell msg -p ~/Git/quick shell toggleClipboardIpc
bind = $mod, X, exec, quickshell msg -p ~/Git/quick shell toggleToolsIpc
```

## Theme

Edit `Theme.qml` to change colors. Works with [iro](https://github.com/0xdilo/iro) for automatic wallpaper-based theming.
