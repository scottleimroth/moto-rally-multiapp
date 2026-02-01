import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../events/domain/entities/event.dart';
import '../../domain/usecases/add_to_watchlist.dart';
import '../../domain/usecases/get_watchlist.dart';
import '../../domain/usecases/remove_from_watchlist.dart';

// Events
abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

class LoadWatchlistEvent extends WatchlistEvent {}

class AddToWatchlistEvent extends WatchlistEvent {
  final MotorcycleEvent event;

  const AddToWatchlistEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class RemoveFromWatchlistEvent extends WatchlistEvent {
  final String eventId;

  const RemoveFromWatchlistEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

// States
abstract class WatchlistState extends Equatable {
  const WatchlistState();

  @override
  List<Object?> get props => [];
}

class WatchlistInitial extends WatchlistState {}

class WatchlistLoading extends WatchlistState {}

class WatchlistLoaded extends WatchlistState {
  final List<MotorcycleEvent> events;
  final Set<String> eventIds;

  WatchlistLoaded({required this.events})
      : eventIds = events.map((e) => e.id).toSet();

  bool isInWatchlist(String eventId) => eventIds.contains(eventId);

  @override
  List<Object?> get props => [events];
}

class WatchlistError extends WatchlistState {
  final String message;

  const WatchlistError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final GetWatchlist _getWatchlist;
  final AddToWatchlist _addToWatchlist;
  final RemoveFromWatchlist _removeFromWatchlist;

  WatchlistBloc({
    required GetWatchlist getWatchlist,
    required AddToWatchlist addToWatchlist,
    required RemoveFromWatchlist removeFromWatchlist,
  })  : _getWatchlist = getWatchlist,
        _addToWatchlist = addToWatchlist,
        _removeFromWatchlist = removeFromWatchlist,
        super(WatchlistInitial()) {
    on<LoadWatchlistEvent>(_onLoadWatchlist);
    on<AddToWatchlistEvent>(_onAddToWatchlist);
    on<RemoveFromWatchlistEvent>(_onRemoveFromWatchlist);
  }

  Future<void> _onLoadWatchlist(
    LoadWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(WatchlistLoading());

    try {
      final events = await _getWatchlist();
      emit(WatchlistLoaded(events: events));
    } catch (e) {
      emit(WatchlistError(e.toString()));
    }
  }

  Future<void> _onAddToWatchlist(
    AddToWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    try {
      await _addToWatchlist(event.event);
      final events = await _getWatchlist();
      emit(WatchlistLoaded(events: events));
    } catch (e) {
      emit(WatchlistError(e.toString()));
    }
  }

  Future<void> _onRemoveFromWatchlist(
    RemoveFromWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    try {
      await _removeFromWatchlist(event.eventId);
      final events = await _getWatchlist();
      emit(WatchlistLoaded(events: events));
    } catch (e) {
      emit(WatchlistError(e.toString()));
    }
  }
}
