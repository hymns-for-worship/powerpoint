import 'package:flutter/material.dart';

import '../extensions/index.dart';
import 'color.dart';

class TextSlide extends ColorSlide {
  TextSlide({
    required super.color,
    required super.name,
    required this.text,
    required this.style,
    this.x = "2%",
    this.y = "95%",
  });

  final String text;
  final String x;
  final String y;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                text,
                style: style.copyWith(
                  fontSize: 18,
                  color: style.color!.withOpacity(0.67),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'name': name,
      'color': color.toHex(leadingHashSign: false),
      'textColor': style.color!.toHex(leadingHashSign: false),
      'textSize': style.fontSize,
      'x': x,
      'y': y,
    };
  }
}
