import '../../../events/domain/entities/event.dart';
import '../repositories/watchlist_repository.dart';

/// Use case for getting watchlist events
class GetWatchlist {
  final WatchlistRepository _repository;

  GetWatchlist(this._repository);

  Future<List<MotorcycleEvent>> call() {
    return _repository.getWatchlist();
  }
}
