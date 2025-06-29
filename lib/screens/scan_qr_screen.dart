import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../models/event_qr_data.dart';
import 'event_details_screen.dart';
import 'dart:developer' as dev;
import 'dart:async';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen>
    with WidgetsBindingObserver {
  late final MobileScannerController controller;
  bool _isProcessing = false;
  final bool _showScanner = false;
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      returnImage: true,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    controller.dispose();
    _nameController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(controller.start());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        unawaited(controller.stop());
        break;
    }
  }

  Future<void> _processQRData(String? rawValue) async {
    if (rawValue == null) {
      _showError('Could not read QR code');
      return;
    }

    try {
      final eventData = EventQRData.fromJson(rawValue);
      dev.log('QR data parsed successfully', name: 'QRScanner');

      if (!mounted) return;

      if (_showScanner) {
        await controller.stop();
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => EventDetailsScreen(
                  eventData: eventData,
                  guestName: _nameController.text.trim(),
                ),
          ),
        );
      }
    } catch (e) {
      dev.log('Error parsing QR data', name: 'QRScanner', error: e.toString());
      _showError('Invalid QR code format');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1440,
        maxHeight: 1440,
      );

      if (image == null) return;
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: SizedBox(
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Processing image...'),
                  ],
                ),
              ),
            ),
      );

      try {
        final result = await controller.analyzeImage(image.path);

        if (!mounted) return;
        Navigator.of(context).pop(); // Close loading dialog

        if (result == null || result.barcodes.isEmpty) {
          _showError('No QR code found in the image');
          return;
        }

        final barcode = result.barcodes[0];
        if (barcode.rawValue == null) {
          _showError('Could not read QR code data');
          return;
        }

        await _processQRData(barcode.rawValue);
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
        }
        dev.log(
          'Error processing gallery image',
          name: 'QRScanner',
          error: e.toString(),
        );
        _showError(
          'Error processing image. Please try scanning directly with camera.',
        );
      }
    } catch (e) {
      dev.log('Error picking image', name: 'QRScanner', error: e.toString());
      _showError('Error selecting image from gallery');
    }
  }

  void _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      if (capture.barcodes.isEmpty) return;

      final barcode = capture.barcodes[0];
      if (barcode.rawValue == null) {
        _showError('Could not read QR code data');
        return;
      }

      await _processQRData(barcode.rawValue);
    } catch (e) {
      dev.log('Error handling barcode', name: 'QRScanner', error: e.toString());
      _showError('Error reading QR code');
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _pickImageFromGallery,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: controller,
              onDetect: _handleBarcode,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Your Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
