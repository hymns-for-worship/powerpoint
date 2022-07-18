import 'package:flutter/material.dart';

import '../classes/index.dart';

extension SlidesUtils on List<BaseSlide> {
  List<BaseSlide> get flatten {
    var value = <BaseSlide>[];
    for (var slide in this) {
      if (slide is SlideGroup) {
        value.addAll(slide.flatten);
      } else {
        value.add(slide);
      }
    }
    return value;
  }

  int get total => flatten.length;

  int getIndex(BaseSlide? slide) {
    if (slide == null) return -1;
    return flatten.indexOf(slide);
  }

  BaseSlide? getSlide(int index) => flatten[index];

  BaseSlide? next(int current) {
    if (current + 1 >= total) return null;
    return getSlide(current + 1);
  }

  BaseSlide? previous(int current) {
    if (current - 1 < 0) return null;
    return getSlide(current - 1);
  }

  bool get canGoNext => next(total - 1) != null;

  bool get canGoPrevious => previous(0) != null;

  BaseSlide? nextGroup(SlideGroup group) {
    final first = group.children.first;
    if (first is SlideGroup) {
      return nextGroup(first);
    } else {
      return next(getIndex(first));
    }
  }

  BaseSlide? previousGroup(SlideGroup group) {
    final first = group.children.first;
    if (first is SlideGroup) {
      return previousGroup(first);
    } else {
      return previous(getIndex(first));
    }
  }
}
