import 'package:flutter/material.dart';

import 'color.dart';

class ImageSlide extends ColorSlide {
  ImageSlide({
    required String name,
    required Color color,
    required this.image,
  }) : super(name: name, color: color);

  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Image(
        image: image,
        fit: BoxFit.fill,
      ),
    );
  }

  Future<void> preload(BuildContext context) async {
    return precacheImage(image, context);
  }
}
