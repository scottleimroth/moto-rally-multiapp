import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../bloc/events_bloc.dart';

/// Filter bar widget for filtering events by state and category
class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        if (state is! EventsLoaded) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSearchBar(context, state),
              ),
              const SizedBox(height: 12),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildStateFilter(context, state),
                    const SizedBox(width: 12),
                    _buildCategoryFilter(context, state),
                    if (_hasActiveFilters(state)) ...[
                      const SizedBox(width: 12),
                      _buildClearFiltersButton(context),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, EventsLoaded state) {
    return SizedBox(
      height: AppConstants.minTouchTarget,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search events...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: state.searchQuery?.isNotEmpty == true
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    context.read<EventsBloc>().add(
                          const FilterEventsEvent(searchQuery: ''),
                        );
                  },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          context.read<EventsBloc>().add(
                FilterEventsEvent(searchQuery: value),
              );
        },
      ),
    );
  }

  Widget _buildStateFilter(BuildContext context, EventsLoaded state) {
    return SizedBox(
      height: AppConstants.minTouchTarget,
      child: PopupMenuButton<AustralianState>(
        initialValue: state.selectedState,
        onSelected: (selectedState) {
          context.read<EventsBloc>().add(
                FilterEventsEvent(state: selectedState),
              );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: state.selectedState != null && state.selectedState != AustralianState.all
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: state.selectedState != null && state.selectedState != AustralianState.all
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade400,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.map, size: 20),
              const SizedBox(width: 8),
              Text(
                state.selectedState?.code ?? 'All States',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 24),
            ],
          ),
        ),
        itemBuilder: (context) => [
          for (final australianState in AustralianState.values)
            PopupMenuItem<AustralianState>(
              value: australianState,
              height: AppConstants.minTouchTarget,
              child: Text(
                australianState == AustralianState.all
                    ? 'All States'
                    : '${australianState.code} - ${australianState.fullName}',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, EventsLoaded state) {
    return SizedBox(
      height: AppConstants.minTouchTarget,
      child: PopupMenuButton<EventCategory>(
        initialValue: state.selectedCategory,
        onSelected: (category) {
          context.read<EventsBloc>().add(
                FilterEventsEvent(category: category),
              );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: state.selectedCategory != null && state.selectedCategory != EventCategory.all
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: state.selectedCategory != null && state.selectedCategory != EventCategory.all
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade400,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.category, size: 20),
              const SizedBox(width: 8),
              Text(
                state.selectedCategory?.displayName ?? 'All Categories',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 24),
            ],
          ),
        ),
        itemBuilder: (context) => [
          for (final category in EventCategory.values)
            PopupMenuItem<EventCategory>(
              value: category,
              height: AppConstants.minTouchTarget,
              child: Text(category.displayName),
            ),
        ],
      ),
    );
  }

  Widget _buildClearFiltersButton(BuildContext context) {
    return SizedBox(
      height: AppConstants.minTouchTarget,
      child: TextButton.icon(
        onPressed: () {
          context.read<EventsBloc>().add(ClearFiltersEvent());
        },
        icon: const Icon(Icons.clear_all),
        label: const Text('Clear'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.red,
        ),
      ),
    );
  }

  bool _hasActiveFilters(EventsLoaded state) {
    return (state.selectedState != null && state.selectedState != AustralianState.all) ||
        (state.selectedCategory != null && state.selectedCategory != EventCategory.all) ||
        (state.searchQuery?.isNotEmpty == true);
  }
}
