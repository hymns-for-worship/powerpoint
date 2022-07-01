import 'base.dart';

class SlidesState {
  SlidesState({
    required this.slides,
    required this.currentIndex,
    required this.groupIndex,
    required this.showControls,
    required this.fullScreen,
  });
  final List<BaseSlide> slides;
  final int currentIndex;
  final int groupIndex;
  final bool showControls;
  final bool fullScreen;

  SlidesState copyWith({
    List<BaseSlide>? slides,
    int? currentIndex,
    int? groupIndex,
    bool? showControls,
    bool? fullScreen,
  }) {
    return SlidesState(
      slides: slides ?? this.slides,
      currentIndex: currentIndex ?? this.currentIndex,
      groupIndex: groupIndex ?? this.groupIndex,
      showControls: showControls ?? this.showControls,
      fullScreen: fullScreen ?? this.fullScreen,
    );
  }
}
