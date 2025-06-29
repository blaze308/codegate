import 'event_segment.dart';
import 'vendor.dart';

class Event {
  final String? id; // Optional as it will be assigned by Firebase
  final String title;
  final DateTime date;
  final String venue;
  final String description;
  final List<EventSegment> segments;
  final String hostId;
  final String dresscode;
  final List<Vendor>? vendors; // Optional list of credited vendors

  Event({
    this.id, // No longer required
    required this.title,
    required this.date,
    required this.venue,
    required this.description,
    required this.segments,
    required this.hostId,
    required this.dresscode,
    this.vendors,
  });

  // Create a copy of this Event with an optional new ID
  Event copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? venue,
    String? description,
    List<EventSegment>? segments,
    String? hostId,
    String? dresscode,
    List<Vendor>? vendors,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      venue: venue ?? this.venue,
      description: description ?? this.description,
      segments: segments ?? this.segments,
      hostId: hostId ?? this.hostId,
      dresscode: dresscode ?? this.dresscode,
      vendors: vendors ?? this.vendors,
    );
  }
}
