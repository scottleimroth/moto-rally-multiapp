import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/get_events.dart';
import '../../domain/usecases/refresh_events.dart';

// Events
abstract class EventsEvent extends Equatable {
  const EventsEvent();

  @override
  List<Object?> get props => [];
}

class LoadEventsEvent extends EventsEvent {}

class RefreshEventsEvent extends EventsEvent {}

class FilterEventsEvent extends EventsEvent {
  final AustralianState? state;
  final EventCategory? category;
  final String? searchQuery;

  const FilterEventsEvent({
    this.state,
    this.category,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [state, category, searchQuery];
}

class ClearFiltersEvent extends EventsEvent {}

// States
abstract class EventsState extends Equatable {
  const EventsState();

  @override
  List<Object?> get props => [];
}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventsLoaded extends EventsState {
  final List<MotorcycleEvent> events;
  final List<MotorcycleEvent> filteredEvents;
  final AustralianState? selectedState;
  final EventCategory? selectedCategory;
  final String? searchQuery;
  final DateTime lastUpdated;
  final bool hasErrors;
  final String? errorMessage;

  const EventsLoaded({
    required this.events,
    required this.filteredEvents,
    this.selectedState,
    this.selectedCategory,
    this.searchQuery,
    required this.lastUpdated,
    this.hasErrors = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        events,
        filteredEvents,
        selectedState,
        selectedCategory,
        searchQuery,
        lastUpdated,
        hasErrors,
        errorMessage,
      ];

  EventsLoaded copyWith({
    List<MotorcycleEvent>? events,
    List<MotorcycleEvent>? filteredEvents,
    AustralianState? selectedState,
    EventCategory? selectedCategory,
    String? searchQuery,
    DateTime? lastUpdated,
    bool? hasErrors,
    String? errorMessage,
  }) {
    return EventsLoaded(
      events: events ?? this.events,
      filteredEvents: filteredEvents ?? this.filteredEvents,
      selectedState: selectedState,
      selectedCategory: selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      hasErrors: hasErrors ?? this.hasErrors,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class EventsError extends EventsState {
  final String message;

  const EventsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final GetEvents _getEvents;
  final RefreshEvents _refreshEvents;

  EventsBloc({
    required GetEvents getEvents,
    required RefreshEvents refreshEvents,
  })  : _getEvents = getEvents,
        _refreshEvents = refreshEvents,
        super(EventsInitial()) {
    on<LoadEventsEvent>(_onLoadEvents);
    on<RefreshEventsEvent>(_onRefreshEvents);
    on<FilterEventsEvent>(_onFilterEvents);
    on<ClearFiltersEvent>(_onClearFilters);
  }

  Future<void> _onLoadEvents(
    LoadEventsEvent event,
    Emitter<EventsState> emit,
  ) async {
    emit(EventsLoading());

    try {
      final events = await _getEvents();
      emit(EventsLoaded(
        events: events,
        filteredEvents: events,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  Future<void> _onRefreshEvents(
    RefreshEventsEvent event,
    Emitter<EventsState> emit,
  ) async {
    final currentState = state;
    try {
      final result = await _refreshEvents();
      final events = result.events;

      AustralianState? selectedState;
      EventCategory? selectedCategory;
      String? searchQuery;

      if (currentState is EventsLoaded) {
        selectedState = currentState.selectedState;
        selectedCategory = currentState.selectedCategory;
        searchQuery = currentState.searchQuery;
      }

      final filtered = _applyFilters(
        events,
        selectedState,
        selectedCategory,
        searchQuery,
      );

      emit(EventsLoaded(
        events: events,
        filteredEvents: filtered,
        selectedState: selectedState,
        selectedCategory: selectedCategory,
        searchQuery: searchQuery,
        lastUpdated: result.lastUpdated,
        hasErrors: result.hasErrors,
        errorMessage: result.errors.isNotEmpty
            ? result.errors.map((e) => e.message).join('\n')
            : null,
      ));
    } catch (e) {
      if (currentState is EventsLoaded) {
        emit(currentState.copyWith(
          hasErrors: true,
          errorMessage: e.toString(),
        ));
      } else {
        emit(EventsError(e.toString()));
      }
    }
  }

  void _onFilterEvents(
    FilterEventsEvent event,
    Emitter<EventsState> emit,
  ) {
    if (state is! EventsLoaded) return;

    final currentState = state as EventsLoaded;
    final newState = event.state ?? currentState.selectedState;
    final newCategory = event.category ?? currentState.selectedCategory;
    final newQuery = event.searchQuery ?? currentState.searchQuery;

    final filtered = _applyFilters(
      currentState.events,
      newState,
      newCategory,
      newQuery,
    );

    emit(currentState.copyWith(
      filteredEvents: filtered,
      selectedState: newState,
      selectedCategory: newCategory,
      searchQuery: newQuery,
    ));
  }

  void _onClearFilters(
    ClearFiltersEvent event,
    Emitter<EventsState> emit,
  ) {
    if (state is! EventsLoaded) return;

    final currentState = state as EventsLoaded;
    emit(EventsLoaded(
      events: currentState.events,
      filteredEvents: currentState.events,
      lastUpdated: currentState.lastUpdated,
    ));
  }

  List<MotorcycleEvent> _applyFilters(
    List<MotorcycleEvent> events,
    AustralianState? state,
    EventCategory? category,
    String? query,
  ) {
    var filtered = events;

    // Filter by state
    if (state != null && state != AustralianState.all) {
      filtered = filtered.where((e) => e.state == state).toList();
    }

    // Filter by category
    if (category != null && category != EventCategory.all) {
      filtered = filtered.where((e) => e.category == category).toList();
    }

    // Filter by search query
    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = filtered.where((e) {
        return e.title.toLowerCase().contains(lowerQuery) ||
            e.description.toLowerCase().contains(lowerQuery) ||
            e.location.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    return filtered;
  }
}
