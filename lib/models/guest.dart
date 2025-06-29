class Guest {
  final String id;
  final String name;
  final String? email;
  final String? tableNumber;
  final String rsvpStatus; // confirmed, pending, declined
  final String qrCode;
  final String? dietaryRestrictions;

  Guest({
    required this.id,
    required this.name,
    this.email,
    this.tableNumber,
    required this.rsvpStatus,
    required this.qrCode,
    this.dietaryRestrictions,
  });
}
