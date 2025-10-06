// Simple model used across screens + API
class Accommodation {
  final String id;
  final String title;       // e.g. "Cozy Studio in Downtown"
  final String address;
  final String bhk;         // "1 BHK" | "2 BHK" | ...
  final bool available;     // true = Available, false = Need
  final int? pricePerMonth; // optional
  final String description; // optional
  final List<String> photoUrls;

  Accommodation({
    required this.id,
    required this.title,
    required this.address,
    required this.bhk,
    required this.available,
    this.pricePerMonth,
    this.description = '',
    this.photoUrls = const [],
  });

  factory Accommodation.fromJson(Map<String, dynamic> j) => Accommodation(
        id: j['id'] as String,
        title: j['title'] as String,
        address: j['address'] as String,
        bhk: j['bhk'] as String,
        available: j['available'] as bool,
        pricePerMonth: j['pricePerMonth'] == null ? null : (j['pricePerMonth'] as num).toInt(),
        description: (j['description'] ?? '') as String,
        photoUrls: (j['photoUrls'] as List?)?.cast<String>() ?? const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'address': address,
        'bhk': bhk,
        'available': available,
        'pricePerMonth': pricePerMonth,
        'description': description,
        'photoUrls': photoUrls,
      };
}
