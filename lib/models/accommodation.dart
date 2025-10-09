// lib/models/accommodation.dart
class Accommodation {
  final String? id;
  final String? title;
  final String? address;
  final int? bhk;
  final String? type; // 'AVAILABLE' | 'NEEDED'
  final String? price; // keep as string to match backend
  final String? userName;
  final String? description;
  final List<String> amenities;

  Accommodation({
    this.id,
    this.title,
    this.address,
    this.bhk,
    this.type,
    this.price,
    this.userName,
    this.description,
    this.amenities = const [],
  });

  factory Accommodation.fromJson(Map<String, dynamic> j) {
    List<String> am = [];
    final rawAm = j['amenities'];
    if (rawAm is List) {
      am = rawAm.whereType<String>().toList();
    } else if (rawAm is String) {
      am = rawAm.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return Accommodation(
      id: j['id'] ?? j['PK'],
      title: j['title'],
      address: j['address'],
      bhk: (j['bhk'] is int) ? j['bhk'] : int.tryParse('${j['bhk']}'),
      type: (j['type'] as String?)?.toUpperCase(),
      price: j['price']?.toString(),
      userName: j['userName'],
      description: j['description'],
      amenities: am,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'address': address,
        'bhk': bhk,
        'type': type,
        'price': price,
        'userName': userName,
        'description': description,
        'amenities': amenities,
      };
}
