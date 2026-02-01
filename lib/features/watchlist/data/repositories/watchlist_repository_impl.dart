import '../../../events/domain/entities/event.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/watchlist_local_datasource.dart';

/// Implementation of WatchlistRepository
class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistLocalDatasource _localDatasource;

  WatchlistRepositoryImpl({
    required WatchlistLocalDatasource localDatasource,
  }) : _localDatasource = localDatasource;

  @override
  Future<List<MotorcycleEvent>> getWatchlist() {
    return _localDatasource.getWatchlist();
  }

  @override
  Future<void> addToWatchlist(MotorcycleEvent event) {
    return _localDatasource.addToWatchlist(event);
  }

  @override
  Future<void> removeFromWatchlist(String eventId) {
    return _localDatasource.removeFromWatchlist(eventId);
  }

  @override
  Future<bool> isInWatchlist(String eventId) {
    return _localDatasource.isInWatchlist(eventId);
  }

  @override
  Future<void> clearWatchlist() {
    return _localDatasource.clearWatchlist();
  }

  @override
  Future<int> getWatchlistCount() {
    return _localDatasource.getWatchlistCount();
  }
}
