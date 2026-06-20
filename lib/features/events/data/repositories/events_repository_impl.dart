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
        final currentCached = _currentEvents(cached);
        if (currentCached.isNotEmpty) {
          return _sortByDate(currentCached);
        }
      }
    }

    // Fetch from network
    try {
      final result = await _remoteDatasource.fetchEvents();
      final events = _currentEvents(result.events);

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
      final currentCached = _currentEvents(cached);
      if (currentCached.isNotEmpty) {
        return _sortByDate(currentCached);
      }
      rethrow;
    }
  }

  @override
  Future<ScraperResult> refreshEvents() async {
    final result = await _remoteDatasource.fetchEvents();
    final events = _currentEvents(result.events);

    // Cache the results
    await _localDatasource.cacheEvents(events);
    await _localDatasource.storeMetadata({
      'lastUpdated': DateTime.now().toIso8601String(),
      'totalEvents': events.length,
      'successfulSources': result.successfulSources,
      'totalSources': result.totalSources,
      'errors': result.errors.map((e) => e.message).toList(),
    });

    return ScraperResult(
      events: events,
      errors: result.errors,
      lastUpdated: result.lastUpdated,
      totalSources: result.totalSources,
      successfulSources: result.successfulSources,
    );
  }

  @override
  Future<List<MotorcycleEvent>> getCachedEvents() {
    return _localDatasource
        .getCachedEvents()
        .then((events) => _sortByDate(_currentEvents(events)));
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

  List<MotorcycleEvent> _currentEvents(List<MotorcycleEvent> events) {
    return events
        .where((event) =>
            event.isCurrentOrUpcoming() && _isAustralianMotorcycleEvent(event))
        .toList();
  }

  bool _isAustralianMotorcycleEvent(MotorcycleEvent event) {
    final text = [
      event.title,
      event.description,
      event.location,
      event.sourceName,
      event.sourceUrl,
    ].join(' ').toLowerCase();

    const blockedTerms = [
      'milwaukee',
      'harley-davidson homecoming',
      'homecoming festival',
      'european hog',
      'european h.o.g',
      'slovenia',
      'croatia',
      'austria',
      'germany',
      'france',
      'italy',
      'spain',
      'portugal',
      'united states',
      ' usa ',
      'sturgis',
      'daytona',
      'cars national rally',
      'full calendar of events suited to girder fork bikes',
    ];

    if (blockedTerms.any(text.contains)) return false;
    if (!text.contains('motor') &&
        !text.contains('bike') &&
        !text.contains('rally') &&
        !text.contains('ride') &&
        !text.contains('mcc') &&
        !text.contains(' mc ')) {
      return false;
    }

    return text.contains('.au') ||
        text.contains('australia') ||
        text.contains('australian') ||
        text.contains('new south wales') ||
        text.contains('victoria') ||
        text.contains('queensland') ||
        text.contains('western australia') ||
        text.contains('south australia') ||
        text.contains('tasmania') ||
        text.contains('northern territory') ||
        text.contains('australian capital territory') ||
        text.contains(' nsw') ||
        text.contains(' vic') ||
        text.contains(' qld') ||
        text.contains(' wa') ||
        text.contains(' sa') ||
        text.contains(' tas') ||
        text.contains(' nt') ||
        text.contains(' act');
  }
}
