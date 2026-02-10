# Moto Rally Australia

**Free Australian Motorcycle Events Aggregator**

Find upcoming motorcycle rallies, swap meets, track days, and club events across Australia - all in one place.

![Platforms](https://img.shields.io/badge/Platforms-Windows%20%7C%20Web%20%7C%20Android-orange.svg)
![License](https://img.shields.io/badge/License-Free-green.svg)
![Events](https://img.shields.io/badge/Events-Auto--Updated%20Weekly-blue.svg)

## Available Platforms

| Platform | How to Get It |
|----------|---------------|
| Web App | [Launch in browser](https://moto-rally-multiapp.pages.dev) — works offline! |
| Android | [Download APK](https://github.com/scottleimroth/moto-rally-multiapp/releases/latest/download/moto-rally.apk) — enable "Unknown sources" to install |
| Windows | [Download EXE](https://github.com/scottleimroth/moto-rally-multiapp/releases/latest) — run directly, no install needed |

**100% Free** - No ads, no tracking, no sign-up required.

## Features

- **60+ Events** from 19 Australian motorcycle sources
- **Auto-Updates Weekly** - Events scraped every Sunday via GitHub Actions
- **Works Offline** - Save events to your watchlist for areas with no reception
- **Filter by State** - NSW, VIC, QLD, SA, WA, TAS, NT, ACT
- **Filter by Type** - Rallies, Swap Meets, Track Days, Club Rides, Shows
- **Search** - Find events by name, location, or description

## Event Sources

Events are automatically scraped from:
- Just Bikes Australia
- Old Bike Australasia
- Motorcycling Australia (National, QLD, NSW, VIC)
- BMW Motorcycle Club
- Ducati Owners Club
- Harley-Davidson Clubs
- Triumph Owners
- Classic Owners SA
- VMCC NSW
- Indian Motorcycle Club
- And more...

## Screenshots

The app features a clean, easy-to-read interface designed for motorcyclists:
- Dark theme for outdoor visibility
- Large touch targets for gloved hands
- Event details with maps and sharing

## Technical Details

Built with Flutter for true cross-platform support from a single codebase:
- **Web**: Progressive Web App (PWA) with offline caching
- **Android**: Native APK
- **Windows**: Native desktop application

Events are scraped using Python and automatically committed to the repo weekly.

## For Developers

```bash
# Clone and run locally
git clone https://github.com/scottleimroth/moto-rally-multiapp.git
cd moto-rally-multiapp
flutter pub get
flutter run -d chrome    # Web
flutter run -d windows   # Windows
flutter run -d android   # Android
```

### Build Commands

```bash
# Android APK
flutter build apk --release

# Web PWA
flutter build web --release

# Windows EXE
flutter build windows --release
```

## Contributing

Found a bug or want to add an event source? Pull requests welcome!

## License

© 2026 Woodsqott ~242~ MDFFMD. All rights reserved.

Free for personal use. Not for resale.
