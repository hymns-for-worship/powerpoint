import 'package:flutter/material.dart';

import '../classes/index.dart';

class RenderSlide extends StatelessWidget {
  const RenderSlide({
    super.key,
    required this.state,
    required this.slide,
  });

  final SlidesState state;
  final BaseSlide slide;

  @override
  Widget build(BuildContext context) {
    var base = slide;
    if (base is ImageSlide) {
      return base.build(context);
    }
    if (base is TextSlide) {
      return base.build(context);
    }
    if (base is ColorSlide) {
      return base.build(context);
    }
    if (base is SlideGroup) {
      BaseSlide base = slide;
      while (base is SlideGroup) {
        base = base.children.first;
      }
      return RenderSlide(
        state: state,
        slide: base,
      );
    }
    return const Center(child: Text('Slide not supported'));
  }
}
