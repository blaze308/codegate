import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import 'dart:developer' as dev;

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Store event details in Firestore
  Future<String> storeEventData(Event event, String qrDataString) async {
    try {
      dev.log('Starting to store event data', name: 'FirebaseService');

      // Create a map of the event data for Firestore
      final eventData = {
        'title': event.title,
        'date': event.date.toIso8601String(),
        'venue': event.venue,
        'description': event.description,
        'dresscode': event.dresscode,
        'hostId': event.hostId,
        'qrData': qrDataString, // Store the QR data string instead of URL
        'createdAt': FieldValue.serverTimestamp(),
        'schedule':
            event.segments
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
            event.vendors
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
                .toList() ??
            [],
      };

      dev.log('Storing event data in Firestore', name: 'FirebaseService');
      // Let Firestore generate the ID
      final docRef = await _firestore.collection('events').add(eventData);
      dev.log(
        'Event data stored successfully with ID: ${docRef.id}',
        name: 'FirebaseService',
      );
      return docRef.id;
    } catch (e) {
      dev.log(
        'Failed to store event data',
        name: 'FirebaseService',
        error: e.toString(),
      );
      throw Exception('Failed to store event data: $e');
    }
  }

  // Retrieve event data by ID
  Future<Map<String, dynamic>> getEventData(String eventId) async {
    try {
      dev.log('Retrieving event data', name: 'FirebaseService');
      final docSnapshot =
          await _firestore.collection('events').doc(eventId).get();

      if (!docSnapshot.exists) {
        throw Exception('Event not found');
      }

      final data = docSnapshot.data()!;
      return {
        'eventData': data,
        'qrData': data['qrData'], // Return the QR data string
      };
    } catch (e) {
      dev.log(
        'Failed to retrieve event data',
        name: 'FirebaseService',
        error: e.toString(),
      );
      throw Exception('Failed to retrieve event data: $e');
    }
  }

  // Get all events for a host
  Future<List<Map<String, dynamic>>> getHostEvents(String hostId) async {
    try {
      dev.log('Retrieving host events', name: 'FirebaseService');
      final querySnapshot =
          await _firestore
              .collection('events')
              .where('hostId', isEqualTo: hostId)
              .orderBy('date', descending: true)
              .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      dev.log(
        'Failed to retrieve host events',
        name: 'FirebaseService',
        error: e.toString(),
      );
      throw Exception('Failed to retrieve host events: $e');
    }
  }

  // Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      dev.log('Deleting event', name: 'FirebaseService');
      await _firestore.collection('events').doc(eventId).delete();
      dev.log('Event deleted successfully', name: 'FirebaseService');
    } catch (e) {
      dev.log(
        'Failed to delete event',
        name: 'FirebaseService',
        error: e.toString(),
      );
      throw Exception('Failed to delete event: $e');
    }
  }

  // Update event details
  Future<void> updateEvent(String eventId, Map<String, dynamic> updates) async {
    try {
      dev.log('Updating event', name: 'FirebaseService');
      await _firestore.collection('events').doc(eventId).update(updates);
      dev.log('Event updated successfully', name: 'FirebaseService');
    } catch (e) {
      dev.log(
        'Failed to update event',
        name: 'FirebaseService',
        error: e.toString(),
      );
      throw Exception('Failed to update event: $e');
    }
  }

  // Check if an event exists
  Future<bool> eventExists(String eventId) async {
    try {
      dev.log('Checking event existence', name: 'FirebaseService');
      final docSnapshot =
          await _firestore.collection('events').doc(eventId).get();
      return docSnapshot.exists;
    } catch (e) {
      dev.log(
        'Failed to check event existence',
        name: 'FirebaseService',
        error: e.toString(),
      );
      throw Exception('Failed to check event existence: $e');
    }
  }
}
