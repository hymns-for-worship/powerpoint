import 'package:flutter/material.dart';

import 'base.dart';

class ColorSlide extends BaseSlide {
  ColorSlide({
    required String name,
    required this.color,
  }) : super(name: name);

  final Color color;

  Widget build(BuildContext context) {
    return Container(color: color);
  }
}
