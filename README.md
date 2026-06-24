# SystemStats

A minimalist macOS menu bar widget that displays real-time system statistics with minimal resource usage. Features a mini graph directly in the menu bar, similar to Windows taskbar system monitors.

![macOS](https://img.shields.io/badge/macOS-13%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.0-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **Mini Graph in Menu Bar** - Real-time CPU graph displayed directly in the menu bar with color-coded status (green/orange/red)
- **CPU Usage** - Processor load percentage with live history graph
- **Memory Usage** - RAM consumption matching Activity Monitor calculations
- **GPU Temperature** - Graphics card temperature monitoring via IOKit
- **Display Modes** - Choose between graph only, percentage only, or both
- **Toggle Monitors** - Enable/disable individual stat displays
- **Auto-Update** - Checks for new versions on GitHub and notifies you
- **Localization** - English and Russian language support
- **Lightweight** - Minimal CPU and memory footprint (<0.1% CPU)

## Requirements

- macOS 13.0 or later (Ventura+)
- Xcode 15.0 or later (only for building)

## Installation

### Download

Download the latest `.dmg` file from [GitHub Releases](https://github.com/konstasiil/SystemStats/releases).

1. Open the downloaded `SystemStats.dmg` file
2. Drag `SystemStats.app` to your `Applications` folder
3. Launch the app

**Note:** On first launch, macOS may block the app. Go to **System Settings → Privacy & Security** and click **Open Anyway**.

## Usage

1. After launching, SystemStats appears in the menu bar with a mini CPU graph
2. The graph updates every 2 seconds showing CPU usage history
3. Click the menu bar item to see detailed statistics and settings

### Menu Bar Display

The menu bar shows:
- A mini graph of CPU usage history (left side)
- Current CPU percentage (right side)
- Color coding: green (<50%), orange (50-80%), red (>80%)

### Display Modes

Click the menu bar icon and choose a display mode:

- **Graph** - Show only the mini graph for each stat
- **Percent** - Show only the percentage value
- **Both** - Show graph and percentage (default)

### Configuration

In the popover, you can:

- Toggle CPU, Memory, and GPU temperature displays
- Switch between display modes
- Check for updates manually

## Auto-Update

SystemStats automatically checks for new versions on GitHub:
- Checks 3 seconds after launch
- Checks every 60 minutes
- Shows a notification when a new version is available
- Click "Download" to open the release page

## Technical Details

SystemStats is built using pure Swift with no external dependencies:

- **NSStatusItem** with custom NSView for menu bar rendering
- **IOKit** for hardware statistics and GPU temperature
- **Mach APIs** (task_threads, host_statistics64) for CPU and memory data
- **AppKit** for native macOS look and feel
- **UNUserNotificationCenter** for update notifications
- Runs as a background accessory app (no Dock icon)

### Architecture

- `SystemMonitor.swift` - Collects CPU, memory, and GPU data
- `StatusBarManager.swift` - Manages menu bar item with mini graph
- `PopoverView.swift` - Popover UI with stats and settings
- `MiniGraphView.swift` - Canvas-based graph renderer
- `UpdateChecker.swift` - Checks GitHub for new releases

## Privacy

SystemStats only reads system statistics and does not collect or transmit any personal data.

## Donate

https://konstasiil.vercel.app/

TON: UQAUUmV4gogvx6sR4Fa06M31L8PKOd7u7T0QEg22Jy6cYUV-

USDT BEP-20:0x5E68839F576dc8229b11b88b24D6D616f849346E

LTC: ltc1qgu3nxwfkkx35r77y8zwh57nt77cm9qjpxndm52

USDT TRC20: TXwQAni5TFHNpk41DthigGftXZVcsS2sxv
