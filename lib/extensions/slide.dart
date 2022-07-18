import '../classes/index.dart';

extension SlideGroupUtils on BaseSlide {
  BaseSlide? visit(bool Function(BaseSlide) visitor) {
    var match = visitor(this);
    if (match) return this;
    if (this is SlideGroup) {
      for (var slide in (this as SlideGroup).children) {
        var match = slide.visit(visitor);
        if (match != null) return match;
      }
    }
    return null;
  }
}
