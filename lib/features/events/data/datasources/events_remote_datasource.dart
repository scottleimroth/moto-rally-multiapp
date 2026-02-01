import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/scraper_service.dart';
import '../../domain/entities/event.dart';

/// Remote data source for fetching events from JSON data
class EventsRemoteDatasource {
  final ScraperService _scraperService;
  final http.Client? _httpClient;

  // URL to fetch fresh events JSON from GitHub (raw file URL)
  // Update this with your actual GitHub repo URL after pushing
  static const String _remoteJsonUrl =
      'https://raw.githubusercontent.com/USER/moto-rally-multiapp/main/assets/data/events.json';

  EventsRemoteDatasource(this._scraperService, [this._httpClient]);

  /// Fetch all events - tries remote JSON first, then bundled JSON, then scraper fallback
  Future<ScraperResult> fetchEvents() async {
    List<MotorcycleEvent> events = [];
    List<ScraperError> errors = [];

    // Try 1: Fetch fresh JSON from GitHub (for web/desktop with network)
    try {
      final remoteEvents = await _fetchFromRemoteJson();
      if (remoteEvents.isNotEmpty) {
        return ScraperResult(
          events: remoteEvents,
          errors: [],
          lastUpdated: DateTime.now(),
          totalSources: 5,
          successfulSources: 5,
        );
      }
    } catch (e) {
      errors.add(ScraperError(
        source: 'Remote JSON',
        message: e.toString(),
        timestamp: DateTime.now(),
      ));
    }

    // Try 2: Load bundled JSON from assets
    try {
      final bundledEvents = await _fetchFromBundledJson();
      if (bundledEvents.isNotEmpty) {
        return ScraperResult(
          events: bundledEvents,
          errors: errors,
          lastUpdated: DateTime.now(),
          totalSources: 5,
          successfulSources: 5,
        );
      }
    } catch (e) {
      errors.add(ScraperError(
        source: 'Bundled JSON',
        message: e.toString(),
        timestamp: DateTime.now(),
      ));
    }

    // Try 3: Fall back to live scraping (will likely fail on web due to CORS)
    try {
      return await _scraperService.fetchAllEvents();
    } catch (e) {
      errors.add(ScraperError(
        source: 'Scraper',
        message: e.toString(),
        timestamp: DateTime.now(),
      ));
    }

    // Return empty result with errors if all methods fail
    return ScraperResult(
      events: events,
      errors: errors,
      lastUpdated: DateTime.now(),
      totalSources: 5,
      successfulSources: 0,
    );
  }

  /// Fetch events from remote JSON URL (GitHub raw file)
  Future<List<MotorcycleEvent>> _fetchFromRemoteJson() async {
    final client = _httpClient ?? http.Client();
    try {
      final response = await client
          .get(Uri.parse(_remoteJsonUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return _parseEventsJson(response.body);
      }
    } finally {
      if (_httpClient == null) {
        client.close();
      }
    }
    return [];
  }

  /// Fetch events from bundled JSON asset
  Future<List<MotorcycleEvent>> _fetchFromBundledJson() async {
    final jsonString = await rootBundle.loadString('assets/data/events.json');
    return _parseEventsJson(jsonString);
  }

  /// Parse events from JSON string
  List<MotorcycleEvent> _parseEventsJson(String jsonString) {
    final Map<String, dynamic> data = json.decode(jsonString);
    final List<dynamic> eventsData = data['events'] ?? [];

    return eventsData.map((e) => _eventFromJson(e)).toList();
  }

  /// Convert JSON map to MotorcycleEvent
  MotorcycleEvent _eventFromJson(Map<String, dynamic> json) {
    return MotorcycleEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'])
          : null,
      endDate:
          json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      location: json['location'] ?? '',
      state: AustralianState.fromString(json['state'] ?? 'ALL'),
      category: EventCategory.fromString(json['category'] ?? 'other'),
      imageUrl: json['imageUrl'],
      sourceUrl: json['sourceUrl'] ?? '',
      sourceName: json['sourceName'] ?? '',
      lastUpdated: DateTime.now(),
      organizer: json['organizer'],
      contactInfo: json['contactInfo'],
      price: json['price']?.toDouble(),
      isFree: json['isFree'] ?? (json['price'] == null || json['price'] == 0),
    );
  }

  /// Get events sorted by date
  Future<List<MotorcycleEvent>> fetchSortedEvents() async {
    final result = await fetchEvents();
    final events = List<MotorcycleEvent>.from(result.events);

    // Sort by date (null dates at the end)
    events.sort((a, b) {
      if (a.startDate == null && b.startDate == null) return 0;
      if (a.startDate == null) return 1;
      if (b.startDate == null) return -1;
      return a.startDate!.compareTo(b.startDate!);
    });

    return events;
  }
}
