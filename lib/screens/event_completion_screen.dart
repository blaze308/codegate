import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:gallery_saver/gallery_saver.dart';
import '../models/event.dart';
import '../models/event_qr_data.dart';
import '../services/firebase_service.dart';
import 'dart:developer' as dev;
import 'package:share_plus/share_plus.dart';

class EventCompletionScreen extends StatefulWidget {
  final Event event;

  const EventCompletionScreen({super.key, required this.event});

  @override
  State<EventCompletionScreen> createState() => _EventCompletionScreenState();
}

class _EventCompletionScreenState extends State<EventCompletionScreen> {
  final GlobalKey _qrKey = GlobalKey();
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  String? _errorMessage;
  late String _qrDataString;
  late Event _event;

  @override
  void initState() {
    super.initState();
    dev.log('EventCompletionScreen initialized', name: 'EventCompletionScreen');
    _event = widget.event;
    _storeEventData();
  }

  Future<void> _storeEventData() async {
    dev.log('Starting event data storage', name: 'EventStorage');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Store event data in Firebase first
      dev.log('Storing event data in Firebase', name: 'EventStorage');
      final eventId = await _firebaseService.storeEventData(
        _event,
        '',
      ); // Empty QR string initially

      // Update the event with the generated ID
      setState(() {
        _event = _event.copyWith(id: eventId);
        // Now generate QR data with the Firebase ID
        _qrDataString = EventQRData.fromEvent(_event).toJson();
      });

      // Update the stored event with the QR data
      await _firebaseService.updateEvent(eventId, {'qrData': _qrDataString});

      dev.log(
        'Event data stored successfully with ID: $eventId',
        name: 'EventStorage',
      );
    } catch (e, stackTrace) {
      dev.log(
        'Error storing event data',
        name: 'EventStorage',
        error: e.toString(),
        stackTrace: stackTrace,
      );
      setState(() {
        _errorMessage = 'Failed to store event data: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _shareQRCode() async {
    dev.log('Starting QR code sharing', name: 'QRShare');
    try {
      // Create a QR painting
      final qrPainting = QrPainter(
        data: _qrDataString,
        version: QrVersions.auto,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
      );

      // Convert to image
      final qrImage = await qrPainting.toImage(300);
      final byteData = await qrImage.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to generate QR image for sharing');
      }

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qr_code.png').create();
      await file.writeAsBytes(byteData.buffer.asUint8List());
      dev.log(
        'QR image saved to temporary file: ${file.path}',
        name: 'QRShare',
      );

      await SharePlus.instance.share(
        ShareParams(
          text: 'QR Code for ${_event.title}',
          files: [XFile(file.path)],
        ),
      );
      dev.log('QR code shared successfully', name: 'QRShare');
    } catch (e, stackTrace) {
      dev.log(
        'Error sharing QR code',
        name: 'QRShare',
        error: e.toString(),
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share QR code: $e')));
      }
    }
  }

  Future<void> _downloadQRCode() async {
    try {
      dev.log('Starting QR code download', name: 'QRDownload');

      // Check platform support
      if (!Platform.isAndroid && !Platform.isIOS) {
        throw UnsupportedError(
          'QR code download is only supported on Android and iOS',
        );
      }

      // Create a QR painting
      final qrPainting = QrPainter(
        data: _qrDataString,
        version: QrVersions.auto,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
      );

      // Convert to image
      final qrImage = await qrPainting.toImage(300);
      final byteData = await qrImage.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to generate QR image');
      }

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qr_code.png').create();
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // Save to gallery
      final success = await GallerySaver.saveImage(file.path);

      if (success ?? false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR Code saved to gallery')),
          );
        }
        dev.log('QR code saved to gallery successfully', name: 'QRDownload');
      } else {
        throw Exception('Failed to save to gallery');
      }
    } catch (e) {
      dev.log(
        'Error downloading QR code',
        name: 'QRDownload',
        error: e.toString(),
      );
      if (mounted) {
        String errorMessage = 'Failed to download QR code';
        if (e is UnsupportedError) {
          errorMessage =
              e.message ?? 'QR code download is not supported on this platform';
        } else if (e.toString().contains('MissingPluginException')) {
          errorMessage = 'Gallery saving is not supported on this platform';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    dev.log('Building EventCompletionScreen', name: 'EventCompletionScreen');

    return Scaffold(
      appBar: AppBar(title: const Text('Event Created Successfully')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (_errorMessage != null) ...[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _storeEventData,
                          child: const Text('Retry'),
                        ),
                        const SizedBox(height: 20),
                      ],
                      const Text(
                        'Your event has been created!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: RepaintBoundary(
                          key: _qrKey,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: QrImageView(
                              data: _qrDataString,
                              version: QrVersions.auto,
                              size: 200.0,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _shareQRCode,
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _downloadQRCode,
                            icon: const Icon(Icons.download),
                            label: const Text('Download'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _event.title,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Date: ${_event.date.toString().split(' ')[0]}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'Venue: ${_event.venue}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'Dress Code: ${_event.dresscode}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  @override
  void dispose() {
    dev.log('EventCompletionScreen disposed', name: 'EventCompletionScreen');
    super.dispose();
  }
}
