import '../repositories/watchlist_repository.dart';

/// Use case for removing an event from watchlist
class RemoveFromWatchlist {
  final WatchlistRepository _repository;

  RemoveFromWatchlist(this._repository);

  Future<void> call(String eventId) {
    return _repository.removeFromWatchlist(eventId);
  }
}
