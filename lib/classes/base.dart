abstract class BaseSlide {
  BaseSlide({
    required this.name,
  });

  final String name;

  final Map<String, dynamic> data = {};

  Map<String, dynamic> toJson();
}
