# Moto Rally Australia - Development Log & TODO

## Last Session

- **Date:** 2026-02-10
- **Summary:** Added standard repo files
- **Key changes:**
  - Created CREDENTIALS.md, SECURITY_AUDIT.md, TODO.md, ARCHITECTURE.md
  - Updated .gitignore and README
- **Stopped at:** Repo standardisation complete
- **Blockers:** None

---

## Current Status

### Working Features
- 60+ events from 19 Australian motorcycle sources
- Auto-update weekly via GitHub Actions scraper
- Web PWA with offline support (Cloudflare Pages)
- Android APK
- Windows EXE
- Filter by state (NSW, VIC, QLD, SA, WA, TAS, NT, ACT)
- Filter by type (Rallies, Swap Meets, Track Days, Club Rides, Shows)
- Search by name, location, or description
- Dark theme for outdoor visibility

### In Progress
- None currently

### Known Bugs
- None currently tracked

---

## TODO - Priority

1. [ ] Verify all 19 event source scrapers still work
2. [ ] Update APK/EXE links to use GitHub Releases
3. [ ] Add more event sources

---

## TODO - Nice to Have

- [ ] Push notifications for watchlisted events
- [ ] Map view of events
- [ ] Calendar integration (add event to phone calendar)
- [ ] iOS build

---

## Completed

- [x] Flutter cross-platform app (Web, Android, Windows) (2026)
- [x] Python event scraper with 19 sources (2026)
- [x] GitHub Actions weekly auto-scrape (2026)
- [x] Cloudflare Pages deployment (2026)
- [x] Repo standardisation (2026-02-10)

---

## Notes

- Events are scraped from public motorcycle club/event websites
- Scraper runs weekly on Sunday via GitHub Actions
- If a source site changes layout, that scraper may need updating
