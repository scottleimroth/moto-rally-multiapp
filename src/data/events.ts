import rawEvents from '../../assets/data/events.json';

export type EventCategory =
  | 'all'
  | 'rally'
  | 'swap_meet'
  | 'show'
  | 'track'
  | 'racing'
  | 'other';

export type AustralianState =
  | 'ALL'
  | 'NSW'
  | 'VIC'
  | 'QLD'
  | 'WA'
  | 'SA'
  | 'TAS'
  | 'ACT'
  | 'NT';

export interface MotorcycleEvent {
  id: string;
  title: string;
  description: string;
  startDate: string | null;
  endDate?: string | null;
  location: string;
  state: AustralianState;
  category: EventCategory;
  sourceUrl: string;
  sourceName: string;
}

export interface EventsPayload {
  lastUpdated: string;
  totalEvents: number;
  sources: string[];
  errors: string[];
  events: MotorcycleEvent[];
}

export const eventsPayload = rawEvents as EventsPayload;

export const categoryLabels: Record<EventCategory, string> = {
  all: 'All types',
  rally: 'Rallies',
  swap_meet: 'Swap meets',
  show: 'Shows',
  track: 'Track days',
  racing: 'Racing',
  other: 'Other',
};

export const stateLabels: Record<AustralianState, string> = {
  ALL: 'All states',
  NSW: 'New South Wales',
  VIC: 'Victoria',
  QLD: 'Queensland',
  WA: 'Western Australia',
  SA: 'South Australia',
  TAS: 'Tasmania',
  ACT: 'ACT',
  NT: 'Northern Territory',
};

export function parseEventDate(value: string | null | undefined): Date | null {
  if (!value) return null;
  const parsed = new Date(`${value}T00:00:00`);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

export function isCurrentOrUpcoming(
  event: MotorcycleEvent,
  referenceDate = new Date(),
): boolean {
  const start = parseEventDate(event.startDate);
  if (!start) return false;

  const end = parseEventDate(event.endDate) ?? start;
  const today = new Date(
    referenceDate.getFullYear(),
    referenceDate.getMonth(),
    referenceDate.getDate(),
  );
  const eventEnd = new Date(end.getFullYear(), end.getMonth(), end.getDate());

  return eventEnd >= today;
}

export function sortEvents(events: MotorcycleEvent[]): MotorcycleEvent[] {
  return [...events].sort((a, b) => {
    const dateA = parseEventDate(a.startDate)?.getTime() ?? Number.MAX_SAFE_INTEGER;
    const dateB = parseEventDate(b.startDate)?.getTime() ?? Number.MAX_SAFE_INTEGER;
    return dateA - dateB || a.title.localeCompare(b.title);
  });
}

export function formatDateRange(event: MotorcycleEvent): string {
  const start = parseEventDate(event.startDate);
  if (!start) return 'Date TBA';

  const formatter = new Intl.DateTimeFormat('en-AU', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  });

  const end = parseEventDate(event.endDate);
  if (!end || end.toDateString() === start.toDateString()) {
    return formatter.format(start);
  }

  return `${formatter.format(start)} - ${formatter.format(end)}`;
}

export function getCleanEvents(referenceDate = new Date()): MotorcycleEvent[] {
  return sortEvents(
    eventsPayload.events.filter((event) => isCurrentOrUpcoming(event, referenceDate)),
  );
}

export interface EventFilters {
  query: string;
  state: AustralianState;
  category: EventCategory;
}

export function filterEvents(
  events: MotorcycleEvent[],
  filters: EventFilters,
): MotorcycleEvent[] {
  const query = filters.query.trim().toLowerCase();

  return events.filter((event) => {
    const matchesState = filters.state === 'ALL' || event.state === filters.state;
    const matchesCategory =
      filters.category === 'all' || event.category === filters.category;
    const searchable = [
      event.title,
      event.description,
      event.location,
      event.state,
      event.sourceName,
    ]
      .join(' ')
      .toLowerCase();

    return matchesState && matchesCategory && (!query || searchable.includes(query));
  });
}

export const states: AustralianState[] = [
  'ALL',
  'NSW',
  'VIC',
  'QLD',
  'WA',
  'SA',
  'TAS',
  'ACT',
  'NT',
];

export const categories: EventCategory[] = [
  'all',
  'rally',
  'swap_meet',
  'show',
  'track',
  'racing',
  'other',
];
