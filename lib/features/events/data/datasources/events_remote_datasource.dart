import '../../../../core/services/scraper_service.dart';
import '../../domain/entities/event.dart';

/// Remote data source for fetching events from web sources
class EventsRemoteDatasource {
  final ScraperService _scraperService;

  EventsRemoteDatasource(this._scraperService);

  /// Fetch all events from configured sources
  Future<ScraperResult> fetchEvents() async {
    return await _scraperService.fetchAllEvents();
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
