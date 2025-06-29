import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_qr_data.dart';
import '../models/event_segment.dart';
import '../models/vendor.dart';

class EventDetailsScreen extends StatelessWidget {
  final EventQRData eventData;
  final String guestName;

  const EventDetailsScreen({
    super.key,
    required this.eventData,
    required this.guestName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(eventData.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Event Header
            Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventData.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Guest Name
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Welcome, $guestName',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(eventData.date),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        eventData.venue,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  if (eventData.dresscode != null &&
                      eventData.dresscode!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.style,
                          size: 16,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dress Code: ${eventData.dresscode}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Event Schedule
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ...eventData.segments.map(
                    (segment) => _buildScheduleItem(context, segment),
                  ),
                  if (eventData.vendors != null &&
                      eventData.vendors!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Vendors',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ...eventData.vendors!.map(
                      (vendor) => _buildVendorItem(context, vendor),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(BuildContext context, EventSegment segment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  segment.eventDetail,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${segment.durationMinutes} mins',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'By ${segment.performedBy}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('h:mm a').format(segment.startTime),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorItem(BuildContext context, Vendor vendor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getVendorIcon(vendor.serviceType),
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        vendor.serviceType,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (vendor.contactNumber != null ||
                vendor.email != null ||
                vendor.website != null ||
                (vendor.socialMedia != null && vendor.socialMedia!.isNotEmpty))
              Column(
                children: [
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  if (vendor.contactNumber != null)
                    _buildContactItem(
                      context,
                      Icons.phone,
                      vendor.contactNumber!,
                    ),
                  if (vendor.email != null)
                    _buildContactItem(context, Icons.email, vendor.email!),
                  if (vendor.website != null)
                    _buildContactItem(context, Icons.language, vendor.website!),
                  if (vendor.socialMedia != null) ...[
                    if (vendor.socialMedia!['instagram'] != null)
                      _buildContactItem(
                        context,
                        Icons.camera_alt,
                        '@${vendor.socialMedia!['instagram']}',
                      ),
                    if (vendor.socialMedia!['facebook'] != null)
                      _buildContactItem(
                        context,
                        Icons.facebook,
                        vendor.socialMedia!['facebook']!,
                      ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  IconData _getVendorIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'photographer':
        return Icons.camera_alt;
      case 'florist':
        return Icons.local_florist;
      case 'catering':
        return Icons.restaurant;
      case 'music':
        return Icons.music_note;
      case 'venue':
        return Icons.location_on;
      case 'decoration':
        return Icons.celebration;
      default:
        return Icons.business;
    }
  }
}
