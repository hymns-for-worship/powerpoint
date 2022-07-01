import 'package:flutter/material.dart';

import 'color.dart';

class TextSlide extends ColorSlide {
  TextSlide({
    required String name,
    required Color color,
    required this.text,
    required this.style,
  }) : super(name: name, color: color);

  final String text;
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
}
