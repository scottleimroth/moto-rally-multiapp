import React, { useMemo, useState } from 'react';
import { createRoot } from 'react-dom/client';
import {
  Bike,
  CalendarDays,
  Compass,
  ExternalLink,
  Filter,
  Fuel,
  HeartPulse,
  MapPin,
  Route,
  Search,
  ShieldCheck,
  Star,
  TentTree,
  Wrench,
  X,
} from 'lucide-react';

import {
  categories,
  categoryLabels,
  filterEvents,
  formatDateRange,
  getCleanEvents,
  stateLabels,
  states,
  type AustralianState,
  type EventCategory,
  type EventFilters,
  type MotorcycleEvent,
} from './data/events';
import {
  calculateTripAdvice,
  createDefaultTripPlan,
  defaultChecklist,
  type BikeType,
  type Terrain,
  type TripPlan,
} from './data/tripPlanner';
import {
  loadTripPlans,
  loadWatchlist,
  saveTripPlans,
  saveWatchlist,
} from './data/storage';
import './styles/app.css';

type ViewMode = 'events' | 'watchlist' | 'planner';

const bikeTypes: BikeType[] = ['tourer', 'cruiser', 'adventure', 'sport', 'classic'];
const terrains: Terrain[] = ['highway', 'twisty', 'gravel', 'remote', 'urban'];

function App() {
  const allEvents = useMemo(() => getCleanEvents(), []);
  const [filters, setFilters] = useState<EventFilters>({
    query: '',
    state: 'ALL',
    category: 'all',
  });
  const [view, setView] = useState<ViewMode>('events');
  const [selectedEventId, setSelectedEventId] = useState<string>(allEvents[0]?.id ?? '');
  const [watchlist, setWatchlist] = useState<string[]>(() => loadWatchlist());
  const [plans, setPlans] = useState<Record<string, TripPlan>>(() => loadTripPlans());

  const filteredEvents = useMemo(
    () => filterEvents(allEvents, filters),
    [allEvents, filters],
  );
  const watchlistEvents = allEvents.filter((event) => watchlist.includes(event.id));
  const selectedEvent =
    allEvents.find((event) => event.id === selectedEventId) ?? allEvents[0] ?? null;

  function updateWatchlist(id: string) {
    setWatchlist((current) => {
      const next = current.includes(id)
        ? current.filter((item) => item !== id)
        : [...current, id];
      saveWatchlist(next);
      return next;
    });
  }

  function openPlanner(event: MotorcycleEvent) {
    setSelectedEventId(event.id);
    setPlans((current) => {
      if (current[event.id]) return current;
      const next = { ...current, [event.id]: createDefaultTripPlan(event) };
      saveTripPlans(next);
      return next;
    });
    setView('planner');
  }

  function savePlan(plan: TripPlan) {
    setPlans((current) => {
      const next = { ...current, [plan.eventId]: plan };
      saveTripPlans(next);
      return next;
    });
  }

  const activeEvents = view === 'watchlist' ? watchlistEvents : filteredEvents;

  return (
    <main className="app-shell">
      <header className="topbar">
        <div className="brand">
          <span className="brand-mark">
            <Bike size={26} aria-hidden="true" />
          </span>
          <div>
            <h1>Moto Rally Australia</h1>
            <p>Upcoming Australian motorcycle events and ride planning.</p>
          </div>
        </div>
        <div className="topbar-stats" aria-label="Event summary">
          <span>{allEvents.length} upcoming</span>
          <span>{watchlist.length} saved</span>
        </div>
      </header>

      <section className="layout">
        <nav className="side-nav" aria-label="App sections">
          <button className={view === 'events' ? 'active' : ''} onClick={() => setView('events')}>
            <Compass size={19} /> Events
          </button>
          <button
            className={view === 'watchlist' ? 'active' : ''}
            onClick={() => setView('watchlist')}
          >
            <Star size={19} /> Watchlist
          </button>
          <button
            className={view === 'planner' ? 'active' : ''}
            onClick={() => setView('planner')}
            disabled={!selectedEvent}
          >
            <Route size={19} /> Trip planner
          </button>
        </nav>

        <section className="content-panel">
          {view !== 'planner' ? (
            <>
              <Filters filters={filters} onChange={setFilters} />
              <section className="event-grid" aria-live="polite">
                {activeEvents.length ? (
                  activeEvents.map((event) => (
                    <EventCard
                      key={event.id}
                      event={event}
                      saved={watchlist.includes(event.id)}
                      onSave={() => updateWatchlist(event.id)}
                      onPlan={() => openPlanner(event)}
                    />
                  ))
                ) : (
                  <EmptyState view={view} />
                )}
              </section>
            </>
          ) : selectedEvent ? (
            <TripPlanner
              event={selectedEvent}
              plan={plans[selectedEvent.id] ?? createDefaultTripPlan(selectedEvent)}
              onSave={savePlan}
              onClose={() => setView('events')}
            />
          ) : null}
        </section>
      </section>
    </main>
  );
}

interface FiltersProps {
  filters: EventFilters;
  onChange: (filters: EventFilters) => void;
}

function Filters({ filters, onChange }: FiltersProps) {
  return (
    <section className="filters" aria-label="Event filters">
      <label className="search-box">
        <Search size={20} aria-hidden="true" />
        <input
          value={filters.query}
          onChange={(event) => onChange({ ...filters, query: event.target.value })}
          placeholder="Search by event, place, state, or source"
        />
        {filters.query ? (
          <button
            className="icon-button"
            type="button"
            aria-label="Clear search"
            onClick={() => onChange({ ...filters, query: '' })}
          >
            <X size={18} />
          </button>
        ) : null}
      </label>

      <div className="filter-row">
        <label>
          <Filter size={17} aria-hidden="true" />
          <select
            value={filters.state}
            onChange={(event) =>
              onChange({ ...filters, state: event.target.value as AustralianState })
            }
          >
            {states.map((state) => (
              <option key={state} value={state}>
                {stateLabels[state]}
              </option>
            ))}
          </select>
        </label>
        <label>
          <Bike size={17} aria-hidden="true" />
          <select
            value={filters.category}
            onChange={(event) =>
              onChange({ ...filters, category: event.target.value as EventCategory })
            }
          >
            {categories.map((category) => (
              <option key={category} value={category}>
                {categoryLabels[category]}
              </option>
            ))}
          </select>
        </label>
      </div>
    </section>
  );
}

interface EventCardProps {
  event: MotorcycleEvent;
  saved: boolean;
  onSave: () => void;
  onPlan: () => void;
}

function EventCard({ event, saved, onSave, onPlan }: EventCardProps) {
  return (
    <article className="event-card">
      <div className="event-card-header">
        <span className={`category-pill ${event.category}`}>
          {categoryLabels[event.category]}
        </span>
        <button
          className={`save-button ${saved ? 'saved' : ''}`}
          onClick={onSave}
          aria-label={saved ? 'Remove from watchlist' : 'Add to watchlist'}
        >
          <Star size={19} fill={saved ? 'currentColor' : 'none'} />
        </button>
      </div>
      <h2>{event.title}</h2>
      <dl className="event-meta">
        <div>
          <dt>Date</dt>
          <dd>
            <CalendarDays size={17} /> {formatDateRange(event)}
          </dd>
        </div>
        <div>
          <dt>Location</dt>
          <dd>
            <MapPin size={17} /> {event.location || stateLabels[event.state]}
          </dd>
        </div>
      </dl>
      <p>{event.description}</p>
      <div className="event-source">
        <span>{event.sourceName}</span>
        <span>{event.state}</span>
      </div>
      <div className="card-actions">
        <button type="button" className="primary-action" onClick={onPlan}>
          <Route size={18} /> Plan trip
        </button>
        <a href={event.sourceUrl} target="_blank" rel="noreferrer" className="secondary-action">
          <ExternalLink size={18} /> Source
        </a>
      </div>
    </article>
  );
}

function EmptyState({ view }: { view: ViewMode }) {
  return (
    <div className="empty-state">
      <Bike size={42} />
      <h2>{view === 'watchlist' ? 'No saved events yet' : 'No events match these filters'}</h2>
      <p>
        {view === 'watchlist'
          ? 'Save events as you browse, then use the trip planner to prepare fuel, stops, and accommodation.'
          : 'Try another state, category, or search term.'}
      </p>
    </div>
  );
}

interface TripPlannerProps {
  event: MotorcycleEvent;
  plan: TripPlan;
  onSave: (plan: TripPlan) => void;
  onClose: () => void;
}

function TripPlanner({ event, plan, onSave, onClose }: TripPlannerProps) {
  const [draft, setDraft] = useState<TripPlan>(plan);
  const advice = calculateTripAdvice(draft, event);

  function update<K extends keyof TripPlan>(key: K, value: TripPlan[K]) {
    setDraft((current) => ({ ...current, [key]: value }));
  }

  function updateSegment(index: number, field: string, value: string | number) {
    setDraft((current) => {
      const segments = current.segments.map((segment, itemIndex) =>
        itemIndex === index ? { ...segment, [field]: value } : segment,
      );
      return { ...current, segments };
    });
  }

  function addSegment() {
    setDraft((current) => ({
      ...current,
      segments: [
        ...current.segments,
        {
          id: crypto.randomUUID(),
          name: 'New route segment',
          state: event.state,
          distanceKm: 150,
          terrain: 'highway',
          notes: '',
        },
      ],
    }));
  }

  function removeSegment(index: number) {
    setDraft((current) => ({
      ...current,
      segments: current.segments.filter((_, itemIndex) => itemIndex !== index),
    }));
  }

  function toggleChecklist(item: string) {
    setDraft((current) => {
      const checklist = current.checklist.includes(item)
        ? current.checklist.filter((entry) => entry !== item)
        : [...current.checklist, item];
      return { ...current, checklist };
    });
  }

  return (
    <section className="planner">
      <div className="planner-header">
        <div>
          <p className="eyebrow">Trip planner</p>
          <h2>{event.title}</h2>
          <p>{formatDateRange(event)} · {event.location}</p>
        </div>
        <div className="planner-actions">
          <button type="button" className="secondary-action" onClick={onClose}>
            <X size={18} /> Close
          </button>
          <button
            type="button"
            className="primary-action"
            onClick={() => {
              onSave(draft);
            }}
          >
            <ShieldCheck size={18} /> Save plan
          </button>
        </div>
      </div>

      <section className="planner-grid">
        <div className="planner-form">
          <h3>Ride basics</h3>
          <div className="form-grid">
            <TextField label="Start location" value={draft.startLocation} onChange={(value) => update('startLocation', value)} />
            <NumberField label="Total distance km" value={draft.totalDistanceKm} onChange={(value) => update('totalDistanceKm', value)} />
            <NumberField label="Comfortable daily km" value={draft.dailyComfortKm} onChange={(value) => update('dailyComfortKm', value)} />
            <NumberField label="Fuel range km" value={draft.fuelRangeKm} onChange={(value) => update('fuelRangeKm', value)} />
            <NumberField label="Riders" value={draft.riders} onChange={(value) => update('riders', value)} />
            <label className="field">
              <span>Bike type</span>
              <select value={draft.bikeType} onChange={(event) => update('bikeType', event.target.value as BikeType)}>
                {bikeTypes.map((type) => (
                  <option key={type} value={type}>{titleCase(type)}</option>
                ))}
              </select>
            </label>
          </div>

          <div className="toggle-row">
            <label><input type="checkbox" checked={draft.secureParking} onChange={(event) => update('secureParking', event.target.checked)} /> Secure parking</label>
            <label><input type="checkbox" checked={draft.pillion} onChange={(event) => update('pillion', event.target.checked)} /> Riding with pillion</label>
          </div>

          <h3>Route segments</h3>
          <div className="segments">
            {draft.segments.map((segment, index) => (
              <div className="segment-row" key={segment.id}>
                <TextField label="Segment" value={segment.name} onChange={(value) => updateSegment(index, 'name', value)} />
                <NumberField label="km" value={segment.distanceKm} onChange={(value) => updateSegment(index, 'distanceKm', value)} />
                <label className="field">
                  <span>Terrain</span>
                  <select value={segment.terrain} onChange={(event) => updateSegment(index, 'terrain', event.target.value as Terrain)}>
                    {terrains.map((terrain) => (
                      <option key={terrain} value={terrain}>{titleCase(terrain)}</option>
                    ))}
                  </select>
                </label>
                <button type="button" className="icon-button remove" onClick={() => removeSegment(index)} aria-label="Remove segment">
                  <X size={17} />
                </button>
              </div>
            ))}
            <button type="button" className="secondary-action inline" onClick={addSegment}>
              <Route size={18} /> Add segment
            </button>
          </div>

          <h3>Checklist</h3>
          <div className="checklist">
            {defaultChecklist.map((item) => (
              <label key={item}>
                <input
                  type="checkbox"
                  checked={draft.checklist.includes(item)}
                  onChange={() => toggleChecklist(item)}
                />
                {item}
              </label>
            ))}
          </div>
        </div>

        <aside className="planner-summary">
          <h3>Touring summary</h3>
          <div className="summary-grid">
            <Metric icon={<Route />} label="Ride days" value={advice.rideDays.toString()} />
            <Metric icon={<Fuel />} label="Fuel stops" value={advice.fuelStops.toString()} />
            <Metric icon={<HeartPulse />} label="Breaks" value={advice.comfortBreaks.toString()} />
            <Metric icon={<Compass />} label="Difficulty" value={advice.difficulty} />
          </div>

          <AdviceBlock title="Warnings" items={advice.warnings} icon={<ShieldCheck />} />
          <AdviceBlock title="Route notes" items={advice.routeNotes} icon={<Route />} />
          <AdviceBlock title="Service notes" items={advice.serviceNotes} icon={<Wrench />} />
          <AdviceBlock title="Stay notes" items={advice.accommodationNotes} icon={<TentTree />} />
        </aside>
      </section>
    </section>
  );
}

function TextField({
  label,
  value,
  onChange,
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
}) {
  return (
    <label className="field">
      <span>{label}</span>
      <input value={value} onChange={(event) => onChange(event.target.value)} />
    </label>
  );
}

function NumberField({
  label,
  value,
  onChange,
}: {
  label: string;
  value: number;
  onChange: (value: number) => void;
}) {
  return (
    <label className="field">
      <span>{label}</span>
      <input
        type="number"
        min="0"
        value={value}
        onChange={(event) => onChange(Number(event.target.value))}
      />
    </label>
  );
}

function Metric({
  icon,
  label,
  value,
}: {
  icon: React.ReactNode;
  label: string;
  value: string;
}) {
  return (
    <div className="metric">
      <span>{icon}</span>
      <strong>{value}</strong>
      <small>{label}</small>
    </div>
  );
}

function AdviceBlock({
  title,
  items,
  icon,
}: {
  title: string;
  items: string[];
  icon: React.ReactNode;
}) {
  return (
    <section className="advice-block">
      <h4>{icon}{title}</h4>
      {items.length ? (
        <ul>
          {items.map((item) => <li key={item}>{item}</li>)}
        </ul>
      ) : (
        <p>No specific warnings for this plan.</p>
      )}
    </section>
  );
}

function titleCase(value: string): string {
  return value.replace(/_/g, ' ').replace(/\b\w/g, (letter) => letter.toUpperCase());
}

createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
);
