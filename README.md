# Moto Rally Australia

Australian motorcycle event browser for the Pi internal apps dashboard.

## Internal App

The live internal site is served by Caddy at:

```text
https://moto-rally.internal
```

The web app is plain static HTML, CSS, and JavaScript in `dist/web`. It does not require Flutter to run or rebuild the internal website.

## Features

- Current and future events only
- Search by event, source, location, or description
- Filter by state
- Filter by category
- Filter by source
- Open original source links in a new tab

## Event Data

Events are scraped by:

```text
scripts/scrape_events.py
```

The scraper writes:

```text
assets/data/events.json
```

The deployed static site reads:

```text
dist/web/assets/assets/data/events.json
```

After updating events, copy the generated JSON into the deployed static asset path:

```bash
python3 scripts/scrape_events.py
cp assets/data/events.json dist/web/assets/assets/data/events.json
```

## Serve Locally

```bash
python3 -m http.server 8080 --directory dist/web
```

Then open:

```text
http://localhost:8080
```

## Legacy Flutter Files

This project previously used Flutter for web/Android/Windows builds. The Pi-hosted internal website has been converted to static HTML/JS because it is only an event browser.
