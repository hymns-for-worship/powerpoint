import 'base.dart';

class SlidesState {
  SlidesState({
    required this.slides,
    required this.currentSlide,
    required this.showControls,
    required this.fullScreen,
    required this.total,
    required this.index,
  });
  final List<BaseSlide> slides;
  final BaseSlide? currentSlide;
  final bool showControls;
  final bool fullScreen;
  int index;
  final int total;

  SlidesState copyWith({
    List<BaseSlide>? slides,
    BaseSlide? currentSlide,
    bool? showControls,
    bool? fullScreen,
    int? total,
    int? index,
  }) {
    return SlidesState(
      slides: slides ?? this.slides,
      showControls: showControls ?? this.showControls,
      fullScreen: fullScreen ?? this.fullScreen,
      total: total ?? this.total,
      currentSlide: currentSlide ?? this.currentSlide,
      index: index ?? this.index,
    );
  }
}
