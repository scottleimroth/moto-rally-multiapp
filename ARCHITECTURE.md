# Moto Rally Australia - Architecture

**Last updated:** 2026-06-21

## Overview

Moto Rally Australia is now a web-first static application. The production site no longer uses the Flutter web runtime. The Python scraper remains the data pipeline and writes the generated event catalogue to `assets/data/events.json`.

## Current Production Flow

```text
Public event websites
        |
        v
scripts/scrape_events.py
        |
        v
assets/data/events.json
        |
        v
React/Vite build
        |
        v
dist/web
        |
        v
Cloudflare Pages or static host
```

## Why This Changed

The previous public web app used Flutter web plus bundled JSON, GitHub raw JSON, Hive browser cache, and a service worker. That created too many places for stale event data to survive. The new production path uses a single generated JSON contract and a lightweight static frontend.

## Frontend

- Framework: React
- Language: TypeScript
- Build tool: Vite
- Output: `dist/web`
- Runtime data: build-time import of `assets/data/events.json`
- Browser storage: local watchlist and trip plans only
- Service worker: none in production

## Scraper

- Script: `scripts/scrape_events.py`
- Output: `assets/data/events.json`
- Purpose: collect, clean, date-filter, and classify Australian motorcycle events
- CI workflow: `.github/workflows/update-events.yml`

## Deployment

Use:

```bash
npm run build
```

Deploy:

```text
dist/web
```

Cloudflare Pages should use normal static hosting behavior. Do not add aggressive cache rules for `index.html`.

## Retired From Production

Flutter source and native build artifacts may still exist in the repository history or working tree, but Flutter is no longer the public web production runtime. The production deployment should point at the Vite output in `dist/web`.

## Validation Performed

- `npm test`
- `npm run build`
- `npm audit --audit-level=low`
- Browser verification at desktop, half-width, and mobile widths
- Trip planner interaction verification
