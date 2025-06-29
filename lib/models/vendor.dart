class Vendor {
  final String id;
  final String name;
  final String serviceType; // e.g., "DJ", "Photographer", "Caterer"
  final String? contactNumber;
  final String? email;
  final Map<String, String>? socialMedia; // platform -> handle/link
  final String? website;

  Vendor({
    required this.id,
    required this.name,
    required this.serviceType,
    this.contactNumber,
    this.email,
    this.socialMedia,
    this.website,
  });

  // Helper method to create social media map
  static Map<String, String> createSocialMediaMap({
    String? instagram,
    String? facebook,
    String? twitter,
    String? tiktok,
    String? linkedin,
  }) {
    final map = <String, String>{};
    if (instagram != null) map['instagram'] = instagram;
    if (facebook != null) map['facebook'] = facebook;
    if (twitter != null) map['twitter'] = twitter;
    if (tiktok != null) map['tiktok'] = tiktok;
    if (linkedin != null) map['linkedin'] = linkedin;
    return map;
  }
}
