# Moto Rally Aggregator - Build Guide

A cross-platform Flutter application for aggregating Australian motorcycle rally events.

## Prerequisites

### Required Software
- **Flutter SDK**: Version 3.16.0 or later
- **Dart SDK**: Version 3.2.0 or later (included with Flutter)
- **Git**: For version control

### Platform-Specific Requirements

#### Windows
- Visual Studio 2022 with "Desktop development with C++" workload
- Windows 10 SDK (10.0.17763.0 or later)

#### Web
- Chrome browser (for development/testing)
- Any modern web browser for deployment

#### Android
- Android Studio with Android SDK
- Android SDK Command-line Tools
- Android SDK Build-Tools

#### iOS/macOS (requires macOS)
- Xcode 15.0 or later
- CocoaPods
- Valid Apple Developer account for device deployment

## Project Setup

### 1. Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME/moto-rally-multiapp.git
cd moto-rally-multiapp
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Verify Flutter Setup
```bash
flutter doctor
```
Ensure all required components show a checkmark (✓).

---

## Build Commands

### Windows Executable (.exe)

Build a release Windows executable:

```bash
flutter build windows --release
```

**Output location**: `build/windows/x64/runner/Release/`

The executable and all required DLLs will be in this folder. Distribute the entire folder contents.

#### Creating an Installer (Optional)
For creating an MSIX installer:
```bash
flutter pub run msix:create
```

### Progressive Web App (PWA)

Build the PWA with offline-first caching strategy:

```bash
flutter build web --release --pwa-strategy offline-first --web-renderer canvaskit
```

**Output location**: `build/web/`

#### PWA Build Options:
- `--pwa-strategy offline-first`: Caches all assets for offline use
- `--web-renderer canvaskit`: Better rendering quality (larger download)
- `--web-renderer html`: Smaller download, faster initial load

### Android APK

Build a release APK:

```bash
flutter build apk --release
```

**Output location**: `build/app/outputs/flutter-apk/app-release.apk`

Build an App Bundle for Play Store:
```bash
flutter build appbundle --release
```

**Output location**: `build/app/outputs/bundle/release/app-release.aab`

### iOS (requires macOS)

Build for iOS:
```bash
flutter build ios --release
```

**Output location**: `build/ios/iphoneos/Runner.app`

For App Store submission, use Xcode to archive and upload.

---

## Deployment

### GitHub Pages (Automatic)

The project includes a GitHub Actions workflow that automatically deploys to GitHub Pages on every push to `main`.

1. Enable GitHub Pages in your repository settings:
   - Go to **Settings** → **Pages**
   - Source: **GitHub Actions**

2. Push to `main` branch:
```bash
git add .
git commit -m "Deploy to GitHub Pages"
git push origin main
```

3. The site will be available at:
   `https://YOUR_USERNAME.github.io/moto-rally-multiapp/`

### Manual Web Deployment

#### GitHub Pages (Manual)
```bash
# Build the web app
flutter build web --release --pwa-strategy offline-first --base-href "/moto-rally-multiapp/"

# Deploy using gh-pages or copy to gh-pages branch
```

#### Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize and deploy
firebase init hosting
firebase deploy --only hosting
```

#### Netlify
1. Build: `flutter build web --release --pwa-strategy offline-first`
2. Drag `build/web/` folder to Netlify dashboard
3. Or connect your GitHub repo for automatic deployments

#### Vercel
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
cd build/web
vercel
```

---

## Development

### Running in Debug Mode

```bash
# Web
flutter run -d chrome

# Windows
flutter run -d windows

# Android (with device connected)
flutter run -d android

# iOS (on macOS with simulator)
flutter run -d ios
```

### Hot Reload
Press `r` in the terminal while the app is running to hot reload.

### Generating Code (if using code generators)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/
│   ├── constants/           # App constants, enums
│   ├── di/                  # Dependency injection
│   ├── services/            # Core services (scraper)
│   ├── theme/               # App theming
│   ├── utils/               # Utility functions
│   └── widgets/             # Shared widgets
└── features/
    ├── events/
    │   ├── data/            # Data layer
    │   │   ├── datasources/ # Local & remote data sources
    │   │   ├── models/      # Data models
    │   │   └── repositories/
    │   ├── domain/          # Business logic
    │   │   ├── entities/    # Domain entities
    │   │   ├── repositories/
    │   │   └── usecases/
    │   └── presentation/    # UI layer
    │       ├── bloc/        # State management
    │       ├── pages/       # Screen pages
    │       └── widgets/     # Feature widgets
    └── watchlist/           # Watchlist feature (same structure)
```

---

## Data Sources

The app aggregates events from:
1. **Just Bikes Australia**: https://www.justbikes.com.au/events/upcoming
2. **Old Bike Magazine**: https://www.oldbikemag.com.au/category/buzz-box/calendar/
3. **Motorcycling Australia**: https://motorcycling.com.au/riders/calendar/

### Scraper Resilience
The scraper is designed to handle website structure changes gracefully:
- Multiple CSS selectors are tried for each element type
- Fallback sample data is provided when scraping fails
- Last updated timestamps are tracked for all data
- Errors are logged but don't crash the app

---

## Offline Support

### Watchlist Feature
- Events saved to watchlist are stored locally using Hive
- Hive uses SQLite on Windows/Mobile and IndexedDB on Web
- Watchlist data persists between sessions
- No internet required to view saved events

### PWA Caching
- All app assets are cached with service worker
- App works offline after initial load
- New content syncs when online

---

## Troubleshooting

### Common Issues

**Flutter SDK not found**
```bash
# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"
```

**Windows build fails**
- Ensure Visual Studio is installed with C++ workload
- Run `flutter doctor -v` to check specific issues

**Web build shows blank page**
- Check browser console for errors
- Ensure base-href matches your deployment path
- Try `--web-renderer html` for older browsers

**Hive initialization fails**
- Clear app data/cache
- Check write permissions for storage directory

### Getting Help
- Flutter documentation: https://docs.flutter.dev
- Project issues: https://github.com/YOUR_USERNAME/moto-rally-multiapp/issues

---

## License

This project is private. All rights reserved.

---

## Version History

- **1.0.0**: Initial release
  - Cross-platform support (Windows, Web, Android, iOS)
  - Event aggregation from 3 Australian sources
  - Offline watchlist feature
  - Responsive UI with filtering
  - PWA support for web
