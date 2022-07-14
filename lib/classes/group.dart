import 'base.dart';

class SlideGroup extends BaseSlide {
  SlideGroup({
    required this.children,
    required super.name,
  });

  final List<BaseSlide> children;

  int get total {
    var value = 0;
    for (var slide in children) {
      if (slide is SlideGroup) {
        value += slide.total;
      } else {
        value += 1;
      }
    }
    return value;
  }

  List<BaseSlide> get flatten {
    var value = <BaseSlide>[];
    for (var slide in children) {
      if (slide is SlideGroup) {
        value.addAll(slide.flatten);
      } else {
        value.add(slide);
      }
    }
    return value;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'children': children.map((slide) => slide.toJson()).toList(),
    };
  }
}
