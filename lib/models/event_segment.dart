class EventSegment {
  final String id;
  final String eventDetail;
  final String performedBy;
  final int durationMinutes;
  final DateTime startTime;

  EventSegment({
    required this.id,
    required this.eventDetail,
    required this.performedBy,
    required this.durationMinutes,
    required this.startTime,
  });
}
