import 'event.dart';
import 'event_segment.dart';
import 'vendor.dart';

class Host {
  final String id;
  final String name;
  final String contactNumber;
  final String email;
  final String role; // bride, groom, or organizer

  Host({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.email,
    required this.role,
  });

  // Create basic event (first form)
  Event createBasicEvent({
    required String title,
    required DateTime date,
    required String venue,
    required String description,
    required String dresscode,
  }) {
    return Event(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      date: date,
      venue: venue,
      description: description,
      segments: [],
      hostId: id,
      dresscode: dresscode,
      vendors: [], // Initialize empty vendors list
    );
  }

  // Create an event segment (for second form)
  EventSegment createEventSegment({
    required String eventDetail,
    required String performedBy,
    required int durationMinutes,
    required DateTime startTime,
  }) {
    return EventSegment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      eventDetail: eventDetail,
      performedBy: performedBy,
      durationMinutes: durationMinutes,
      startTime: startTime,
    );
  }

  // Add segments to event (after second form)
  Event addSegmentsToEvent(Event event, List<EventSegment> newSegments) {
    return Event(
      id: event.id,
      title: event.title,
      date: event.date,
      venue: event.venue,
      description: event.description,
      segments: [...event.segments, ...newSegments],
      hostId: event.hostId,
      dresscode: event.dresscode,
      vendors: event.vendors,
    );
  }

  // Create a vendor credit
  Vendor createVendor({
    required String name,
    required String serviceType,
    String? contactNumber,
    String? email,
    String? website,
    String? instagram,
    String? facebook,
    String? twitter,
    String? tiktok,
    String? linkedin,
  }) {
    return Vendor(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      serviceType: serviceType,
      contactNumber: contactNumber,
      email: email,
      website: website,
      socialMedia: Vendor.createSocialMediaMap(
        instagram: instagram,
        facebook: facebook,
        twitter: twitter,
        tiktok: tiktok,
        linkedin: linkedin,
      ),
    );
  }

  // Add vendors to event
  Event addVendorsToEvent(Event event, List<Vendor> newVendors) {
    final currentVendors = event.vendors ?? [];
    return Event(
      id: event.id,
      title: event.title,
      date: event.date,
      venue: event.venue,
      description: event.description,
      segments: event.segments,
      hostId: event.hostId,
      dresscode: event.dresscode,
      vendors: [...currentVendors, ...newVendors],
    );
  }

  // Edit a vendor's details
  Event editVendor(
    Event event,
    String vendorId, {
    String? name,
    String? serviceType,
    String? contactNumber,
    String? email,
    String? website,
    String? instagram,
    String? facebook,
    String? twitter,
    String? tiktok,
    String? linkedin,
  }) {
    final currentVendors = event.vendors ?? [];
    final updatedVendors =
        currentVendors.map((vendor) {
          if (vendor.id == vendorId) {
            // Create new social media map if needed
            final Map<String, String>? newSocialMedia =
                instagram != null ||
                        facebook != null ||
                        twitter != null ||
                        tiktok != null ||
                        linkedin != null
                    ? Vendor.createSocialMediaMap(
                      instagram: instagram ?? vendor.socialMedia?['instagram'],
                      facebook: facebook ?? vendor.socialMedia?['facebook'],
                      twitter: twitter ?? vendor.socialMedia?['twitter'],
                      tiktok: tiktok ?? vendor.socialMedia?['tiktok'],
                      linkedin: linkedin ?? vendor.socialMedia?['linkedin'],
                    )
                    : vendor.socialMedia;

            return Vendor(
              id: vendor.id,
              name: name ?? vendor.name,
              serviceType: serviceType ?? vendor.serviceType,
              contactNumber: contactNumber ?? vendor.contactNumber,
              email: email ?? vendor.email,
              website: website ?? vendor.website,
              socialMedia: newSocialMedia,
            );
          }
          return vendor;
        }).toList();

    return Event(
      id: event.id,
      title: event.title,
      date: event.date,
      venue: event.venue,
      description: event.description,
      segments: event.segments,
      hostId: event.hostId,
      dresscode: event.dresscode,
      vendors: updatedVendors,
    );
  }

  // Remove a vendor from the event
  Event removeVendor(Event event, String vendorId) {
    final currentVendors = event.vendors ?? [];
    final updatedVendors =
        currentVendors.where((v) => v.id != vendorId).toList();

    return Event(
      id: event.id,
      title: event.title,
      date: event.date,
      venue: event.venue,
      description: event.description,
      segments: event.segments,
      hostId: event.hostId,
      dresscode: event.dresscode,
      vendors: updatedVendors,
    );
  }

  // Remove multiple vendors from the event
  Event removeVendors(Event event, List<String> vendorIds) {
    final currentVendors = event.vendors ?? [];
    final updatedVendors =
        currentVendors.where((v) => !vendorIds.contains(v.id)).toList();

    return Event(
      id: event.id,
      title: event.title,
      date: event.date,
      venue: event.venue,
      description: event.description,
      segments: event.segments,
      hostId: event.hostId,
      dresscode: event.dresscode,
      vendors: updatedVendors,
    );
  }

  // Get a vendor by ID
  Vendor? getVendor(Event event, String vendorId) {
    final vendors = event.vendors ?? [];
    return vendors.where((v) => v.id == vendorId).firstOrNull;
  }
}
