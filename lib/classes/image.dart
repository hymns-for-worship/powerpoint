import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../extensions/index.dart';
import 'color.dart';

class ImageSlide extends ColorSlide {
  ImageSlide({
    required super.color,
    required super.name,
    required this.bytes,
  });

  final Uint8List bytes;
  late final provider = MemoryImage(bytes);
  final BoxFit fit = BoxFit.fill;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Image(image: provider, fit: fit),
    );
  }

  Future<void> preload(BuildContext context) {
    return precacheImage(provider, context);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'fit': describeEnum(fit),
      'name': name,
      'data': base64.encode(bytes),
      'color': color.toHex(leadingHashSign: false),
    };
  }
}
