# Moto Rally Australia

Free Australian motorcycle event discovery and trip planning.

Moto Rally Australia is a public web app for finding upcoming Australian motorcycle rallies, swap meets, shows, and touring events. It uses a Python scraper to generate a reviewed JSON data file, then serves a lightweight React/Vite frontend from `dist/web`.

## Current Production Architecture

- **Frontend:** React, TypeScript, Vite
- **Production output:** `dist/web`
- **Data source:** `assets/data/events.json`
- **Scraper:** `scripts/scrape_events.py`
- **Hosting target:** Cloudflare Pages or another static host
- **Production Flutter status:** retired from the public web deployment path

## Features

- Upcoming Australian motorcycle events only
- Search by event, place, state, or source
- Filter by state and event type
- Local watchlist in browser storage
- Trip planner for ride days, fuel stops, comfort breaks, route notes, service notes, accommodation notes, and packing checklist
- No runtime GitHub raw-data fetch
- No app-level service worker cache layer

## Data Pipeline

The scraper writes:

```text
assets/data/events.json
```

The web app imports that JSON at build time. This keeps the public site simple and avoids stale runtime data from competing sources.

Run the scraper:

```bash
python scripts/scrape_events.py
```

## Web Development

```bash
npm install
npm run dev
npm test
npm run build
npm run preview
```

## Deployment

Build command:

```bash
npm run build
```

Deploy directory:

```text
dist/web
```

## Copyright

Copyright 2026 Scott Leimroth. All rights reserved.
