import 'dart:convert';
import 'package:hive/hive.dart';

import '../../../events/domain/entities/event.dart';

/// Local data source for watchlist using Hive
/// Supports SQLite on Windows/Mobile and IndexedDB on Web
class WatchlistLocalDatasource {
  final Box _box;
  static const String _watchlistKey = 'watchlist_events';

  WatchlistLocalDatasource(this._box);

  /// Get all watchlist events
  Future<List<MotorcycleEvent>> getWatchlist() async {
    try {
      final jsonList = _box.get(_watchlistKey);
      if (jsonList == null) return [];

      final List<dynamic> decoded = json.decode(jsonList as String);
      return decoded
          .map((item) => MotorcycleEvent.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Add event to watchlist
  Future<void> addToWatchlist(MotorcycleEvent event) async {
    final current = await getWatchlist();

    // Check if already exists
    if (current.any((e) => e.id == event.id)) return;

    current.add(event);
    await _saveWatchlist(current);
  }

  /// Remove event from watchlist
  Future<void> removeFromWatchlist(String eventId) async {
    final current = await getWatchlist();
    current.removeWhere((e) => e.id == eventId);
    await _saveWatchlist(current);
  }

  /// Check if event is in watchlist
  Future<bool> isInWatchlist(String eventId) async {
    final current = await getWatchlist();
    return current.any((e) => e.id == eventId);
  }

  /// Clear entire watchlist
  Future<void> clearWatchlist() async {
    await _box.delete(_watchlistKey);
  }

  /// Get watchlist count
  Future<int> getWatchlistCount() async {
    final current = await getWatchlist();
    return current.length;
  }

  /// Save watchlist to storage
  Future<void> _saveWatchlist(List<MotorcycleEvent> events) async {
    final jsonList = json.encode(events.map((e) => e.toJson()).toList());
    await _box.put(_watchlistKey, jsonList);
  }
}
