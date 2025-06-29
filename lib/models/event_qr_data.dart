import 'dart:convert';
import 'event.dart';
import 'event_segment.dart';
import 'vendor.dart';
import 'qr_exceptions.dart';

/// A model that represents the event data that will be encoded in the QR code
/// This is a simplified version of the event data that's safe to share publicly
class EventQRData {
  final String? id;
  final String title;
  final DateTime date;
  final String venue;
  final String? description;
  final String? dresscode;
  final List<EventSegment> segments;
  final List<Vendor>? vendors;

  EventQRData({
    this.id,
    required this.title,
    required this.date,
    required this.venue,
    this.description,
    this.dresscode,
    required this.segments,
    this.vendors,
  });

  // Factory method to create EventQRData from Event
  factory EventQRData.fromEvent(Event event) {
    return EventQRData(
      id: event.id,
      title: event.title,
      date: event.date,
      venue: event.venue,
      description: event.description,
      dresscode: event.dresscode,
      segments: List<EventSegment>.from(event.segments)
        ..sort((a, b) => a.startTime.compareTo(b.startTime)),
      vendors: event.vendors,
    );
  }

  // Validate the event data
  void validate() {
    final errors = <String, String>{};

    if (title.isEmpty) errors['title'] = 'Title cannot be empty';
    if (venue.isEmpty) errors['venue'] = 'Venue cannot be empty';

    // Validate date
    if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      errors['date'] = 'Event date cannot be in the past';
    }

    // Validate schedule
    if (segments.isEmpty) {
      errors['segments'] = 'Schedule must have at least one event';
    } else {
      // First ensure segments are sorted by start time
      segments.sort((a, b) => a.startTime.compareTo(b.startTime));

      // Then check for overlaps and invalid times
      for (var i = 0; i < segments.length; i++) {
        final segment = segments[i];
        final segmentEndTime = segment.startTime.add(
          Duration(minutes: segment.durationMinutes),
        );

        // Check if segment starts before event date
        if (segment.startTime.isBefore(
          DateTime(date.year, date.month, date.day),
        )) {
          errors['segments_$i'] =
              'Event segment cannot start before event date';
          continue;
        }

        // Check if this segment overlaps with the next one
        if (i < segments.length - 1) {
          final nextSegment = segments[i + 1];
          if (segmentEndTime.isAfter(nextSegment.startTime)) {
            errors['segments_$i'] = 'Event segments cannot overlap';
          }
        }
      }
    }

    // Validate vendors if present
    if (vendors != null && vendors!.isNotEmpty) {
      for (var i = 0; i < vendors!.length; i++) {
        final vendor = vendors![i];

        // Check required vendor fields
        if (vendor.name.isEmpty) {
          errors['vendor_${i}_name'] = 'Vendor name cannot be empty';
        }
        if (vendor.serviceType.isEmpty) {
          errors['vendor_${i}_service'] = 'Vendor service type cannot be empty';
        }

        // Validate email if provided
        if (vendor.email != null && vendor.email!.isNotEmpty) {
          if (!_isValidEmail(vendor.email!)) {
            errors['vendor_${i}_email'] = 'Invalid email format';
          }
        }
      }
    }

    if (errors.isNotEmpty) {
      throw QRValidationException('Event data validation failed', errors);
    }
  }

  // Convert to JSON string for QR code
  String toJson() {
    try {
      validate();

      final Map<String, dynamic> json = {
        'title': title,
        'date': date.toIso8601String(),
        'venue': venue,
        'description': description,
        'dresscode': dresscode,
        'segments':
            segments
                .map(
                  (segment) => {
                    'eventDetail': segment.eventDetail,
                    'performedBy': segment.performedBy,
                    'durationMinutes': segment.durationMinutes,
                    'startTime': segment.startTime.toIso8601String(),
                  },
                )
                .toList(),
        'vendors':
            vendors
                ?.map(
                  (vendor) => {
                    'name': vendor.name,
                    'serviceType': vendor.serviceType,
                    'contactNumber': vendor.contactNumber,
                    'email': vendor.email,
                    'website': vendor.website,
                    'socialMedia': vendor.socialMedia,
                  },
                )
                .toList(),
      };

      // Only include ID if it exists
      if (id != null) {
        json['id'] = id;
      }

      return jsonEncode(json);
    } catch (e) {
      if (e is QRValidationException) {
        rethrow;
      }
      throw QRGenerationException('Failed to generate QR code data', e);
    }
  }

  // Create from QR string
  factory EventQRData.fromJson(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);

      // Validate required fields in JSON
      final requiredFields = [
        'title',
        'date',
        'venue',
        'segments',
      ]; // ID no longer required
      final missingFields = requiredFields.where(
        (field) => !json.containsKey(field),
      );

      if (missingFields.isNotEmpty) {
        throw QRParsingException(
          'Missing required fields: ${missingFields.join(", ")}',
        );
      }

      return EventQRData(
        id: json['id'], // Will be null if not present
        title: json['title'],
        date: DateTime.parse(json['date']),
        venue: json['venue'],
        description: json['description'],
        dresscode: json['dresscode'],
        segments:
            (json['segments'] as List)
                .map(
                  (segment) => EventSegment(
                    id:
                        segment['id'] ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    eventDetail: segment['eventDetail'],
                    performedBy: segment['performedBy'],
                    durationMinutes: segment['durationMinutes'],
                    startTime: DateTime.parse(segment['startTime']),
                  ),
                )
                .toList(),
        vendors:
            json['vendors'] != null
                ? (json['vendors'] as List)
                    .map(
                      (vendor) => Vendor(
                        id:
                            vendor['id'] ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        name: vendor['name'],
                        serviceType: vendor['serviceType'],
                        contactNumber: vendor['contactNumber'],
                        email: vendor['email'],
                        website: vendor['website'],
                        socialMedia: vendor['socialMedia'],
                      ),
                    )
                    .toList()
                : null,
      );
    } catch (e) {
      if (e is QRValidationException) {
        rethrow;
      }
      throw QRParsingException('Failed to parse QR code data', e);
    }
  }

  // Helper method to validate email format
  static bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }
}

/// Simplified event segment info for QR code
class EventSegmentInfo {
  final String eventDetail;
  final String performedBy;
  final int durationMinutes;
  final DateTime startTime;

  EventSegmentInfo({
    required this.eventDetail,
    required this.performedBy,
    required this.durationMinutes,
    required this.startTime,
  });

  factory EventSegmentInfo.fromEventSegment(EventSegment segment) {
    return EventSegmentInfo(
      eventDetail: segment.eventDetail,
      performedBy: segment.performedBy,
      durationMinutes: segment.durationMinutes,
      startTime: segment.startTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventDetail': eventDetail,
      'performedBy': performedBy,
      'durationMinutes': durationMinutes,
      'startTime': startTime.toIso8601String(),
    };
  }

  factory EventSegmentInfo.fromJson(Map<String, dynamic> json) {
    return EventSegmentInfo(
      eventDetail: json['eventDetail'],
      performedBy: json['performedBy'],
      durationMinutes: json['durationMinutes'],
      startTime: DateTime.parse(json['startTime']),
    );
  }
}

/// Simplified vendor info for QR code
class VendorInfo {
  final String name;
  final String serviceType;
  final String? contactNumber;
  final String? email;
  final String? website;
  final Map<String, String>? socialMedia;

  VendorInfo({
    required this.name,
    required this.serviceType,
    this.contactNumber,
    this.email,
    this.website,
    this.socialMedia,
  });

  factory VendorInfo.fromVendor(Vendor vendor) {
    return VendorInfo(
      name: vendor.name,
      serviceType: vendor.serviceType,
      contactNumber: vendor.contactNumber,
      email: vendor.email,
      website: vendor.website,
      socialMedia: vendor.socialMedia,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'serviceType': serviceType,
      'contactNumber': contactNumber,
      'email': email,
      'website': website,
      'socialMedia': socialMedia,
    };
  }

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    return VendorInfo(
      name: json['name'],
      serviceType: json['serviceType'],
      contactNumber: json['contactNumber'],
      email: json['email'],
      website: json['website'],
      socialMedia:
          json['socialMedia'] != null
              ? Map<String, String>.from(json['socialMedia'])
              : null,
    );
  }
}
