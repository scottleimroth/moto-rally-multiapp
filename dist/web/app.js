const DATA_URL = './assets/assets/data/events.json?v=20260620';

const state = {
  events: [],
  filtered: [],
  query: '',
  state: 'ALL',
  category: 'ALL',
  source: 'ALL',
};

const els = {
  status: document.querySelector('#status'),
  search: document.querySelector('#searchInput'),
  state: document.querySelector('#stateFilter'),
  category: document.querySelector('#categoryFilter'),
  source: document.querySelector('#sourceFilter'),
  clear: document.querySelector('#clearFilters'),
  count: document.querySelector('#resultCount'),
  updated: document.querySelector('#lastUpdated'),
  list: document.querySelector('#eventsList'),
  empty: document.querySelector('#emptyState'),
};

const categoryLabels = {
  swap_meet: 'Swap Meet',
  rally: 'Rally',
  track: 'Track Day',
  show: 'Show',
  ride: 'Organised Ride',
  racing: 'Racing',
  other: 'Other',
  ALL: 'All Categories',
};

function parseDate(value) {
  if (!value) return null;
  const date = new Date(`${String(value).slice(0, 10)}T00:00:00`);
  return Number.isNaN(date.getTime()) ? null : date;
}

function todayStart() {
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), now.getDate());
}

function isCurrentOrFuture(event) {
  const end = parseDate(event.endDate || event.startDate);
  return Boolean(end) && end >= todayStart();
}

function byDate(a, b) {
  const aDate = parseDate(a.startDate);
  const bDate = parseDate(b.startDate);
  if (!aDate && !bDate) return a.title.localeCompare(b.title);
  if (!aDate) return 1;
  if (!bDate) return -1;
  return aDate - bDate || a.title.localeCompare(b.title);
}

function formatDate(value) {
  const date = parseDate(value);
  if (!date) return 'Date TBA';
  return new Intl.DateTimeFormat('en-AU', {
    weekday: 'short',
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(date);
}

function dateBox(event) {
  const date = parseDate(event.startDate);
  if (!date) {
    return '<div class="date-box"><span class="month">Date</span><span class="day">TBA</span></div>';
  }

  const month = new Intl.DateTimeFormat('en-AU', { month: 'short' }).format(date);
  const year = date.getFullYear();
  return `<div class="date-box">
    <span class="month">${escapeHtml(month)}</span>
    <span class="day">${date.getDate()}</span>
    <span class="year">${year}</span>
  </div>`;
}

function dateRange(event) {
  if (!event.startDate) return 'Date TBA';
  if (!event.endDate || event.endDate === event.startDate) return formatDate(event.startDate);
  return `${formatDate(event.startDate)} to ${formatDate(event.endDate)}`;
}

function escapeHtml(value) {
  return String(value ?? '').replace(/[&<>"']/g, (char) => ({
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;',
  }[char]));
}

function option(value, label) {
  return `<option value="${escapeHtml(value)}">${escapeHtml(label)}</option>`;
}

function fillSelect(select, values, allLabel, labeler = (value) => value) {
  select.innerHTML = option('ALL', allLabel) + values.map((value) => option(value, labeler(value))).join('');
}

function uniqueSorted(key) {
  return [...new Set(state.events.map((event) => event[key]).filter(Boolean))].sort((a, b) => a.localeCompare(b));
}

function setupFilters() {
  fillSelect(els.state, uniqueSorted('state'), 'All States');
  fillSelect(els.category, uniqueSorted('category'), 'All Categories', (value) => categoryLabels[value] || value);
  fillSelect(els.source, uniqueSorted('sourceName'), 'All Sources');
}

function applyFilters() {
  const query = state.query.trim().toLowerCase();
  state.filtered = state.events.filter((event) => {
    if (state.state !== 'ALL' && event.state !== state.state) return false;
    if (state.category !== 'ALL' && event.category !== state.category) return false;
    if (state.source !== 'ALL' && event.sourceName !== state.source) return false;
    if (!query) return true;

    return [event.title, event.description, event.location, event.sourceName]
      .some((value) => String(value || '').toLowerCase().includes(query));
  });
  render();
}

function render() {
  els.count.textContent = `${state.filtered.length} ${state.filtered.length === 1 ? 'event' : 'events'}`;
  els.empty.hidden = state.filtered.length > 0;
  els.list.innerHTML = state.filtered.map(renderEvent).join('');
}

function renderEvent(event) {
  const url = event.sourceUrl || '#';
  const category = categoryLabels[event.category] || event.category || 'Other';
  const stateLabel = event.state && event.state !== 'ALL' ? event.state : 'Australia';
  const location = event.location || stateLabel;
  return `<article class="event-card">
    ${dateBox(event)}
    <div class="event-main">
      <h2 class="event-title"><a href="${escapeHtml(url)}" target="_blank" rel="noreferrer">${escapeHtml(event.title || 'Untitled event')}</a></h2>
      <div class="chips">
        <span class="chip">${escapeHtml(dateRange(event))}</span>
        <span class="chip">${escapeHtml(stateLabel)}</span>
        <span class="chip">${escapeHtml(category)}</span>
        ${event.startDate ? '' : '<span class="chip warn">Date TBA</span>'}
      </div>
      <p class="description">${escapeHtml(event.description || location)}</p>
    </div>
    <a class="source-link" href="${escapeHtml(url)}" target="_blank" rel="noreferrer">${escapeHtml(event.sourceName || 'Source')}</a>
  </article>`;
}

function bindEvents() {
  els.search.addEventListener('input', () => {
    state.query = els.search.value;
    applyFilters();
  });
  els.state.addEventListener('change', () => {
    state.state = els.state.value;
    applyFilters();
  });
  els.category.addEventListener('change', () => {
    state.category = els.category.value;
    applyFilters();
  });
  els.source.addEventListener('change', () => {
    state.source = els.source.value;
    applyFilters();
  });
  els.clear.addEventListener('click', () => {
    state.query = '';
    state.state = 'ALL';
    state.category = 'ALL';
    state.source = 'ALL';
    els.search.value = '';
    els.state.value = 'ALL';
    els.category.value = 'ALL';
    els.source.value = 'ALL';
    applyFilters();
  });
}

async function loadEvents() {
  try {
    const response = await fetch(DATA_URL, { cache: 'no-store' });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const data = await response.json();
    state.events = (data.events || [])
      .filter(isCurrentOrFuture)
      .sort(byDate);

    const updated = data.lastUpdated ? new Date(data.lastUpdated) : null;
    els.updated.textContent = updated && !Number.isNaN(updated.getTime())
      ? `Updated ${new Intl.DateTimeFormat('en-AU', { dateStyle: 'medium', timeStyle: 'short' }).format(updated)}`
      : '';
    els.status.textContent = `${state.events.length} current events loaded`;
    setupFilters();
    applyFilters();
  } catch (error) {
    els.status.textContent = `Could not load events: ${error.message}`;
    els.list.innerHTML = '';
    els.empty.hidden = false;
    els.empty.querySelector('h2').textContent = 'Events could not be loaded';
    els.empty.querySelector('p').textContent = 'Check the event JSON file or try refreshing.';
  }
}

bindEvents();
loadEvents();
