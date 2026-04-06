class SlideModel {
  final String image;
  final String greeting;
  final String title;

  const SlideModel({
    required this.image,
    required this.greeting,
    required this.title,
  });

  /// Factory to build from a JSON map (API-ready)
  factory SlideModel.fromJson(Map<String, dynamic> json) {
    return SlideModel(
      image: json['image'] as String,
      greeting: json['greeting'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'image': image,
        'greeting': greeting,
        'title': title,
      };
}