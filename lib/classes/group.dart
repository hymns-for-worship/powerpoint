import 'base.dart';

class SlideGroup extends BaseSlide {
  SlideGroup({
    required this.children,
    required String name,
  }) : super(name: name);

  final List<BaseSlide> children;
}
