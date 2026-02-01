import '../entities/event.dart';
import '../repositories/events_repository.dart';

/// Use case for fetching events
class GetEvents {
  final EventsRepository _repository;

  GetEvents(this._repository);

  Future<List<MotorcycleEvent>> call({bool forceRefresh = false}) {
    return _repository.getEvents(forceRefresh: forceRefresh);
  }
}
