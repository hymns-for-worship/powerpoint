import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../extensions/index.dart';
import 'color.dart';

class StackSlide extends ColorSlide {
  StackSlide({
    required super.color,
    required super.name,
    required this.children,
  });

  final List<StackItem> children;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color.toHex(leadingHashSign: false),
      'children': children.map((item) => item.toJson()).toList(),
    };
  }
}

abstract class StackItem {
  Map<String, dynamic> toJson();
  Widget build(BuildContext context);
}

class StackText extends StackItem {
  StackText({
    required this.text,
    required this.style,
    this.y,
    this.x,
  });

  final String text;
  final String? x, y;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
        fontSize: 18,
        color: style.color!.withOpacity(0.67),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'text_color': style.color!.toHex(leadingHashSign: false),
      'text_size': style.fontSize,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
    };
  }
}

class StackImage extends StackItem {
  StackImage({
    required this.bytes,
    required this.fit,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final BoxFit fit;
  final String? x, y;
  final String? width, height;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: MemoryImage(bytes),
      fit: fit,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'fit': describeEnum(fit),
      'data': base64.encode(bytes),
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
    };
  }
}
