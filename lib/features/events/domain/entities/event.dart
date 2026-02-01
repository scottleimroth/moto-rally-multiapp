import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

/// Represents a motorcycle event/rally
class MotorcycleEvent extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String location;
  final AustralianState state;
  final EventCategory category;
  final String? imageUrl;
  final String sourceUrl;
  final String sourceName;
  final DateTime lastUpdated;
  final String? organizer;
  final String? contactInfo;
  final double? price;
  final bool isFree;

  const MotorcycleEvent({
    required this.id,
    required this.title,
    required this.description,
    this.startDate,
    this.endDate,
    required this.location,
    required this.state,
    required this.category,
    this.imageUrl,
    required this.sourceUrl,
    required this.sourceName,
    required this.lastUpdated,
    this.organizer,
    this.contactInfo,
    this.price,
    this.isFree = false,
  });

  /// Check if the event is upcoming
  bool get isUpcoming {
    if (startDate == null) return true;
    return startDate!.isAfter(DateTime.now().subtract(const Duration(days: 1)));
  }

  /// Format date range for display
  String get formattedDateRange {
    if (startDate == null) return 'Date TBA';

    final start = _formatDate(startDate!);
    if (endDate == null || endDate == startDate) {
      return start;
    }
    return '$start - ${_formatDate(endDate!)}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Create a copy with updated fields
  MotorcycleEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    AustralianState? state,
    EventCategory? category,
    String? imageUrl,
    String? sourceUrl,
    String? sourceName,
    DateTime? lastUpdated,
    String? organizer,
    String? contactInfo,
    double? price,
    bool? isFree,
  }) {
    return MotorcycleEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      state: state ?? this.state,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      sourceName: sourceName ?? this.sourceName,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      organizer: organizer ?? this.organizer,
      contactInfo: contactInfo ?? this.contactInfo,
      price: price ?? this.price,
      isFree: isFree ?? this.isFree,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'location': location,
      'state': state.code,
      'category': category.id,
      'imageUrl': imageUrl,
      'sourceUrl': sourceUrl,
      'sourceName': sourceName,
      'lastUpdated': lastUpdated.toIso8601String(),
      'organizer': organizer,
      'contactInfo': contactInfo,
      'price': price,
      'isFree': isFree,
    };
  }

  /// Create from JSON map
  factory MotorcycleEvent.fromJson(Map<String, dynamic> json) {
    return MotorcycleEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
      location: json['location'] as String? ?? '',
      state: AustralianState.fromString(json['state'] as String? ?? 'ALL'),
      category: _categoryFromId(json['category'] as String? ?? 'other'),
      imageUrl: json['imageUrl'] as String?,
      sourceUrl: json['sourceUrl'] as String? ?? '',
      sourceName: json['sourceName'] as String? ?? '',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
      organizer: json['organizer'] as String?,
      contactInfo: json['contactInfo'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      isFree: json['isFree'] as bool? ?? false,
    );
  }

  static EventCategory _categoryFromId(String id) {
    return EventCategory.values.firstWhere(
      (cat) => cat.id == id,
      orElse: () => EventCategory.other,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startDate,
        endDate,
        location,
        state,
        category,
        imageUrl,
        sourceUrl,
        sourceName,
        lastUpdated,
        organizer,
        contactInfo,
        price,
        isFree,
      ];
}
