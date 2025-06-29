/// Base class for all QR code related exceptions
abstract class QRException implements Exception {
  final String message;
  final dynamic originalError;

  QRException(this.message, [this.originalError]);

  @override
  String toString() {
    if (originalError != null) {
      return '$message (Original error: $originalError)';
    }
    return message;
  }
}

/// Exception thrown when QR code generation fails
class QRGenerationException extends QRException {
  QRGenerationException(super.message, [super.originalError]);
}

/// Exception thrown when parsing QR code data fails
class QRParsingException extends QRException {
  QRParsingException(super.message, [super.originalError]);
}

/// Exception thrown when QR code data validation fails
class QRValidationException extends QRException {
  final Map<String, String> validationErrors;

  QRValidationException(
    String message,
    this.validationErrors, [
    dynamic originalError,
  ]) : super(message, originalError);

  @override
  String toString() {
    final errorsString = validationErrors.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
    return '${super.toString()} Validation errors: {$errorsString}';
  }
}
