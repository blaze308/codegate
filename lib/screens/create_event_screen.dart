import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../models/event_segment.dart';
import '../models/vendor.dart';
import 'event_completion_screen.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _venueController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dresscodeController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<EventSegment> _segments = [];
  final List<Vendor> _vendors = [];

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _descriptionController.dispose();
    _dresscodeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addSegment() {
    final eventDetailController = TextEditingController();
    final performedByController = TextEditingController();
    final durationController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Event Segment'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: eventDetailController,
                    decoration: const InputDecoration(
                      labelText: 'Event Detail',
                      hintText: 'e.g., Wedding Ceremony',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: performedByController,
                    decoration: const InputDecoration(
                      labelText: 'Performed By',
                      hintText: 'e.g., Officiant Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                      hintText: 'e.g., 60',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Start Time'),
                    subtitle: Text(selectedTime.format(context)),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        selectedTime = picked;
                        (context as Element).markNeedsBuild();
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (eventDetailController.text.isEmpty ||
                      performedByController.text.isEmpty ||
                      durationController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final duration = int.tryParse(durationController.text);
                  if (duration == null || duration <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid duration'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Create DateTime from selected date and time
                  final startTime = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );

                  // Check if the start time is valid
                  if (startTime.isBefore(DateTime.now())) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Start time cannot be in the past'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Check for overlaps with existing segments
                  final endTime = startTime.add(Duration(minutes: duration));
                  final hasOverlap = _segments.any((segment) {
                    final segmentEndTime = segment.startTime.add(
                      Duration(minutes: segment.durationMinutes),
                    );
                    return (startTime.isBefore(segmentEndTime) &&
                        endTime.isAfter(segment.startTime));
                  });

                  if (hasOverlap) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'This time slot overlaps with another segment',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final segment = EventSegment(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    eventDetail: eventDetailController.text,
                    performedBy: performedByController.text,
                    durationMinutes: duration,
                    startTime: startTime,
                  );

                  setState(() {
                    _segments.add(segment);
                    // Sort segments by start time
                    _segments.sort(
                      (a, b) => a.startTime.compareTo(b.startTime),
                    );
                  });

                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _addVendor() {
    final nameController = TextEditingController();
    final serviceTypeController = TextEditingController();
    final contactNumberController = TextEditingController();
    final emailController = TextEditingController();
    final websiteController = TextEditingController();
    final instagramController = TextEditingController();
    final facebookController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Vendor'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Vendor Name',
                      hintText: 'e.g., Elegant Flowers',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: serviceTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Service Type',
                      hintText: 'e.g., Florist',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contactNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Number (Optional)',
                      hintText: 'e.g., +1 234 567 8900',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email (Optional)',
                      hintText: 'e.g., contact@elegantflowers.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: websiteController,
                    decoration: const InputDecoration(
                      labelText: 'Website (Optional)',
                      hintText: 'e.g., www.elegantflowers.com',
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: instagramController,
                    decoration: const InputDecoration(
                      labelText: 'Instagram Handle (Optional)',
                      hintText: 'e.g., @elegantflowers',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: facebookController,
                    decoration: const InputDecoration(
                      labelText: 'Facebook Page (Optional)',
                      hintText: 'e.g., ElegantFlowers',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      serviceTypeController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Vendor name and service type are required',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final socialMedia = <String, String>{};
                  if (instagramController.text.isNotEmpty) {
                    socialMedia['instagram'] = instagramController.text;
                  }
                  if (facebookController.text.isNotEmpty) {
                    socialMedia['facebook'] = facebookController.text;
                  }

                  final vendor = Vendor(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    serviceType: serviceTypeController.text,
                    contactNumber:
                        contactNumberController.text.isNotEmpty
                            ? contactNumberController.text
                            : null,
                    email:
                        emailController.text.isNotEmpty
                            ? emailController.text
                            : null,
                    website:
                        websiteController.text.isNotEmpty
                            ? websiteController.text
                            : null,
                    socialMedia: socialMedia.isNotEmpty ? socialMedia : null,
                  );

                  setState(() {
                    _vendors.add(vendor);
                    // Sort vendors by name
                    _vendors.sort((a, b) => a.name.compareTo(b.name));
                  });

                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _editSegment(EventSegment segment, int index) {
    final eventDetailController = TextEditingController(
      text: segment.eventDetail,
    );
    final performedByController = TextEditingController(
      text: segment.performedBy,
    );
    final durationController = TextEditingController(
      text: segment.durationMinutes.toString(),
    );
    TimeOfDay selectedTime = TimeOfDay(
      hour: segment.startTime.hour,
      minute: segment.startTime.minute,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Event Segment'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: eventDetailController,
                    decoration: const InputDecoration(
                      labelText: 'Event Detail',
                      hintText: 'e.g., Wedding Ceremony',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: performedByController,
                    decoration: const InputDecoration(
                      labelText: 'Performed By',
                      hintText: 'e.g., Pastor John',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                      hintText: 'e.g., 60',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  StatefulBuilder(
                    builder:
                        (context, setState) => InkWell(
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setState(() {
                                selectedTime = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Start Time',
                            ),
                            child: Text(selectedTime.format(context)),
                          ),
                        ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (eventDetailController.text.isEmpty ||
                      performedByController.text.isEmpty ||
                      durationController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final duration = int.tryParse(durationController.text);
                  if (duration == null || duration <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid duration'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Create DateTime from selected date and time
                  final startTime = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );

                  final updatedSegment = EventSegment(
                    id: segment.id,
                    eventDetail: eventDetailController.text,
                    performedBy: performedByController.text,
                    durationMinutes: duration,
                    startTime: startTime,
                  );

                  setState(() {
                    _segments[index] = updatedSegment;
                    // Sort segments by start time
                    _segments.sort(
                      (a, b) => a.startTime.compareTo(b.startTime),
                    );
                  });

                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _editVendor(Vendor vendor, int index) {
    final nameController = TextEditingController(text: vendor.name);
    final serviceTypeController = TextEditingController(
      text: vendor.serviceType,
    );
    final contactNumberController = TextEditingController(
      text: vendor.contactNumber ?? '',
    );
    final emailController = TextEditingController(text: vendor.email ?? '');
    final websiteController = TextEditingController(text: vendor.website ?? '');
    final instagramController = TextEditingController(
      text: vendor.socialMedia?['instagram'] ?? '',
    );
    final facebookController = TextEditingController(
      text: vendor.socialMedia?['facebook'] ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Vendor'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Vendor Name',
                      hintText: 'e.g., Elegant Flowers',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: serviceTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Service Type',
                      hintText: 'e.g., Florist',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contactNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Number (Optional)',
                      hintText: 'e.g., +1 234 567 8900',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email (Optional)',
                      hintText: 'e.g., contact@elegantflowers.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: websiteController,
                    decoration: const InputDecoration(
                      labelText: 'Website (Optional)',
                      hintText: 'e.g., www.elegantflowers.com',
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: instagramController,
                    decoration: const InputDecoration(
                      labelText: 'Instagram Handle (Optional)',
                      hintText: 'e.g., @elegantflowers',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: facebookController,
                    decoration: const InputDecoration(
                      labelText: 'Facebook Page (Optional)',
                      hintText: 'e.g., ElegantFlowers',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      serviceTypeController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Vendor name and service type are required',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final socialMedia = <String, String>{};
                  if (instagramController.text.isNotEmpty) {
                    socialMedia['instagram'] = instagramController.text;
                  }
                  if (facebookController.text.isNotEmpty) {
                    socialMedia['facebook'] = facebookController.text;
                  }

                  final updatedVendor = Vendor(
                    id: vendor.id,
                    name: nameController.text,
                    serviceType: serviceTypeController.text,
                    contactNumber:
                        contactNumberController.text.isNotEmpty
                            ? contactNumberController.text
                            : null,
                    email:
                        emailController.text.isNotEmpty
                            ? emailController.text
                            : null,
                    website:
                        websiteController.text.isNotEmpty
                            ? websiteController.text
                            : null,
                    socialMedia: socialMedia.isNotEmpty ? socialMedia : null,
                  );

                  setState(() {
                    _vendors[index] = updatedVendor;
                    // Sort vendors by name
                    _vendors.sort((a, b) => a.name.compareTo(b.name));
                  });

                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _createEvent() {
    if (!_formKey.currentState!.validate()) return;

    if (_segments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one segment to the schedule'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final event = Event(
      title: _titleController.text,
      date: _selectedDate,
      venue: _venueController.text,
      description: _descriptionController.text,
      dresscode: _dresscodeController.text,
      segments: _segments,
      vendors: _vendors,
      hostId: Random().nextInt(1000000).toString(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventCompletionScreen(event: event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                    prefixIcon: Icon(Icons.event),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an event title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date Picker
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Event Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _venueController,
                  decoration: const InputDecoration(
                    labelText: 'Venue',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a venue';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _dresscodeController,
                  decoration: const InputDecoration(
                    labelText: 'Dress Code (Optional)',
                    prefixIcon: Icon(Icons.checkroom),
                  ),
                ),
                const SizedBox(height: 24),

                // Segments Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Event Schedule',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      onPressed: _addSegment,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                if (_segments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No segments added yet'),
                  ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _segments.length,
                  itemBuilder: (context, index) {
                    final segment = _segments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(segment.eventDetail),
                        subtitle: Text(
                          '${DateFormat.jm().format(segment.startTime)} - ${segment.performedBy}\n'
                          'Duration: ${segment.durationMinutes} minutes',
                        ),
                        isThreeLine: true,
                        onTap: () => _editSegment(segment, index),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() {
                              _segments.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Vendors Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vendors',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      onPressed: _addVendor,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                if (_vendors.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No vendors added yet'),
                  ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _vendors.length,
                  itemBuilder: (context, index) {
                    final vendor = _vendors[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(vendor.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vendor.serviceType),
                            if (vendor.contactNumber != null)
                              Text('📞 ${vendor.contactNumber}'),
                            if (vendor.email != null)
                              Text('✉️ ${vendor.email}'),
                            if (vendor.website != null)
                              Text('🌐 ${vendor.website}'),
                            if (vendor.socialMedia != null) ...[
                              if (vendor.socialMedia!['instagram'] != null)
                                Text('📸 ${vendor.socialMedia!['instagram']}'),
                              if (vendor.socialMedia!['facebook'] != null)
                                Text('👥 ${vendor.socialMedia!['facebook']}'),
                            ],
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () => _editVendor(vendor, index),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() {
                              _vendors.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            _segments.isEmpty
                ? null
                : _createEvent, // Disable button if no segments
        icon: const Icon(Icons.check),
        label: const Text('Create Event'),
        tooltip:
            _segments.isEmpty
                ? 'Add at least one segment to create event'
                : 'Create Event',
      ),
    );
  }
}
