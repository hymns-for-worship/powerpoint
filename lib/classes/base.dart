abstract class BaseSlide {
  BaseSlide({
    required this.name,
  });

  final String name;

  Map<String, dynamic> toJson();
}
