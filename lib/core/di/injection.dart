import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';
import '../services/scraper_service.dart';
import '../../features/events/data/datasources/events_local_datasource.dart';
import '../../features/events/data/datasources/events_remote_datasource.dart';
import '../../features/events/data/repositories/events_repository_impl.dart';
import '../../features/events/domain/repositories/events_repository.dart';
import '../../features/events/domain/usecases/get_events.dart';
import '../../features/events/domain/usecases/refresh_events.dart';
import '../../features/events/presentation/bloc/events_bloc.dart';
import '../../features/watchlist/data/datasources/watchlist_local_datasource.dart';
import '../../features/watchlist/data/repositories/watchlist_repository_impl.dart';
import '../../features/watchlist/domain/repositories/watchlist_repository.dart';
import '../../features/watchlist/domain/usecases/add_to_watchlist.dart';
import '../../features/watchlist/domain/usecases/get_watchlist.dart';
import '../../features/watchlist/domain/usecases/remove_from_watchlist.dart';
import '../../features/watchlist/presentation/bloc/watchlist_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Register Hive boxes
  final watchlistBox = await Hive.openBox(AppConstants.watchlistBoxKey);
  final eventsBox = await Hive.openBox(AppConstants.eventsBoxKey);

  getIt.registerLazySingleton<Box>(() => watchlistBox,
      instanceName: 'watchlist');
  getIt.registerLazySingleton<Box>(() => eventsBox, instanceName: 'events');

  // Core Services
  getIt.registerLazySingleton<ScraperService>(() => ScraperService());

  // Events Feature
  getIt.registerLazySingleton<EventsLocalDatasource>(
    () => EventsLocalDatasource(getIt<Box>(instanceName: 'events')),
  );

  getIt.registerLazySingleton<EventsRemoteDatasource>(
    () => EventsRemoteDatasource(getIt<ScraperService>()),
  );

  getIt.registerLazySingleton<EventsRepository>(
    () => EventsRepositoryImpl(
      remoteDatasource: getIt<EventsRemoteDatasource>(),
      localDatasource: getIt<EventsLocalDatasource>(),
    ),
  );

  getIt.registerLazySingleton<GetEvents>(
    () => GetEvents(getIt<EventsRepository>()),
  );

  getIt.registerLazySingleton<RefreshEvents>(
    () => RefreshEvents(getIt<EventsRepository>()),
  );

  getIt.registerFactory<EventsBloc>(
    () => EventsBloc(
      getEvents: getIt<GetEvents>(),
      refreshEvents: getIt<RefreshEvents>(),
    ),
  );

  // Watchlist Feature
  getIt.registerLazySingleton<WatchlistLocalDatasource>(
    () => WatchlistLocalDatasource(getIt<Box>(instanceName: 'watchlist')),
  );

  getIt.registerLazySingleton<WatchlistRepository>(
    () => WatchlistRepositoryImpl(
      localDatasource: getIt<WatchlistLocalDatasource>(),
    ),
  );

  getIt.registerLazySingleton<GetWatchlist>(
    () => GetWatchlist(getIt<WatchlistRepository>()),
  );

  getIt.registerLazySingleton<AddToWatchlist>(
    () => AddToWatchlist(getIt<WatchlistRepository>()),
  );

  getIt.registerLazySingleton<RemoveFromWatchlist>(
    () => RemoveFromWatchlist(getIt<WatchlistRepository>()),
  );

  getIt.registerFactory<WatchlistBloc>(
    () => WatchlistBloc(
      getWatchlist: getIt<GetWatchlist>(),
      addToWatchlist: getIt<AddToWatchlist>(),
      removeFromWatchlist: getIt<RemoveFromWatchlist>(),
    ),
  );
}
