# Moto Rally Aggregator

A cross-platform Flutter application that aggregates Australian motorcycle rally and event information from multiple sources.

![Flutter](https://img.shields.io/badge/Flutter-3.16+-blue.svg)
![Platforms](https://img.shields.io/badge/Platforms-Windows%20%7C%20Web%20%7C%20Android-green.svg)

## Download & Install

| Platform | Download | Instructions |
|----------|----------|--------------|
| **Web App** | [moto-rally-multiapp.pages.dev](https://moto-rally-multiapp.pages.dev) | Open in browser, works offline as PWA |
| **Android** | [`dist/android/moto-rally.apk`](dist/android/moto-rally.apk) | Enable "Install from unknown sources", install APK |
| **Windows** | [`dist/windows/moto-rally.exe`](dist/windows/) | Download and run (coming soon) |

## Features

- **Multi-Source Aggregation**: Fetches events from 19+ Australian motorcycle sources including:
  - Just Bikes Australia
  - Old Bike Australasia
  - Motorcycling Australia, QLD, NSW, VIC
  - BMW, Ducati, Harley-Davidson, Triumph clubs
  - Classic Owners SA, VMCC NSW, Indian MC
  - And more...

- **Automatic Updates**: Events are automatically scraped and updated weekly via GitHub Actions

- **Cross-Platform**: Single Flutter codebase builds for Windows, Web, and Android

- **Offline Watchlist**: Save events for viewing in areas with no reception

- **Responsive Design**:
  - Multi-column dashboard on desktop/tablet
  - Single-column scroll view on mobile
  - High-contrast themes for outdoor visibility
  - Large touch targets (44px minimum)

- **Filtering**: Filter events by:
  - Australian State (NSW, VIC, QLD, etc.)
  - Category (Swap Meet, Rally, Track Day, etc.)
  - Search text

## Project Structure

```
moto-rally-multiapp/
├── dist/                    # Ready-to-use apps
│   ├── android/
│   │   └── moto-rally.apk   # Android app
│   ├── web/                 # Web app files
│   └── windows/             # Windows app (coming soon)
│       └── moto-rally.exe
├── lib/                     # Flutter source code
├── assets/data/events.json  # Scraped event data
├── scripts/                 # Python scraper
└── .github/workflows/       # Auto-update automation
```

## Development

```bash
# Clone the repository
git clone https://github.com/scottleimroth/moto-rally-multiapp.git
cd moto-rally-multiapp

# Install dependencies
flutter pub get

# Run on your preferred platform
flutter run -d chrome    # Web
flutter run -d windows   # Windows
flutter run -d android   # Android
```

## Build

```bash
# Android APK
flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk dist/android/moto-rally.apk

# Web PWA
flutter build web --release
cp -r build/web/* dist/web/

# Windows EXE (requires Visual Studio)
flutter build windows --release
cp -r build/windows/x64/runner/Release/* dist/windows/
```

## License

© 2026 Woodquott ~242~ MDFFMD. All rights reserved.
