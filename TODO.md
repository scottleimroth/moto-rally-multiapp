# Moto Rally Australia - Development Log & TODO

## Last Session

- **Date:** 2026-06-21
- **Summary:** Replaced the production Flutter web app with a React/Vite static frontend while keeping the Python scraper.
- **Key changes:**
  - Added React, TypeScript, and Vite production web app.
  - Kept `scripts/scrape_events.py` and `assets/data/events.json` as the data pipeline.
  - Built event discovery, state/category filters, search, local watchlist, and trip planner.
  - Removed Flutter web runtime, CanvasKit, service worker, and GitHub raw JSON fetch from `dist/web`.
- **Stopped at:** React/Vite build verified locally.
- **Blockers:** None.

---

## Current Status

### Working Features

- Upcoming Australian motorcycle events from the generated scraper JSON.
- Search by event, place, state, or source.
- Filter by Australian state.
- Filter by event type.
- Browser-local watchlist.
- Trip planner with ride days, fuel stops, comfort breaks, route notes, service notes, accommodation notes, and checklist.
- Static production output in `dist/web`.

### In Progress

- None currently.

### Known Bugs

- None currently tracked.

---

## TODO - Priority

1. [ ] Verify all scraper sources still provide useful public event data.
2. [ ] Add more high-quality Australian motorcycle event sources.
3. [ ] Add scraper validation rules for suspicious titles and date mismatches.
4. [ ] Confirm Cloudflare Pages build command is `npm run build` and output directory is `dist/web`.

---

## TODO - Nice To Have

- [ ] Map view of events.
- [ ] Calendar export.
- [ ] Route fuel-stop lookup.
- [ ] Weather by route segment.
- [ ] Rider-friendly accommodation notes.
- [ ] Service and tyre shop notes.

---

## Completed

- [x] Python event scraper with generated JSON output.
- [x] GitHub Actions weekly scraper workflow.
- [x] React/Vite production web frontend.
- [x] Watchlist and trip-planner browser storage.
- [x] Production Flutter web runtime retired.

---

## Notes

- Events are scraped from public motorcycle club and event websites.
- The public web app imports `assets/data/events.json` at build time.
- The production site should not fetch GitHub raw JSON at runtime.
- The production site should not register an app-level service worker.
