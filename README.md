# Moto Rally Aggregator

A cross-platform Flutter application that aggregates Australian motorcycle rally and event information from multiple sources.

![Flutter](https://img.shields.io/badge/Flutter-3.16+-blue.svg)
![Platforms](https://img.shields.io/badge/Platforms-Windows%20%7C%20Web%20%7C%20Android%20%7C%20iOS-green.svg)
![License](https://img.shields.io/badge/License-Private-red.svg)

## Features

- **Multi-Source Aggregation**: Fetches events from:
  - Just Bikes Australia
  - Old Bike Magazine
  - Motorcycling Australia

- **Cross-Platform Support**:
  - Windows desktop application
  - Progressive Web App (PWA)
  - Android mobile app
  - iOS mobile app

- **Offline Watchlist**: Save events for viewing in areas with no reception using Hive (SQLite/IndexedDB)

- **Responsive Design**:
  - Multi-column dashboard on desktop/tablet
  - Single-column scroll view on mobile
  - High-contrast themes for outdoor visibility
  - Large touch targets (44px minimum)

- **Filtering**: Filter events by:
  - Australian State (NSW, VIC, QLD, etc.)
  - Category (Swap Meet, Rally, Track Day, etc.)
  - Search text

## Architecture

The project follows Feature-First Clean Architecture:

```
lib/
├── core/           # Shared utilities, theme, constants
└── features/
    ├── events/     # Event listing and scraping
    └── watchlist/  # Offline event storage
```

Each feature contains:
- `data/` - Data sources, repositories implementation
- `domain/` - Entities, repository interfaces, use cases
- `presentation/` - UI (pages, widgets, BLoC state management)

## Quick Start

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/moto-rally-multiapp.git
cd moto-rally-multiapp

# Install dependencies
flutter pub get

# Run on your preferred platform
flutter run -d chrome    # Web
flutter run -d windows   # Windows
flutter run -d android   # Android
flutter run -d ios       # iOS
```

## Build

See [BUILD_GUIDE.md](BUILD_GUIDE.md) for detailed build and deployment instructions.

### Quick Build Commands

```bash
# Windows executable
flutter build windows --release

# PWA (offline-first)
flutter build web --release --pwa-strategy offline-first

# Android APK
flutter build apk --release

# iOS (requires macOS)
flutter build ios --release
```

## Deployment

The project includes GitHub Actions for automatic deployment to GitHub Pages on push to `main`.

## Tech Stack

- **Framework**: Flutter 3.16+
- **State Management**: flutter_bloc
- **Local Storage**: Hive (cross-platform)
- **Dependency Injection**: get_it
- **HTTP**: http package
- **HTML Parsing**: html package

## Contributing

This is a private repository. Contact the maintainer for contribution guidelines.

## License

All rights reserved. This is a private repository.
