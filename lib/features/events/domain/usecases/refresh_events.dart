import '../../../../core/services/scraper_service.dart';
import '../repositories/events_repository.dart';

/// Use case for refreshing events from network
class RefreshEvents {
  final EventsRepository _repository;

  RefreshEvents(this._repository);

  Future<ScraperResult> call() {
    return _repository.refreshEvents();
  }
}
