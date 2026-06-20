import type { MotorcycleEvent } from './events';

export type BikeType = 'tourer' | 'cruiser' | 'adventure' | 'sport' | 'classic';
export type Terrain = 'highway' | 'twisty' | 'gravel' | 'remote' | 'urban';

export interface TripSegment {
  id: string;
  name: string;
  state: string;
  distanceKm: number;
  terrain: Terrain;
  notes: string;
}

export interface TripPlan {
  eventId: string;
  startLocation: string;
  totalDistanceKm: number;
  dailyComfortKm: number;
  fuelRangeKm: number;
  riders: number;
  bikeType: BikeType;
  secureParking: boolean;
  pillion: boolean;
  accommodation: 'pub' | 'motel' | 'camping' | 'caravan_park' | 'mixed';
  segments: TripSegment[];
  checklist: string[];
  meetingPoint: string;
  emergencyContact: string;
  roadsideProvider: string;
}

export interface TripAdvice {
  rideDays: number;
  fuelStops: number;
  comfortBreaks: number;
  difficulty: 'Easy' | 'Moderate' | 'Demanding' | 'Remote';
  warnings: string[];
  routeNotes: string[];
  serviceNotes: string[];
  accommodationNotes: string[];
}

export const defaultChecklist = [
  'Wet-weather gear',
  'Water and hydration salts',
  'Puncture kit',
  'Basic tools',
  'Phone power bank',
  'First-aid kit',
  'Licence and rego papers',
  'Sunscreen',
  'Warm layer',
  'Tie-downs or straps',
];

export function createDefaultTripPlan(event: MotorcycleEvent): TripPlan {
  return {
    eventId: event.id,
    startLocation: '',
    totalDistanceKm: 300,
    dailyComfortKm: 450,
    fuelRangeKm: 240,
    riders: 1,
    bikeType: 'tourer',
    secureParking: true,
    pillion: false,
    accommodation: 'motel',
    segments: [
      {
        id: crypto.randomUUID ? crypto.randomUUID() : `${event.id}-segment-1`,
        name: event.location || event.title,
        state: event.state,
        distanceKm: 300,
        terrain: 'highway',
        notes: '',
      },
    ],
    checklist: defaultChecklist.slice(0, 6),
    meetingPoint: '',
    emergencyContact: '',
    roadsideProvider: '',
  };
}

export function calculateTripAdvice(plan: TripPlan, event?: MotorcycleEvent): TripAdvice {
  const segmentDistance = plan.segments.reduce(
    (sum, segment) => sum + Number(segment.distanceKm || 0),
    0,
  );
  const totalDistance = Math.max(Number(plan.totalDistanceKm || 0), segmentDistance);
  const rideDays = Math.max(1, Math.ceil(totalDistance / Math.max(1, plan.dailyComfortKm)));
  const fuelStops = Math.max(0, Math.ceil(totalDistance / Math.max(80, plan.fuelRangeKm)) - 1);
  const comfortBreaks = Math.max(1, Math.ceil(totalDistance / 150));
  const terrainScore = plan.segments.reduce((score, segment) => {
    if (segment.terrain === 'remote') return score + 3;
    if (segment.terrain === 'gravel') return score + 2;
    if (segment.terrain === 'twisty') return score + 1;
    return score;
  }, 0);
  const difficulty =
    terrainScore >= 4 || fuelStops >= 4
      ? 'Remote'
      : totalDistance > 800 || rideDays > 2
        ? 'Demanding'
        : terrainScore > 0 || plan.pillion
          ? 'Moderate'
          : 'Easy';

  const warnings: string[] = [];
  if (plan.fuelRangeKm < 200) warnings.push('Plan fuel stops early for smaller tanks.');
  if (totalDistance / rideDays > 500) warnings.push('Long riding days: add rest stops.');
  if (plan.segments.some((segment) => segment.terrain === 'remote')) {
    warnings.push('Remote sections need fuel, water, and phone-coverage planning.');
  }
  if (plan.segments.some((segment) => segment.terrain === 'gravel')) {
    warnings.push('Gravel sections: check tyres, luggage security, and weather.');
  }
  if (event?.state === 'QLD' || event?.state === 'NT' || event?.state === 'WA') {
    warnings.push('Heat exposure can build quickly: ride earlier and hydrate.');
  }

  const routeNotes = plan.segments.map((segment) => {
    const terrainNote =
      segment.terrain === 'twisty'
        ? 'good road-rhythm section'
        : segment.terrain === 'remote'
          ? 'limited-services section'
          : segment.terrain === 'gravel'
            ? 'surface-condition section'
            : segment.terrain === 'urban'
              ? 'traffic and timing section'
              : 'steady highway section';
    return `${segment.name || 'Route segment'}: ${terrainNote}`;
  });

  const serviceNotes = [
    `Allow roughly ${fuelStops} planned fuel stop${fuelStops === 1 ? '' : 's'}.`,
    `Add about ${comfortBreaks} comfort stop${comfortBreaks === 1 ? '' : 's'} for fatigue control.`,
    plan.bikeType === 'classic'
      ? 'Classic bike: add a tools, spares, and recovery plan.'
      : 'Check tyres, chain/belt/shaft, lights, and luggage before departure.',
  ];

  const accommodationNotes = [
    plan.secureParking
      ? 'Prioritise accommodation with secure or visible bike parking.'
      : 'Confirm parking before booking if leaving luggage on the bike.',
    plan.accommodation === 'camping'
      ? 'Camping: check weather, water, and late-arrival access.'
      : 'Book early near popular rally weekends.',
  ];

  return {
    rideDays,
    fuelStops,
    comfortBreaks,
    difficulty,
    warnings,
    routeNotes,
    serviceNotes,
    accommodationNotes,
  };
}
