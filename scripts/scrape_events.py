#!/usr/bin/env python3
"""
Motorcycle Events Scraper for Australian Events
Scrapes multiple sources and outputs a JSON file for the Moto Rally app.
Runs via GitHub Actions on a weekly schedule.
"""

import json
import re
import hashlib
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional
import requests
from bs4 import BeautifulSoup

# Configuration
OUTPUT_FILE = Path(__file__).parent.parent / "assets" / "data" / "events.json"
REQUEST_TIMEOUT = 30
USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"

# Event sources to scrape
SOURCES = [
    {
        "id": "motorcyclerallies",
        "name": "Motorcycle Rallies Australia",
        "url": "https://www.motorcycleralliesaustralia.com/",
        "scraper": "scrape_motorcycle_rallies"
    },
    {
        "id": "justbikes",
        "name": "Just Bikes",
        "url": "https://www.justbikes.com.au/events/upcoming",
        "scraper": "scrape_justbikes"
    },
    {
        "id": "oldbikemag",
        "name": "Old Bike Australasia",
        "url": "https://www.oldbikemag.com.au/october-rally-calendar/",
        "scraper": "scrape_oldbikemag"
    },
    {
        "id": "throwyourlegover",
        "name": "Throw Your Leg Over",
        "url": "https://www.throwyourlegover.com.au/events",
        "scraper": "scrape_throwyourlegover"
    },
    {
        "id": "vmccnsw",
        "name": "VMCC NSW",
        "url": "https://vmccnsw.org.au/events/",
        "scraper": "scrape_vmccnsw"
    },
    # BMW Clubs
    {
        "id": "bmwca",
        "name": "BMW Clubs Australia",
        "url": "https://www.bmwca.au/",
        "scraper": "scrape_bmw_clubs"
    },
    {
        "id": "bmwmccwa",
        "name": "BMW MCC Western Australia",
        "url": "https://www.bmwmccwa.asn.au/",
        "scraper": "scrape_generic_events"
    },
    {
        "id": "bmwmccact",
        "name": "BMW MCC Canberra",
        "url": "https://www.bmwmcc.au/page-1419638",
        "scraper": "scrape_wildapricot_calendar"
    },
    # Ducati Clubs
    {
        "id": "docnsw",
        "name": "Ducati Owners Club NSW",
        "url": "https://www.ducatiownersclubnsw.com.au/",
        "scraper": "scrape_generic_events"
    },
    {
        "id": "docv",
        "name": "Ducati Owners Club Victoria",
        "url": "https://www.docv.org/events",
        "scraper": "scrape_generic_events"
    },
    {
        "id": "docsa",
        "name": "Ducati Owners Club SA",
        "url": "https://www.docsa.com.au/index.php/schedule-2",
        "scraper": "scrape_generic_events"
    },
    # Harley-Davidson
    {
        "id": "harleyau",
        "name": "Harley-Davidson Australia",
        "url": "https://www.harley-davidson.com/au/en/content/event-calendar.html",
        "scraper": "scrape_generic_events"
    },
    # Indian Motorcycle Club
    {
        "id": "imca",
        "name": "Indian Motorcycle Club Australia",
        "url": "https://www.indianmotorcycleclub.com.au/events/",
        "scraper": "scrape_generic_events"
    },
    # Triumph
    {
        "id": "tomcc",
        "name": "Triumph Owners MCC Australia",
        "url": "https://tomcc.com.au/",
        "scraper": "scrape_generic_events"
    },
    # Classic Owners SA
    {
        "id": "classicsa",
        "name": "Classic Owners MC SA",
        "url": "https://classicowners.org/",
        "scraper": "scrape_generic_events"
    },
    # Motorcycling Australia official
    {
        "id": "ma",
        "name": "Motorcycling Australia",
        "url": "https://www.ma.org.au/ma-calendar/",
        "scraper": "scrape_generic_events"
    },
    # Motorcycling Queensland
    {
        "id": "mqld",
        "name": "Motorcycling Queensland",
        "url": "https://www.mqld.org.au/riders/calendar/",
        "scraper": "scrape_generic_events"
    },
    # Motorcycling NSW
    {
        "id": "mnsw",
        "name": "Motorcycling NSW",
        "url": "https://motorcycling.com.au/riders/calendar/",
        "scraper": "scrape_generic_events"
    },
    # Motorcycling Victoria
    {
        "id": "mvic",
        "name": "Motorcycling Victoria",
        "url": "https://www.motorcyclingvic.com.au/riders/calendar/",
        "scraper": "scrape_generic_events"
    },
]

# Australian states mapping
STATE_PATTERNS = {
    "NSW": ["nsw", "new south wales", "sydney", "newcastle", "wollongong", "bathurst", "orange", "goulburn", "singleton", "dungog", "kempsey"],
    "VIC": ["vic", "victoria", "melbourne", "geelong", "phillip island", "ballarat", "bendigo", "bright", "scoresby", "newstead", "casterton"],
    "QLD": ["qld", "queensland", "brisbane", "gold coast", "sunshine coast", "cairns", "townsville", "roma", "maleny", "toowoomba"],
    "WA": ["wa", "western australia", "perth", "fremantle"],
    "SA": ["sa", "south australia", "adelaide", "the bend", "coonalpyn"],
    "TAS": ["tas", "tasmania", "hobart", "launceston"],
    "ACT": ["act", "canberra", "australian capital territory"],
    "NT": ["nt", "northern territory", "darwin", "alice springs"],
}

# Event categories mapping
CATEGORY_PATTERNS = {
    "swap_meet": ["swap", "swap meet", "swapmeet", "parts", "memorabilia"],
    "rally": ["rally", "ride", "run", "tour", "adventure"],
    "track": ["track day", "trackday", "circuit", "racing", "race"],
    "show": ["show", "display", "exhibition", "concours"],
    "racing": ["race", "racing", "championship", "superbike", "motogp", "grand prix"],
    "other": [],
}


def get_session() -> requests.Session:
    """Create a requests session with headers."""
    session = requests.Session()
    session.headers.update({
        "User-Agent": USER_AGENT,
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "en-AU,en;q=0.9",
    })
    return session


def fetch_page(url: str, session: requests.Session) -> Optional[BeautifulSoup]:
    """Fetch a page and return parsed BeautifulSoup object."""
    try:
        response = session.get(url, timeout=REQUEST_TIMEOUT)
        response.raise_for_status()
        return BeautifulSoup(response.text, "html.parser")
    except Exception as e:
        print(f"Error fetching {url}: {e}")
        return None


def extract_state(text: str) -> str:
    """Extract Australian state from text."""
    text_lower = text.lower()
    for state, patterns in STATE_PATTERNS.items():
        for pattern in patterns:
            if pattern in text_lower:
                return state
    return "ALL"


def extract_category(text: str) -> str:
    """Extract event category from text."""
    text_lower = text.lower()
    for category, patterns in CATEGORY_PATTERNS.items():
        for pattern in patterns:
            if pattern in text_lower:
                return category
    return "other"


def parse_date(date_str: str) -> Optional[str]:
    """Parse various date formats and return ISO format."""
    if not date_str:
        return None

    date_str = date_str.strip()

    # Common date patterns
    patterns = [
        (r"(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{4})", "%d/%m/%Y"),
        (r"(\d{1,2})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+(\d{4})", None),
        (r"(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+(\d{1,2}),?\s+(\d{4})", None),
    ]

    month_map = {
        "jan": 1, "feb": 2, "mar": 3, "apr": 4, "may": 5, "jun": 6,
        "jul": 7, "aug": 8, "sep": 9, "oct": 10, "nov": 11, "dec": 12
    }

    # Try DD/MM/YYYY or similar
    match = re.search(r"(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{4})", date_str)
    if match:
        day, month, year = int(match.group(1)), int(match.group(2)), int(match.group(3))
        try:
            return datetime(year, month, day).strftime("%Y-%m-%d")
        except ValueError:
            pass

    # Try "12 April 2026" format
    match = re.search(r"(\d{1,2})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+(\d{4})", date_str, re.I)
    if match:
        day = int(match.group(1))
        month = month_map.get(match.group(2).lower()[:3], 1)
        year = int(match.group(3))
        try:
            return datetime(year, month, day).strftime("%Y-%m-%d")
        except ValueError:
            pass

    # Try "April 12, 2026" format
    match = re.search(r"(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+(\d{1,2}),?\s+(\d{4})", date_str, re.I)
    if match:
        month = month_map.get(match.group(1).lower()[:3], 1)
        day = int(match.group(2))
        year = int(match.group(3))
        try:
            return datetime(year, month, day).strftime("%Y-%m-%d")
        except ValueError:
            pass

    return None


def generate_id(title: str, source_id: str, date: Optional[str]) -> str:
    """Generate a unique event ID."""
    unique_str = f"{source_id}_{title}_{date or 'nodate'}"
    return hashlib.md5(unique_str.encode()).hexdigest()[:12]


def scrape_motorcycle_rallies(session: requests.Session) -> list:
    """Scrape Motorcycle Rallies Australia."""
    events = []
    soup = fetch_page("https://www.motorcycleralliesaustralia.com/", session)
    if not soup:
        return events

    # Look for event listings
    for article in soup.select("article, .event, .rally, .listing, tr"):
        try:
            title_el = article.select_one("h1, h2, h3, h4, a, .title")
            if not title_el:
                continue

            title = title_el.get_text(strip=True)
            if len(title) < 5 or title.lower() in ["home", "about", "contact"]:
                continue

            link = title_el.get("href") if title_el.name == "a" else None
            if not link:
                link_el = article.select_one("a[href]")
                link = link_el.get("href") if link_el else None

            if link and not link.startswith("http"):
                link = f"https://www.motorcycleralliesaustralia.com{link}"

            text = article.get_text(" ", strip=True)
            date = parse_date(text)

            # Skip if date is in the past
            if date:
                try:
                    event_date = datetime.strptime(date, "%Y-%m-%d")
                    if event_date < datetime.now() - timedelta(days=1):
                        continue
                except:
                    pass

            events.append({
                "id": generate_id(title, "motorcyclerallies", date),
                "title": title,
                "description": text[:500] if len(text) > 20 else "",
                "startDate": date,
                "location": "",
                "state": extract_state(text),
                "category": extract_category(title + " " + text),
                "sourceUrl": link or "https://www.motorcycleralliesaustralia.com/",
                "sourceName": "Motorcycle Rallies Australia",
            })
        except Exception as e:
            print(f"Error parsing motorcycle rallies event: {e}")
            continue

    return events


def scrape_justbikes(session: requests.Session) -> list:
    """Scrape Just Bikes events."""
    events = []
    soup = fetch_page("https://www.justbikes.com.au/events/upcoming", session)
    if not soup:
        return events

    for article in soup.select("article, .event-item, .event, .listing"):
        try:
            title_el = article.select_one("h1, h2, h3, h4, .title, a")
            if not title_el:
                continue

            title = title_el.get_text(strip=True)
            if len(title) < 5:
                continue

            link = None
            link_el = article.select_one("a[href]")
            if link_el:
                link = link_el.get("href")
                if link and not link.startswith("http"):
                    link = f"https://www.justbikes.com.au{link}"

            text = article.get_text(" ", strip=True)
            date = parse_date(text)

            if date:
                try:
                    event_date = datetime.strptime(date, "%Y-%m-%d")
                    if event_date < datetime.now() - timedelta(days=1):
                        continue
                except:
                    pass

            events.append({
                "id": generate_id(title, "justbikes", date),
                "title": title,
                "description": text[:500] if len(text) > 20 else "",
                "startDate": date,
                "location": "",
                "state": extract_state(text),
                "category": extract_category(title + " " + text),
                "sourceUrl": link or "https://www.justbikes.com.au/events/upcoming",
                "sourceName": "Just Bikes",
            })
        except Exception as e:
            print(f"Error parsing justbikes event: {e}")
            continue

    return events


def scrape_oldbikemag(session: requests.Session) -> list:
    """Scrape Old Bike Australasia events."""
    events = []
    soup = fetch_page("https://www.oldbikemag.com.au/october-rally-calendar/", session)
    if not soup:
        return events

    # This site often has events in tables or paragraphs
    content = soup.select_one(".entry-content, .content, article")
    if not content:
        return events

    # Look for event patterns in text
    text_blocks = content.find_all(["p", "li", "tr"])

    for block in text_blocks:
        try:
            text = block.get_text(" ", strip=True)
            if len(text) < 20:
                continue

            # Try to find a date in the text
            date = parse_date(text)
            if not date:
                continue

            # Skip past events
            try:
                event_date = datetime.strptime(date, "%Y-%m-%d")
                if event_date < datetime.now() - timedelta(days=1):
                    continue
            except:
                pass

            # Extract title (usually the first part before the date or dash)
            title = text.split(" - ")[0].split(" – ")[0][:100].strip()
            if len(title) < 5:
                continue

            link = None
            link_el = block.select_one("a[href]")
            if link_el:
                link = link_el.get("href")

            events.append({
                "id": generate_id(title, "oldbikemag", date),
                "title": title,
                "description": text[:500],
                "startDate": date,
                "location": "",
                "state": extract_state(text),
                "category": extract_category(title + " " + text),
                "sourceUrl": link or "https://www.oldbikemag.com.au/october-rally-calendar/",
                "sourceName": "Old Bike Australasia",
            })
        except Exception as e:
            print(f"Error parsing oldbikemag event: {e}")
            continue

    return events


def scrape_throwyourlegover(session: requests.Session) -> list:
    """Scrape Throw Your Leg Over events."""
    events = []
    soup = fetch_page("https://www.throwyourlegover.com.au/events", session)
    if not soup:
        return events

    for article in soup.select("article, .event, .listing, .collection-item"):
        try:
            title_el = article.select_one("h1, h2, h3, h4, .title, a")
            if not title_el:
                continue

            title = title_el.get_text(strip=True)
            if len(title) < 5:
                continue

            link = None
            link_el = article.select_one("a[href]")
            if link_el:
                link = link_el.get("href")
                if link and not link.startswith("http"):
                    link = f"https://www.throwyourlegover.com.au{link}"

            text = article.get_text(" ", strip=True)
            date = parse_date(text)

            if date:
                try:
                    event_date = datetime.strptime(date, "%Y-%m-%d")
                    if event_date < datetime.now() - timedelta(days=1):
                        continue
                except:
                    pass

            events.append({
                "id": generate_id(title, "throwyourlegover", date),
                "title": title,
                "description": text[:500] if len(text) > 20 else "",
                "startDate": date,
                "location": "",
                "state": extract_state(text),
                "category": extract_category(title + " " + text),
                "sourceUrl": link or "https://www.throwyourlegover.com.au/events",
                "sourceName": "Throw Your Leg Over",
            })
        except Exception as e:
            print(f"Error parsing throwyourlegover event: {e}")
            continue

    return events


def scrape_vmccnsw(session: requests.Session) -> list:
    """Scrape VMCC NSW events."""
    events = []
    soup = fetch_page("https://vmccnsw.org.au/events/", session)
    if not soup:
        return events

    for article in soup.select("article, .event, .tribe-events-calendar-list__event, .type-tribe_events"):
        try:
            title_el = article.select_one("h1, h2, h3, h4, .tribe-events-calendar-list__event-title, a")
            if not title_el:
                continue

            title = title_el.get_text(strip=True)
            if len(title) < 5:
                continue

            link = None
            link_el = article.select_one("a[href]")
            if link_el:
                link = link_el.get("href")

            text = article.get_text(" ", strip=True)
            date = parse_date(text)

            # Also check for datetime attribute
            time_el = article.select_one("time[datetime]")
            if time_el and not date:
                date = time_el.get("datetime", "")[:10]

            if date:
                try:
                    event_date = datetime.strptime(date, "%Y-%m-%d")
                    if event_date < datetime.now() - timedelta(days=1):
                        continue
                except:
                    pass

            events.append({
                "id": generate_id(title, "vmccnsw", date),
                "title": title,
                "description": text[:500] if len(text) > 20 else "",
                "startDate": date,
                "location": "",
                "state": "NSW",  # VMCC NSW is always NSW
                "category": extract_category(title + " " + text),
                "sourceUrl": link or "https://vmccnsw.org.au/events/",
                "sourceName": "VMCC NSW",
            })
        except Exception as e:
            print(f"Error parsing vmccnsw event: {e}")
            continue

    return events


def scrape_bmw_clubs(session: requests.Session) -> list:
    """Scrape BMW Clubs Australia events."""
    events = []
    soup = fetch_page("https://www.bmwca.au/", session)
    if not soup:
        return events

    for article in soup.select("article, .event, .event-item, .tribe-events-calendar-list__event, .ecs-event"):
        try:
            title_el = article.select_one("h1, h2, h3, h4, .title, a")
            if not title_el:
                continue

            title = title_el.get_text(strip=True)
            if len(title) < 5 or title.lower() in ["home", "about", "contact", "events"]:
                continue

            link = None
            link_el = article.select_one("a[href]")
            if link_el:
                link = link_el.get("href")
                if link and not link.startswith("http"):
                    link = f"https://www.bmwca.au{link}"

            text = article.get_text(" ", strip=True)
            date = parse_date(text)

            if date:
                try:
                    event_date = datetime.strptime(date, "%Y-%m-%d")
                    if event_date < datetime.now() - timedelta(days=1):
                        continue
                except:
                    pass

            events.append({
                "id": generate_id(title, "bmwca", date),
                "title": title,
                "description": text[:500] if len(text) > 20 else "",
                "startDate": date,
                "location": "",
                "state": extract_state(text),
                "category": extract_category(title + " " + text),
                "sourceUrl": link or "https://www.bmwca.au/",
                "sourceName": "BMW Clubs Australia",
            })
        except Exception as e:
            print(f"Error parsing BMW clubs event: {e}")
            continue

    return events


def scrape_generic_events(session: requests.Session, source: dict) -> list:
    """Generic event scraper that works for most club websites."""
    events = []
    soup = fetch_page(source["url"], session)
    if not soup:
        return events

    # Common event selectors used by various CMS platforms
    selectors = [
        "article",
        ".event",
        ".event-item",
        ".event-listing",
        ".tribe-events-calendar-list__event",
        ".ecs-event",
        ".type-tribe_events",
        ".upcoming-event",
        ".event-card",
        ".calendar-event",
        ".list-item",
        "li.event",
        "tr",
    ]

    event_elements = []
    for selector in selectors:
        event_elements = soup.select(selector)
        if len(event_elements) > 2:  # Found meaningful content
            break

    for element in event_elements[:30]:  # Limit to 30 events
        try:
            title_el = element.select_one("h1, h2, h3, h4, h5, .title, .event-title, a")
            if not title_el:
                continue

            title = title_el.get_text(strip=True)
            if len(title) < 5:
                continue

            # Skip navigation/menu items
            skip_words = ["home", "about", "contact", "events", "calendar", "menu", "login", "join"]
            if title.lower() in skip_words:
                continue

            link = None
            link_el = element.select_one("a[href]")
            if link_el:
                link = link_el.get("href")
                if link and not link.startswith("http"):
                    base_url = source["url"].rsplit("/", 1)[0]
                    link = f"{base_url}/{link.lstrip('/')}"

            text = element.get_text(" ", strip=True)
            date = parse_date(text)

            # Check for datetime attribute
            time_el = element.select_one("time[datetime]")
            if time_el and not date:
                date = time_el.get("datetime", "")[:10]

            if date:
                try:
                    event_date = datetime.strptime(date, "%Y-%m-%d")
                    if event_date < datetime.now() - timedelta(days=1):
                        continue
                except:
                    pass

            events.append({
                "id": generate_id(title, source["id"], date),
                "title": title,
                "description": text[:500] if len(text) > 20 else "",
                "startDate": date,
                "location": "",
                "state": extract_state(text),
                "category": extract_category(title + " " + text),
                "sourceUrl": link or source["url"],
                "sourceName": source["name"],
            })
        except Exception as e:
            print(f"Error parsing {source['name']} event: {e}")
            continue

    return events


def get_fallback_events() -> list:
    """Return manually curated events as fallback."""
    now = datetime.now()
    return [
        {
            "id": "curated_001",
            "title": "Scoresby Swap Meet",
            "description": "Presented by Vintage Motorcycle Club of Vic. Gates open 6am for stallholders, general public entry 7am-12 noon. Entry $10 per person, Swap Site $20.",
            "startDate": "2026-04-12",
            "location": "National Steam Centre, Scoresby VIC",
            "state": "VIC",
            "category": "swap_meet",
            "sourceUrl": "https://www.oldbikemag.com.au/october-rally-calendar/",
            "sourceName": "Old Bike Australasia",
        },
        {
            "id": "curated_002",
            "title": "Maleny Motorcycle Swap Meet",
            "description": "Hosted by Sunshine Coast HMCCQ. Free parking inside grounds. Entry $10 per person, Swap Sites $10.",
            "startDate": "2026-06-13",
            "location": "Maleny Showgrounds, QLD",
            "state": "QLD",
            "category": "swap_meet",
            "sourceUrl": "https://www.oldbikemag.com.au/october-rally-calendar/",
            "sourceName": "Old Bike Australasia",
        },
        {
            "id": "curated_003",
            "title": "Goulburn CRCG Motorcycle Only Swap Meet",
            "description": "Motorcycle only swap meet in Goulburn.",
            "startDate": "2026-03-22",
            "location": "Goulburn, NSW",
            "state": "NSW",
            "category": "swap_meet",
            "sourceUrl": "https://www.oldbikemag.com.au/october-rally-calendar/",
            "sourceName": "Old Bike Australasia",
        },
        {
            "id": "curated_004",
            "title": "Classic & Enthusiasts MCC NSW 43rd Annual Orange Rally",
            "description": "Saturday and Sunday rides, presentation dinner Saturday night at Scout Camp, Lake Canobolas.",
            "startDate": "2026-02-14",
            "endDate": "2026-02-15",
            "location": "Scout Camp, Lake Canobolas, Orange NSW",
            "state": "NSW",
            "category": "rally",
            "sourceUrl": "https://www.oldbikemag.com.au/october-rally-calendar/",
            "sourceName": "Old Bike Australasia",
        },
        {
            "id": "curated_005",
            "title": "48th All British Rally",
            "description": "Presented by BSA Motorcycle Owners Association of Victoria. Pre-paid entries $80 close 5th April.",
            "startDate": "2026-04-24",
            "endDate": "2026-04-26",
            "location": "Old Newstead Racecourse, Newstead VIC",
            "state": "VIC",
            "category": "rally",
            "sourceUrl": "https://www.oldbikemag.com.au/october-rally-calendar/",
            "sourceName": "Old Bike Australasia",
        },
        {
            "id": "curated_006",
            "title": "30th Annual Heart of the Hunter Rally",
            "description": "Presented by the Singleton Classic Motorcycle Club. 30th anniversary event.",
            "startDate": "2026-05-01",
            "endDate": "2026-05-03",
            "location": "Singleton, NSW",
            "state": "NSW",
            "category": "rally",
            "sourceUrl": "https://www.oldbikemag.com.au/october-rally-calendar/",
            "sourceName": "Old Bike Australasia",
        },
        {
            "id": "curated_007",
            "title": "Australian Classic Motorcycle TT",
            "description": "Featuring Classic & Historic, Solo classes, BEARS, Sidecars, Roaring Sporties, Superbike Feature Events and Classic Bike Parade Laps.",
            "startDate": "2026-03-20",
            "endDate": "2026-03-22",
            "location": "One Raceway, Goulburn NSW",
            "state": "NSW",
            "category": "racing",
            "sourceUrl": "https://www.oldbikemag.com.au/october-rally-calendar/",
            "sourceName": "Old Bike Australasia",
        },
        {
            "id": "curated_008",
            "title": "IMCA Krusty Rally 2026",
            "description": "Indian Motorcycle Club of Australia annual rally.",
            "startDate": "2026-10-31",
            "endDate": "2026-11-03",
            "location": "TBA",
            "state": "ALL",
            "category": "rally",
            "sourceUrl": "https://www.indianmotorcycleclub.com.au/events/",
            "sourceName": "Indian Motorcycle Club",
        },
        {
            "id": "curated_009",
            "title": "ASBK Round 1 - Phillip Island",
            "description": "Australian Superbike Championship Round 1 with WorldSBK.",
            "startDate": "2026-02-20",
            "endDate": "2026-02-22",
            "location": "Phillip Island Grand Prix Circuit, VIC",
            "state": "VIC",
            "category": "racing",
            "sourceUrl": "https://www.ma.org.au/ma-calendar/",
            "sourceName": "Motorcycling Australia",
        },
        {
            "id": "curated_010",
            "title": "ASBK Round 2 - Sydney Motorsport Park",
            "description": "Australian Superbike Championship Round 2.",
            "startDate": "2026-03-27",
            "endDate": "2026-03-28",
            "location": "Sydney Motorsport Park, NSW",
            "state": "NSW",
            "category": "racing",
            "sourceUrl": "https://www.ma.org.au/ma-calendar/",
            "sourceName": "Motorcycling Australia",
        },
        {
            "id": "curated_011",
            "title": "ASBK Round 3 - The Bend",
            "description": "Australian Superbike Championship Round 3.",
            "startDate": "2026-05-01",
            "endDate": "2026-05-03",
            "location": "The Bend Motorsport Park, SA",
            "state": "SA",
            "category": "racing",
            "sourceUrl": "https://www.ma.org.au/ma-calendar/",
            "sourceName": "Motorcycling Australia",
        },
        {
            "id": "curated_012",
            "title": "MotoGP Australian Grand Prix 2026",
            "description": "MotoGP World Championship at the legendary Phillip Island circuit.",
            "startDate": "2026-10-16",
            "endDate": "2026-10-18",
            "location": "Phillip Island Grand Prix Circuit, VIC",
            "state": "VIC",
            "category": "racing",
            "sourceUrl": "https://www.motogp.com.au/",
            "sourceName": "MotoGP Australia",
        },
        {
            "id": "curated_013",
            "title": "Bulli Antique Motorcycle Weekend",
            "description": "10th Anniversary of the Bulli Antique Motorcycle Weekend event.",
            "startDate": "2026-08-15",
            "endDate": "2026-08-16",
            "location": "Bulli Showground, NSW",
            "state": "NSW",
            "category": "show",
            "sourceUrl": "https://www.amcaaustralia.org/",
            "sourceName": "AMCA Australia",
        },
    ]


def main():
    """Main function to scrape all sources and save JSON."""
    print(f"Starting scrape at {datetime.now().isoformat()}")
    print(f"Total sources configured: {len(SOURCES)}")

    session = get_session()
    all_events = []
    errors = []

    # Specific scrapers for certain sources
    specific_scrapers = {
        "motorcyclerallies": scrape_motorcycle_rallies,
        "justbikes": scrape_justbikes,
        "oldbikemag": scrape_oldbikemag,
        "throwyourlegover": scrape_throwyourlegover,
        "vmccnsw": scrape_vmccnsw,
        "bmwca": scrape_bmw_clubs,
    }

    for source in SOURCES:
        source_id = source["id"]
        try:
            print(f"Scraping {source['name']}...")

            # Use specific scraper if available, otherwise generic
            if source_id in specific_scrapers:
                events = specific_scrapers[source_id](session)
            else:
                events = scrape_generic_events(session, source)

            print(f"  Found {len(events)} events")
            all_events.extend(events)
        except Exception as e:
            print(f"  Error scraping {source_id}: {e}")
            errors.append({"source": source_id, "error": str(e)})

    # Add fallback curated events if we didn't get many
    if len(all_events) < 5:
        print("Adding fallback curated events...")
        fallback = get_fallback_events()
        # Only add fallback events not already in scraped events (by title similarity)
        existing_titles = {e["title"].lower() for e in all_events}
        for event in fallback:
            if event["title"].lower() not in existing_titles:
                all_events.append(event)

    # Remove duplicates by ID
    seen_ids = set()
    unique_events = []
    for event in all_events:
        if event["id"] not in seen_ids:
            seen_ids.add(event["id"])
            unique_events.append(event)

    # Sort by date
    def sort_key(e):
        d = e.get("startDate")
        if d:
            try:
                return datetime.strptime(d, "%Y-%m-%d")
            except:
                pass
        return datetime.max

    unique_events.sort(key=sort_key)

    # Build output
    output = {
        "lastUpdated": datetime.now().isoformat(),
        "totalEvents": len(unique_events),
        "sources": [s["name"] for s in SOURCES],
        "errors": errors,
        "events": unique_events,
    }

    # Ensure output directory exists
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    # Write JSON
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(output, f, indent=2, ensure_ascii=False)

    print(f"\nSaved {len(unique_events)} events to {OUTPUT_FILE}")
    print(f"Errors: {len(errors)}")


if __name__ == "__main__":
    main()
