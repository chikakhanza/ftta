class Facility {
  final int id;
  final String name;
  final String icon;
  final bool isAvailable;
  final String? description;

  Facility({
    required this.id,
    required this.name,
    required this.icon,
    this.isAvailable = true,
    this.description,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      isAvailable: json['is_available'] ?? true,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'is_available': isAvailable,
      'description': description,
    };
  }
} 