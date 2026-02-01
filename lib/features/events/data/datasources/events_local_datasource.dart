import 'dart:convert';
import 'package:hive/hive.dart';

import '../../domain/entities/event.dart';

/// Local data source for events using Hive
/// Supports SQLite on Windows/Mobile and IndexedDB on Web
class EventsLocalDatasource {
  final Box _box;
  static const String _eventsKey = 'cached_events';
  static const String _lastUpdatedKey = 'last_updated';
  static const String _metadataKey = 'metadata';

  EventsLocalDatasource(this._box);

  /// Get cached events
  Future<List<MotorcycleEvent>> getCachedEvents() async {
    try {
      final jsonList = _box.get(_eventsKey);
      if (jsonList == null) return [];

      final List<dynamic> decoded = json.decode(jsonList as String);
      return decoded
          .map((item) => MotorcycleEvent.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Cache events
  Future<void> cacheEvents(List<MotorcycleEvent> events) async {
    final jsonList = json.encode(events.map((e) => e.toJson()).toList());
    await _box.put(_eventsKey, jsonList);
    await _box.put(_lastUpdatedKey, DateTime.now().toIso8601String());
  }

  /// Get last update timestamp
  Future<DateTime?> getLastUpdated() async {
    final timestamp = _box.get(_lastUpdatedKey);
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp as String);
  }

  /// Check if cache is valid
  Future<bool> isCacheValid(Duration maxAge) async {
    final lastUpdated = await getLastUpdated();
    if (lastUpdated == null) return false;
    return DateTime.now().difference(lastUpdated) < maxAge;
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _box.delete(_eventsKey);
    await _box.delete(_lastUpdatedKey);
  }

  /// Store metadata about scraping results
  Future<void> storeMetadata(Map<String, dynamic> metadata) async {
    await _box.put(_metadataKey, json.encode(metadata));
  }

  /// Get scraping metadata
  Future<Map<String, dynamic>?> getMetadata() async {
    final data = _box.get(_metadataKey);
    if (data == null) return null;
    return json.decode(data as String) as Map<String, dynamic>;
  }
}
