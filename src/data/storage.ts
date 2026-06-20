import type { TripPlan } from './tripPlanner';

const watchlistKey = 'moto-rally-watchlist-v2';
const tripPlansKey = 'moto-rally-trip-plans-v2';

function readJson<T>(key: string, fallback: T): T {
  try {
    const raw = localStorage.getItem(key);
    return raw ? (JSON.parse(raw) as T) : fallback;
  } catch {
    return fallback;
  }
}

function writeJson<T>(key: string, value: T): void {
  localStorage.setItem(key, JSON.stringify(value));
}

export function loadWatchlist(): string[] {
  return readJson<string[]>(watchlistKey, []);
}

export function saveWatchlist(ids: string[]): void {
  writeJson(watchlistKey, ids);
}

export function loadTripPlans(): Record<string, TripPlan> {
  return readJson<Record<string, TripPlan>>(tripPlansKey, {});
}

export function saveTripPlans(plans: Record<string, TripPlan>): void {
  writeJson(tripPlansKey, plans);
}
