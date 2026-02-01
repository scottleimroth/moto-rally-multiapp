import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../events/presentation/widgets/event_card.dart';
import '../bloc/watchlist_bloc.dart';

/// Watchlist page showing saved events
/// Available offline for viewing during rides
class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.bookmark,
                size: 28,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Your Watchlist',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              BlocBuilder<WatchlistBloc, WatchlistState>(
                builder: (context, state) {
                  if (state is WatchlistLoaded && state.events.isNotEmpty) {
                    return Text(
                      '${state.events.length} saved',
                      style: Theme.of(context).textTheme.bodyMedium,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Offline indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Row(
            children: [
              Icon(
                Icons.offline_pin,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'These events are saved for offline viewing',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ],
          ),
        ),

        // Watchlist content
        Expanded(
          child: BlocBuilder<WatchlistBloc, WatchlistState>(
            builder: (context, state) {
              if (state is WatchlistLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is WatchlistError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load watchlist',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(state.message),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: AppConstants.minTouchTarget,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<WatchlistBloc>().add(LoadWatchlistEvent());
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is WatchlistLoaded) {
                if (state.events.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 80,
                          color: Theme.of(context).disabledColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No saved events',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Save events to view them offline while riding in areas with no reception.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Icon(
                          Icons.swipe_left,
                          size: 32,
                          color: Theme.of(context).disabledColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Browse events to add them',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                return ResponsiveLayout(
                  mobile: _buildMobileList(context, state.events),
                  tablet: _buildTabletGrid(context, state.events),
                  desktop: _buildDesktopGrid(context, state.events),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileList(BuildContext context, List events) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Dismissible(
          key: Key(event.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 32,
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Remove from Watchlist?'),
                content: Text('Remove "${event.title}" from your watchlist?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Remove'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            context.read<WatchlistBloc>().add(
                  RemoveFromWatchlistEvent(event.id),
                );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Removed "${event.title}"'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    context.read<WatchlistBloc>().add(
                          AddToWatchlistEvent(event),
                        );
                  },
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: EventCard(event: event),
          ),
        );
      },
    );
  }

  Widget _buildTabletGrid(BuildContext context, List events) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return EventCard(event: events[index]);
      },
    );
  }

  Widget _buildDesktopGrid(BuildContext context, List events) {
    final columns = ResponsiveUtils.getGridColumns(context);

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 1.3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return EventCard(event: events[index]);
      },
    );
  }
}
