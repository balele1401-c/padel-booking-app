import 'package:cloud_firestore/cloud_firestore.dart';

class CourtModel {
  final String id;
  final String name;
  final String imageUrl;
  final double pricePerHour;
  final String openTime; // format: "08:00"
  final String closeTime; // format: "22:00"
  final bool isActive;
  final String? description;

  CourtModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.pricePerHour,
    required this.openTime,
    required this.closeTime,
    this.isActive = true,
    this.description,
  });

  factory CourtModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Robust parsing for pricePerHour (supports num, int, double, String)
    double priceVal = 0.0;
    final rawPrice = data['harga_per_jam'] ?? data['pricePerHour'] ?? data['harga'];
    if (rawPrice != null) {
      if (rawPrice is num) {
        priceVal = rawPrice.toDouble();
      } else if (rawPrice is String) {
        priceVal = double.tryParse(rawPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      }
    }

    // Robust parsing for isActive (supports bool, String, defaults to true if omitted)
    bool activeVal = true;
    final rawActive = data['is_active'] ?? data['isActive'] ?? data['active'];
    if (rawActive != null) {
      if (rawActive is bool) {
        activeVal = rawActive;
      } else if (rawActive is String) {
        activeVal = rawActive.toLowerCase() == 'true';
      }
    }

    final rawName = data['nama'] ?? data['name'] ?? data['nama_lapangan'] ?? 'Lapangan Padel';
    final rawImage = data['foto'] ?? data['imageUrl'] ?? data['foto_lapangan'] ?? data['image'] ?? '';
    final rawOpen = data['jam_buka'] ?? data['openTime'] ?? '08:00';
    final rawClose = data['jam_tutup'] ?? data['closeTime'] ?? '22:00';
    final rawDesc = data['deskripsi'] ?? data['description'];

    return CourtModel(
      id: doc.id,
      name: rawName.toString(),
      imageUrl: rawImage.toString(),
      pricePerHour: priceVal,
      openTime: rawOpen.toString(),
      closeTime: rawClose.toString(),
      isActive: activeVal,
      description: rawDesc?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nama': name,
      'foto': imageUrl,
      'harga_per_jam': pricePerHour,
      'jam_buka': openTime,
      'jam_tutup': closeTime,
      'is_active': isActive,
      if (description != null) 'deskripsi': description,
    };
  }

  CourtModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? pricePerHour,
    String? openTime,
    String? closeTime,
    bool? isActive,
    String? description,
  }) {
    return CourtModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
    );
  }
}
