import 'package:cloud_firestore/cloud_firestore.dart';

class Species {
  final String id;
  final String name;
  final String origin;
  final String type;
  final String imageUrl;
  final String family;

  Species({
    required this.id,
    required this.name,
    required this.origin,
    required this.type,
    required this.imageUrl,
    required this.family,
  });

  factory Species.fromMap(Map<String, dynamic> map, String id) {
    return Species(
      id: id,
      name: map['name'] ?? '',
      origin: map['origin'] ?? '',
      type: map['type'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      family: map['family'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'origin': origin,
      'type': type,
      'imageUrl': imageUrl,
      'family': family,
    };
  }

  factory Species.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Species(
      id: doc.id,
      name: data['name'] ?? '',
      family: data['family'] ?? '',
      type: data['type'] ?? '',
      origin: data['origin'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
} 