class CityModel {
  final String image;
  final String name;
  final int visitCount;

  const CityModel({
    required this.image,
    required this.name,
    required this.visitCount,
  });

  /// API-ready: build from JSON
  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      image: json['image'] as String,
      name: json['name'] as String,
      visitCount: json['visit_count'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'image': image,
        'name': name,
        'visit_count': visitCount,
      };

  /// Human-friendly visit label
  String get visitsLabel => '$visitCount Visites';
}