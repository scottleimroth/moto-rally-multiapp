import '../../../events/domain/entities/event.dart';
import '../repositories/watchlist_repository.dart';

/// Use case for adding an event to watchlist
class AddToWatchlist {
  final WatchlistRepository _repository;

  AddToWatchlist(this._repository);

  Future<void> call(MotorcycleEvent event) {
    return _repository.addToWatchlist(event);
  }
}
