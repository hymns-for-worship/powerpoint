// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../assets/generate.dart';
import '../classes/index.dart';
import '../extensions/index.dart';

extension SlidesExportUtils on SlidesState {
  Future<void> toPowerPoint(
    BuildContext context, {
    String title = 'untitled',
    LayoutOptions layout = LayoutOptions.LAYOUT_16x9,
  }) async {
    // Check for script tag
    final root = html.document.body!;

    final script =
        root.querySelector('script[id="pptx-export"]') as html.ScriptElement?;
    if (script == null) {
      // Add script tag
      final script = html.ScriptElement();
      script.id = 'pptx-export';
      script.type = 'module';
      script.innerHtml = GENERATE_SCRIPT;
      root.append(script);
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final presJson = {
      'title': title,
      'slides': slides.flatten,
      'layout': describeEnum(layout),
    }.clone();

    html.window.dispatchEvent(html.CustomEvent(
      'generate',
      detail: presJson,
    ));
  }
}
