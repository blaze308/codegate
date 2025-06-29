import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/event_qr_data.dart';
import '../models/qr_exceptions.dart';

class QRService {
  // Generate QR code widget from event
  static Widget generateQRCode(
    Event event, {
    double size = 200.0,
    Color backgroundColor = Colors.white,
    Color foregroundColor = Colors.black,
  }) {
    try {
      final qrData = EventQRData.fromEvent(event);
      final qrString = qrData.toJson();

      return QrImageView(
        data: qrString,
        version: QrVersions.auto,
        size: size,
        backgroundColor: backgroundColor,
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: foregroundColor,
        ),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: foregroundColor,
        ),
        errorCorrectionLevel: QrErrorCorrectLevel.H, // High error correction
        errorStateBuilder: (context, error) {
          return Center(
            child: Text(
              'Error generating QR code: ${error.toString()}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        },
      );
    } catch (e) {
      // Return an error widget instead of throwing
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to generate QR code:\n${e.toString()}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  // Generate QR code data from event
  static String generateQRString(Event event) {
    try {
      final qrData = EventQRData.fromEvent(event);
      return qrData.toJson();
    } catch (e) {
      if (e is QRException) {
        rethrow;
      }
      throw QRGenerationException('Failed to generate QR code string', e);
    }
  }

  // Parse QR code data back to EventQRData
  static EventQRData parseQRString(String qrString) {
    try {
      return EventQRData.fromJson(qrString);
    } catch (e) {
      if (e is QRException) {
        rethrow;
      }
      throw QRParsingException('Failed to parse QR code data', e);
    }
  }

  // Validate QR string without parsing it completely
  static bool isValidQRString(String qrString) {
    try {
      parseQRString(qrString);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get readable error message
  static String getErrorMessage(dynamic error) {
    if (error is QRValidationException) {
      final errorList = error.validationErrors.entries
          .map((e) => '- ${e.key}: ${e.value}')
          .join('\n');
      return 'Validation Errors:\n$errorList';
    } else if (error is QRParsingException) {
      return 'Invalid QR Code: ${error.message}';
    } else if (error is QRGenerationException) {
      return 'QR Generation Failed: ${error.message}';
    }
    return 'An unexpected error occurred: $error';
  }
}
