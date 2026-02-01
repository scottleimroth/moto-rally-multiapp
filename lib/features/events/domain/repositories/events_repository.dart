import '../entities/event.dart';
import '../../../../core/services/scraper_service.dart';

/// Abstract repository for events
abstract class EventsRepository {
  /// Get all events (from cache or network)
  Future<List<MotorcycleEvent>> getEvents({bool forceRefresh = false});

  /// Refresh events from network
  Future<ScraperResult> refreshEvents();

  /// Get cached events only
  Future<List<MotorcycleEvent>> getCachedEvents();

  /// Get last update timestamp
  Future<DateTime?> getLastUpdated();

  /// Clear cache
  Future<void> clearCache();
}
