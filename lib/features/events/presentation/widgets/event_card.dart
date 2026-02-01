import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/event.dart';
import '../../../watchlist/presentation/bloc/watchlist_bloc.dart';

/// Event card widget with high-contrast design and large touch targets
class EventCard extends StatelessWidget {
  final MotorcycleEvent event;
  final bool isCompact;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        side: BorderSide(
          color: _getCategoryColor(event.category),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap ?? () => _showEventDetails(context),
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with category and state
              Row(
                children: [
                  _buildCategoryChip(context),
                  const SizedBox(width: 8),
                  _buildStateChip(context),
                  const Spacer(),
                  _buildWatchlistButton(context),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                event.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.formattedDateRange,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.primaryDark
                            : AppTheme.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.location.isNotEmpty ? event.location : 'Location TBA',
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (!isCompact) ...[
                const SizedBox(height: 12),

                // Description
                if (event.description.isNotEmpty)
                  Text(
                    event.description,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 12),

                // Source and last updated
                Row(
                  children: [
                    Icon(
                      Icons.source,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.sourceName,
                      style: theme.textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.update,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatLastUpdated(event.lastUpdated),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getCategoryColor(event.category).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getCategoryColor(event.category),
          width: 1.5,
        ),
      ),
      child: Text(
        event.category.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _getCategoryColor(event.category),
        ),
      ),
    );
  }

  Widget _buildStateChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey,
          width: 1.5,
        ),
      ),
      child: Text(
        event.state.code,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildWatchlistButton(BuildContext context) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        final isInWatchlist = state is WatchlistLoaded &&
            state.isInWatchlist(event.id);

        return SizedBox(
          width: AppConstants.minTouchTarget,
          height: AppConstants.minTouchTarget,
          child: IconButton(
            onPressed: () {
              if (isInWatchlist) {
                context.read<WatchlistBloc>().add(
                      RemoveFromWatchlistEvent(event.id),
                    );
                _showSnackBar(context, 'Removed from watchlist');
              } else {
                context.read<WatchlistBloc>().add(
                      AddToWatchlistEvent(event),
                    );
                _showSnackBar(context, 'Added to watchlist');
              }
            },
            icon: Icon(
              isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
              color: isInWatchlist ? AppTheme.primaryLight : null,
              size: 28,
            ),
            tooltip: isInWatchlist ? 'Remove from watchlist' : 'Add to watchlist',
          ),
        );
      },
    );
  }

  Color _getCategoryColor(EventCategory category) {
    switch (category) {
      case EventCategory.swapMeet:
        return const Color(0xFF4CAF50); // Green
      case EventCategory.rally:
        return const Color(0xFF2196F3); // Blue
      case EventCategory.track:
        return const Color(0xFFE91E63); // Pink
      case EventCategory.show:
        return const Color(0xFF9C27B0); // Purple
      case EventCategory.ride:
        return const Color(0xFF00BCD4); // Cyan
      case EventCategory.racing:
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF607D8B); // Blue Grey
    }
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEventDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: EventDetailsSheet(
            event: event,
            scrollController: scrollController,
          ),
        ),
      ),
    );
  }
}

/// Event details sheet
class EventDetailsSheet extends StatelessWidget {
  final MotorcycleEvent event;
  final ScrollController scrollController;

  const EventDetailsSheet({
    super.key,
    required this.event,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        // Handle indicator
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Title
        Text(
          event.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Category and State
        Row(
          children: [
            _buildInfoChip(context, event.category.displayName, Icons.category),
            const SizedBox(width: 12),
            _buildInfoChip(context, event.state.fullName, Icons.map),
          ],
        ),
        const SizedBox(height: 20),

        // Date
        _buildInfoRow(
          context,
          Icons.calendar_today,
          'Date',
          event.formattedDateRange,
        ),
        const SizedBox(height: 12),

        // Location
        _buildInfoRow(
          context,
          Icons.location_on,
          'Location',
          event.location.isNotEmpty ? event.location : 'Location TBA',
        ),
        const SizedBox(height: 12),

        // Price
        if (event.price != null || event.isFree)
          Column(
            children: [
              _buildInfoRow(
                context,
                Icons.attach_money,
                'Price',
                event.isFree ? 'FREE' : '\$${event.price!.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 12),
            ],
          ),

        // Organizer
        if (event.organizer != null)
          Column(
            children: [
              _buildInfoRow(
                context,
                Icons.group,
                'Organizer',
                event.organizer!,
              ),
              const SizedBox(height: 12),
            ],
          ),

        const Divider(height: 32),

        // Description
        if (event.description.isNotEmpty) ...[
          Text(
            'Description',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.description,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
        ],

        // Source info
        Row(
          children: [
            const Icon(Icons.source, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              'Source: ${event.sourceName}',
              style: theme.textTheme.bodySmall,
            ),
            const Spacer(),
            Text(
              'Last updated: ${_formatDate(event.lastUpdated)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: AppConstants.minTouchTarget,
                child: OutlinedButton.icon(
                  onPressed: () => _openSourceUrl(context),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('View Source'),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: BlocBuilder<WatchlistBloc, WatchlistState>(
                builder: (context, state) {
                  final isInWatchlist = state is WatchlistLoaded &&
                      state.isInWatchlist(event.id);

                  return SizedBox(
                    height: AppConstants.minTouchTarget,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (isInWatchlist) {
                          context.read<WatchlistBloc>().add(
                                RemoveFromWatchlistEvent(event.id),
                              );
                        } else {
                          context.read<WatchlistBloc>().add(
                                AddToWatchlistEvent(event),
                              );
                        }
                      },
                      icon: Icon(
                        isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                      ),
                      label: Text(
                        isInWatchlist ? 'Saved' : 'Save',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _openSourceUrl(BuildContext context) async {
    final uri = Uri.tryParse(event.sourceUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }
}
