# Moto Rally Australia - System Architecture

## Overview

A cross-platform motorcycle events aggregator that scrapes 19 Australian event sources weekly via GitHub Actions, stores events as JSON, and serves them through a Flutter app available as PWA, Android APK, and Windows EXE.

---

## Architecture Diagram

```
┌────────────────────┐
│   GitHub Actions    │ (Weekly cron - Sunday)
│   Python Scraper    │
└────────┬───────────┘
         │ Scrapes 19 sources
         ▼
┌────────────────────┐
│   events.json      │ (Committed to repo)
└────────┬───────────┘
         │
    ┌────┴────┬──────────────┐
    ▼         ▼              ▼
┌────────┐ ┌────────┐ ┌──────────┐
│  Web   │ │Android │ │ Windows  │
│  PWA   │ │  APK   │ │   EXE   │
│(CF Pgs)│ │(Release│ │(Release) │
└────────┘ └────────┘ └──────────┘
```

---

## Technology Stack

### Flutter App (all platforms)
- **Framework:** Flutter/Dart
- **Platforms:** Web (PWA), Android (APK), Windows (EXE)
- **UI:** Dark theme, large touch targets for outdoor/gloved use

### Event Scraper
- **Language:** Python
- **Automation:** GitHub Actions (weekly cron)
- **Sources:** 19 Australian motorcycle clubs and event aggregators
- **Output:** JSON file committed to repo

### Deployment
- **Web:** Cloudflare Pages (auto-deploy from main)
- **Android/Windows:** GitHub Releases for binary distribution

---

## Component Structure

```
moto-rally-multiapp/
├── lib/                   # Flutter app source
│   ├── main.dart
│   ├── models/            # Event data models
│   ├── screens/           # UI screens
│   └── services/          # Data loading, filtering
├── scraper/               # Python event scraper
│   ├── scrape_events.py
│   └── sources/           # Per-source scrapers
├── assets/
│   └── events.json        # Scraped event data
├── .github/
│   └── workflows/         # GitHub Actions for scraping
├── android/               # Android build config
├── windows/               # Windows build config
├── web/                   # Web build config
└── README.md
```

---

## Key Workflows

### Weekly Event Scrape
1. GitHub Actions triggers on Sunday
2. Python scraper hits all 19 event sources
3. Events parsed, deduplicated, and merged into events.json
4. Changes committed and pushed automatically
5. Cloudflare Pages auto-deploys updated web app

### User Event Discovery
1. App loads events.json (bundled or fetched)
2. User filters by state, type, or search query
3. Event details shown with date, location, description
4. User can add events to watchlist (stored locally)

---

## Security Considerations

- **No API keys required:** All scraping targets are public websites
- **No user data collected:** No accounts, no tracking
- **Offline-first:** PWA caches events for offline access
- **HTTPS:** All platforms use HTTPS

---

**Last Updated:** 2026-02-10
