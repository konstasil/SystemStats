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

### Build from Source

```bash
git clone https://github.com/konstasiil/SystemStats.git
cd SystemStats
open SystemStats.xcodeproj
```

Press **Cmd+R** to build and run.

### Create DMG

```bash
chmod +x create_dmg.sh
./create_dmg.sh
```

Or build and create DMG in one command:

```bash
rm -rf build && xcodebuild -project SystemStats.xcodeproj -scheme SystemStats -configuration Release -derivedDataPath ./build && mkdir -p dmg_staging && cp -R $(find ./build -name "SystemStats.app" -type d | head -1) dmg_staging/ && ln -s /Applications dmg_staging/Applications && hdiutil create -volname "SystemStats" -srcfolder dmg_staging -ov -format UDZO SystemStats.dmg && rm -rf dmg_staging
```

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

---

# SystemStats

Минималистичный виджет для меню macOS, отображающий системную статистику в реальном времени с минимальным потреблением ресурсов. Мини-график отображается прямо в строке меню, аналогично системным мониторам в панели задач Windows.

![macOS](https://img.shields.io/badge/macOS-13%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.0-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Возможности

- **Мини-график в меню** - График загрузки CPU отображается прямо в строке меню с цветовой индикацией (зелёный/оранжевый/красный)
- **Загрузка CPU** - Нагрузка на процессор с историей в реальном времени
- **Использование памяти** - Потребление оперативной памяти, совпадающее с Activity Monitor
- **Температура GPU** - Мониторинг температуры видеокарты через IOKit
- **Режимы отображения** - Только график, только проценты или оба варианта
- **Управление мониторами** - Включение/отключение отдельных показателей
- **Автообновление** - Проверка новых версий на GitHub с уведомлениями
- **Локализация** - Поддержка русского и английского языков
- **Лёгкость** - Минимальное потребление CPU и памяти (<0.1% CPU)

## Требования

- macOS 13.0 или новее (Ventura+)
- Xcode 15.0 или новее (для сборки)

## Установка

### Скачивание

Скачайте последний `.dmg` файл из [GitHub Releases](https://github.com/konstasiil/SystemStats/releases).

1. Откройте скачанный `.dmg` файл
2. Перетащите `SystemStats.app` в папку `Applications`
3. Запустите приложение

**Примечание:** При первом запуске macOS может заблокировать приложение. Перейдите в **Системные настройки → Конфиденциальность и безопасность** и нажмите **Всё равно открыть**.

### Сборка из исходников

```bash
git clone https://github.com/konstasiil/SystemStats.git
cd SystemStats
open SystemStats.xcodeproj
```

Нажмите **Cmd+R** для сборки и запуска.

### Создание DMG

```bash
chmod +x create_dmg.sh
./create_dmg.sh
```

Или сборка и создание DMG одной командой:

```bash
rm -rf build && xcodebuild -project SystemStats.xcodeproj -scheme SystemStats -configuration Release -derivedDataPath ./build && mkdir -p dmg_staging && cp -R $(find ./build -name "SystemStats.app" -type d | head -1) dmg_staging/ && ln -s /Applications dmg_staging/Applications && hdiutil create -volname "SystemStats" -srcfolder dmg_staging -ov -format UDZO SystemStats.dmg && rm -rf dmg_staging
```

## Использование

1. После запуска SystemStats появляется в строке меню с мини-графиком CPU
2. График обновляется каждые 2 секунды, показывая историю загрузки
3. Нажмите на значок в меню для просмотра детальной статистики и настроек

### Отображение в меню

В строке меню отображается:
- Мини-график истории загрузки CPU (слева)
- Текущий процент CPU (справа)
- Цветовая индикация: зелёный (<50%), оранжевый (50-80%), красный (>80%)

### Режимы отображения

Нажмите на значок в меню и выберите режим:

- **График** - Только мини-график для каждого показателя
- **Проценты** - Только процентное значение
- **Оба** - График и проценты (по умолчанию)

### Конфигурация

В выпадающем окне можно:

- Включить/отключить отображение CPU, памяти и температуры GPU
- Переключать между режимами отображения
- Вручную проверить обновления

## Автообновление

SystemStats автоматически проверяет наличие новых версий на GitHub:
- Проверка через 3 секунды после запуска
- Повторная проверка каждые 60 минут
- Уведомление при появлении новой версии
- Нажмите "Скачать" для открытия страницы релиза

## Технические детали

SystemStats построен на чистом Swift без внешних зависимостей:

- **NSStatusItem** с кастомным NSView для отрисовки в меню
- **IOKit** для статистики оборудования и температуры GPU
- **Mach APIs** (task_threads, host_statistics64) для данных CPU и памяти
- **AppKit** для нативного внешнего вида macOS
- **UNUserNotificationCenter** для уведомлений об обновлениях
- Работает как фоновое приложение (без значка в Dock)

### Архитектура

- `SystemMonitor.swift` - Сбор данных CPU, памяти и GPU
- `StatusBarManager.swift` - Управление элементом меню с мини-графиком
- `PopoverView.swift` - UI popover со статистикой и настройками
- `MiniGraphView.swift` - Отрисовка графика через Canvas
- `UpdateChecker.swift` - Проверка новых релизов на GitHub

## Конфиденциальность

SystemStats только считывает системную статистику и не собирает и не передаёт никаких личных данных.
