import 'package:flutter/material.dart';

import '../extensions/index.dart';
import 'base.dart';

class ColorSlide extends BaseSlide {
  ColorSlide({
    required this.color,
    required super.name,
  });

  final Color color;

  Widget build(BuildContext context) {
    return Container(color: color);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color.toHex(leadingHashSign: false),
    };
  }
}
