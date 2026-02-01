import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/events/presentation/bloc/events_bloc.dart';
import 'features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'features/events/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for cross-platform storage
  await Hive.initFlutter();

  // Setup dependency injection
  await configureDependencies();

  runApp(const MotoRallyApp());
}

class MotoRallyApp extends StatelessWidget {
  const MotoRallyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<EventsBloc>()..add(LoadEventsEvent()),
        ),
        BlocProvider(
          create: (_) => getIt<WatchlistBloc>()..add(LoadWatchlistEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'Moto Rally Aggregator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomePage(),
      ),
    );
  }
}
