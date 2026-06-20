import { describe, expect, test } from 'vitest';

import {
  filterEvents,
  getCleanEvents,
  isCurrentOrUpcoming,
  type MotorcycleEvent,
} from './events';
import { calculateTripAdvice, createDefaultTripPlan } from './tripPlanner';

const baseEvent: MotorcycleEvent = {
  id: 'event-1',
  title: 'Test Rally',
  description: 'Australian motorcycle rally',
  startDate: '2026-06-21',
  location: 'NSW 2000',
  state: 'NSW',
  category: 'rally',
  sourceUrl: 'https://example.com',
  sourceName: 'Example',
};

describe('events data', () => {
  test('keeps events that end today', () => {
    expect(
      isCurrentOrUpcoming(
        { ...baseEvent, startDate: '2026-06-20', endDate: '2026-06-21' },
        new Date('2026-06-21T09:00:00'),
      ),
    ).toBe(true);
  });

  test('drops events that ended before today', () => {
    expect(
      isCurrentOrUpcoming(
        { ...baseEvent, startDate: '2026-06-19', endDate: '2026-06-20' },
        new Date('2026-06-21T09:00:00'),
      ),
    ).toBe(false);
  });

  test('loads only current or upcoming generated events', () => {
    const events = getCleanEvents(new Date('2026-06-21T00:00:00'));
    expect(events.length).toBeGreaterThan(0);
    expect(events.map((event) => event.title)).not.toContain('General Meeting');
  });

  test('filters by state, category, and search text', () => {
    const events = [
      baseEvent,
      { ...baseEvent, id: 'event-2', title: 'Queensland Swap', state: 'QLD', category: 'swap_meet' },
    ] satisfies MotorcycleEvent[];

    expect(
      filterEvents(events, { query: 'swap', state: 'QLD', category: 'swap_meet' }),
    ).toHaveLength(1);
  });
});

describe('trip planner', () => {
  test('calculates fuel stops and remote warnings', () => {
    const plan = createDefaultTripPlan(baseEvent);
    plan.totalDistanceKm = 900;
    plan.fuelRangeKm = 180;
    plan.segments = [
      { id: 's1', name: 'Remote road', state: 'NT', distanceKm: 900, terrain: 'remote', notes: '' },
    ];

    const advice = calculateTripAdvice(plan, baseEvent);

    expect(advice.fuelStops).toBeGreaterThanOrEqual(4);
    expect(advice.difficulty).toBe('Remote');
    expect(advice.warnings.join(' ')).toContain('Remote sections');
  });

  test('uses edited total distance when it is higher than default segment distance', () => {
    const plan = createDefaultTripPlan(baseEvent);
    plan.totalDistanceKm = 900;
    plan.fuelRangeKm = 180;

    const advice = calculateTripAdvice(plan, baseEvent);

    expect(advice.fuelStops).toBe(4);
  });
});
