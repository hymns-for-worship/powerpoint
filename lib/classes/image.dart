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

class LazyImageSlide extends ColorSlide {
  LazyImageSlide({
    required super.color,
    required super.name,
    required this.bytes,
  });

  final Future<Uint8List> bytes;
  final BoxFit fit = BoxFit.fill;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: bytes,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container(
              color: color,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          final provider = MemoryImage(snapshot.data!);
          return Container(
            color: color,
            child: Image(image: provider, fit: fit),
          );
        });
  }

  Future<void> preload(BuildContext context) async {
    final bytes = await this.bytes;
    final provider = MemoryImage(bytes);
    await precacheImage(provider, context);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'fit': describeEnum(fit),
      'name': name,
      'color': color.toHex(leadingHashSign: false),
    };
  }
}
