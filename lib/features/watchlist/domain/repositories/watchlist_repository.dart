import '../../../events/domain/entities/event.dart';

/// Abstract repository for watchlist
abstract class WatchlistRepository {
  /// Get all watchlist events
  Future<List<MotorcycleEvent>> getWatchlist();

  /// Add event to watchlist
  Future<void> addToWatchlist(MotorcycleEvent event);

  /// Remove event from watchlist
  Future<void> removeFromWatchlist(String eventId);

  /// Check if event is in watchlist
  Future<bool> isInWatchlist(String eventId);

  /// Clear entire watchlist
  Future<void> clearWatchlist();

  /// Get watchlist count
  Future<int> getWatchlistCount();
}
