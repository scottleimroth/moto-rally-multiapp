/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Moto Rally Aggregator';
  static const String appVersion = '1.0.0';

  // Event Sources
  static const List<EventSource> eventSources = [
    EventSource(
      name: 'Just Bikes',
      url: 'https://www.justbikes.com.au/events/upcoming',
      id: 'justbikes',
    ),
    EventSource(
      name: 'Old Bike Magazine',
      url: 'https://www.oldbikemag.com.au/category/buzz-box/calendar/',
      id: 'oldbikemag',
    ),
    EventSource(
      name: 'Motorcycling Australia',
      url: 'https://motorcycling.com.au/riders/calendar/',
      id: 'motorcyclingau',
    ),
  ];

  // Storage Keys
  static const String watchlistBoxKey = 'watchlist_box';
  static const String eventsBoxKey = 'events_cache_box';
  static const String settingsBoxKey = 'settings_box';

  // UI Constants
  static const double minTouchTarget = 44.0;
  static const double cardBorderRadius = 12.0;
  static const double defaultPadding = 16.0;

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 6);
}

/// Represents an event data source
class EventSource {
  final String name;
  final String url;
  final String id;

  const EventSource({
    required this.name,
    required this.url,
    required this.id,
  });
}

/// Australian States
enum AustralianState {
  nsw('NSW', 'New South Wales'),
  vic('VIC', 'Victoria'),
  qld('QLD', 'Queensland'),
  wa('WA', 'Western Australia'),
  sa('SA', 'South Australia'),
  tas('TAS', 'Tasmania'),
  act('ACT', 'Australian Capital Territory'),
  nt('NT', 'Northern Territory'),
  all('ALL', 'All States');

  final String code;
  final String fullName;

  const AustralianState(this.code, this.fullName);

  static AustralianState fromString(String value) {
    final upperValue = value.toUpperCase();
    return AustralianState.values.firstWhere(
      (state) =>
          state.code == upperValue ||
          state.fullName.toUpperCase() == upperValue,
      orElse: () => AustralianState.all,
    );
  }
}

/// Event Categories
enum EventCategory {
  swapMeet('Swap Meet', 'swap_meet'),
  rally('Rally', 'rally'),
  track('Track Day', 'track'),
  show('Show', 'show'),
  ride('Organised Ride', 'ride'),
  racing('Racing', 'racing'),
  other('Other', 'other'),
  all('All Categories', 'all');

  final String displayName;
  final String id;

  const EventCategory(this.displayName, this.id);

  static EventCategory fromString(String value) {
    final lowerValue = value.toLowerCase();

    // Keywords for categorization
    if (lowerValue.contains('swap') || lowerValue.contains('market')) {
      return EventCategory.swapMeet;
    }
    if (lowerValue.contains('rally') || lowerValue.contains('ride')) {
      return EventCategory.rally;
    }
    if (lowerValue.contains('track') || lowerValue.contains('circuit')) {
      return EventCategory.track;
    }
    if (lowerValue.contains('show') || lowerValue.contains('display')) {
      return EventCategory.show;
    }
    if (lowerValue.contains('race') || lowerValue.contains('racing')) {
      return EventCategory.racing;
    }

    return EventCategory.other;
  }
}
