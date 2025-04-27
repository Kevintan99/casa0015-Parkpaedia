class Species {
  final String id;
  final String name;
  final String origin;
  final String type;
  final String imageUrl;
  final String family;
  final String description;

  Species({
    required this.id,
    required this.name,
    required this.origin,
    required this.type,
    required this.imageUrl,
    required this.family,
    required this.description,
  });

  factory Species.fromMap(Map<String, dynamic> map, String id) {
    return Species(
      id: id,
      name: map['name'] ?? '',
      origin: map['origin'] ?? '',
      type: map['type'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      family: map['family'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'origin': origin,
      'type': type,
      'imageUrl': imageUrl,
      'family': family,
      'description': description,
    };
  }
} 