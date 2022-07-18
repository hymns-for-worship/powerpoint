import 'dart:convert';

import 'package:file_utils/file_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mustache_template/mustache_template.dart';
import 'package:url_launcher/url_launcher.dart';

import '../assets/generate.dart';
import '../classes/index.dart';
import '../extensions/color.dart';
import '../extensions/index.dart';

extension SlidesExportUtils on SlidesState {
  Future<void> toPowerPoint(BuildContext context,
      {String title = 'untitled',
      LayoutOptions layout = LayoutOptions.LAYOUT_16x9}) async {
    final template = Template(GENERATE_TEMPLATE);
    final p = defaultTargetPlatform;
    final isMobile =
        !kIsWeb && (p == TargetPlatform.iOS || p == TargetPlatform.android);
    final sb = StringBuffer();
    for (final result in slides.flatten) {
      String color = '000000';
      if (result is ColorSlide) {
        color = result.color.toHex(leadingHashSign: false);
      }
      sb.writeln('  slide = pptx.addSlide()');
      if (result is TextSlide) {
        sb.writeln('  slide.addText("${result.text}", {');
        sb.writeln('    x: "${result.x}", y: "${result.y}",');
        sb.writeln('    color: "$color",');
        sb.writeln('  });');
      } else if (result is ImageSlide) {
        sb.writeln('  slide.background = {');
        sb.writeln('    data: "image/png;base64,${result.bytes}",');
        sb.writeln('    color: "$color",');
        sb.writeln('  };');
      } else if (result is ColorSlide) {
        sb.writeln('  slide.background = {');
        sb.writeln('    color: "$color",');
        sb.writeln('  };');
      }
    }
    final output = template.renderString({
      'title': title,
      'slides': sb.toString(),
      'mobile': isMobile,
      'layout': describeEnum(layout),
    });
    final bytes = Uint8List.fromList(output.codeUnits);
    const filename = 'generate.html';
    // ignore: use_build_context_synchronously
    final path = await saveBinaryFile(context, bytes, filename, share: false);
    if (isMobile) {
      final controller = HeadlessInAppWebView(
        initialData: InAppWebViewInitialData(data: output),
        onWebViewCreated: (controller) {
          controller.addJavaScriptHandler(
            handlerName: "ping",
            callback: (payload) async {
              if (payload.isNotEmpty) {
                final data = payload.first;
                final bytes = base64.decode(data);
                final filename = 'presentations/$title.pptx';
                await saveBinaryFile(context, bytes, filename);
              }
            },
          );
        },
      );
      await controller.run();
    } else {
      await launchUrl(Uri.parse('file://$path'));
    }
  }
}
