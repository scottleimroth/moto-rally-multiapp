import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/scraper_service.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';
import '../datasources/events_local_datasource.dart';
import '../datasources/events_remote_datasource.dart';

/// Implementation of EventsRepository
class EventsRepositoryImpl implements EventsRepository {
  final EventsRemoteDatasource _remoteDatasource;
  final EventsLocalDatasource _localDatasource;

  EventsRepositoryImpl({
    required EventsRemoteDatasource remoteDatasource,
    required EventsLocalDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  @override
  Future<List<MotorcycleEvent>> getEvents({bool forceRefresh = false}) async {
    // Check if we have valid cache
    if (!forceRefresh) {
      final isCacheValid = await _localDatasource.isCacheValid(
        AppConstants.cacheDuration,
      );
      if (isCacheValid) {
        final cached = await _localDatasource.getCachedEvents();
        if (cached.isNotEmpty) {
          return _sortByDate(cached);
        }
      }
    }

    // Fetch from network
    try {
      final result = await _remoteDatasource.fetchEvents();
      final events = result.events;

      // Cache the results
      await _localDatasource.cacheEvents(events);
      await _localDatasource.storeMetadata({
        'lastUpdated': DateTime.now().toIso8601String(),
        'totalEvents': events.length,
        'successfulSources': result.successfulSources,
        'totalSources': result.totalSources,
        'errors': result.errors.map((e) => e.message).toList(),
      });

      return _sortByDate(events);
    } catch (e) {
      // Fall back to cache on error
      final cached = await _localDatasource.getCachedEvents();
      if (cached.isNotEmpty) {
        return _sortByDate(cached);
      }
      rethrow;
    }
  }

  @override
  Future<ScraperResult> refreshEvents() async {
    final result = await _remoteDatasource.fetchEvents();

    // Cache the results
    await _localDatasource.cacheEvents(result.events);
    await _localDatasource.storeMetadata({
      'lastUpdated': DateTime.now().toIso8601String(),
      'totalEvents': result.events.length,
      'successfulSources': result.successfulSources,
      'totalSources': result.totalSources,
      'errors': result.errors.map((e) => e.message).toList(),
    });

    return result;
  }

  @override
  Future<List<MotorcycleEvent>> getCachedEvents() {
    return _localDatasource.getCachedEvents();
  }

  @override
  Future<DateTime?> getLastUpdated() {
    return _localDatasource.getLastUpdated();
  }

  @override
  Future<void> clearCache() {
    return _localDatasource.clearCache();
  }

  List<MotorcycleEvent> _sortByDate(List<MotorcycleEvent> events) {
    final sorted = List<MotorcycleEvent>.from(events);
    sorted.sort((a, b) {
      if (a.startDate == null && b.startDate == null) return 0;
      if (a.startDate == null) return 1;
      if (b.startDate == null) return -1;
      return a.startDate!.compareTo(b.startDate!);
    });
    return sorted;
  }
}
