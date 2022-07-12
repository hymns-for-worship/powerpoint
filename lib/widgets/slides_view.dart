import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../classes/base.dart';
import '../classes/color.dart';
import '../classes/group.dart';
import '../classes/image.dart';
import '../classes/state.dart';
import '../classes/text.dart';

class SlidesView extends StatefulWidget {
  const SlidesView({
    Key? key,
    required this.slides,
    required this.builder,
    required this.onChange,
    required this.onEnd,
    this.title,
    this.actions = const [],
  }) : super(key: key);

  final Widget? title;
  final List<Widget> actions;
  final List<BaseSlide> slides;
  final Widget Function(SlidesState state, Widget child) builder;
  final Future Function(SlidesState state) onChange;
  final Future Function() onEnd;

  @override
  State<SlidesView> createState() => _SlidesViewState();
}

class _SlidesViewState extends State<SlidesView> {
  late final state = ValueNotifier(SlidesState(
    slides: widget.slides,
    currentIndex: 0,
    groupIndex: 0,
    showControls: true,
    fullScreen: false,
  ));
  final focusNode = FocusNode(skipTraversal: true);
  Timer? controlsTimer;
  Timer? updateDebounce;
  bool loading = false;

  void showControls() {
    final current = state.value;
    focusNode.requestFocus();
    updateState(current.copyWith(showControls: true));
    controlsTimer?.cancel();
    controlsTimer = Timer(const Duration(seconds: 4), () {
      updateState(current.copyWith(showControls: false));
    });
  }

  Future<void> next(BuildContext context, [bool group = true]) async {
    final state = this.state.value;
    final idx = max(0, min(state.slides.length - 1, state.currentIndex));
    final current = state.slides[idx];

    if (group && current is SlideGroup) {
      final groupSlides = current.children;
      final groupIndex = max(0, min(groupSlides.length - 1, state.groupIndex));

      final groupSlide = getSlide(idx, groupIndex + 1);
      if (groupSlide != null) {
        await updateState(state.copyWith(
          currentIndex: idx,
          groupIndex: groupIndex + 1,
        ));
        return;
      }
    }

    final targetSlide = getSlide(idx + 1, 0);
    if (targetSlide != null) {
      await updateState(state.copyWith(
        currentIndex: idx + 1,
        groupIndex: 0,
      ));
      return;
    }

    end(context);
  }

  Future<void> previous(BuildContext context, [bool group = true]) async {
    if (loading) return;
    final state = this.state.value;
    final idx = max(0, min(state.slides.length - 1, state.currentIndex));
    final current = state.slides[idx];

    if (group && current is SlideGroup) {
      final groupSlides = current.children;
      final groupIndex = max(0, min(groupSlides.length - 1, state.groupIndex));

      final groupSlide = getSlide(idx, groupIndex - 1);
      if (groupSlide != null) {
        await updateState(state.copyWith(
          currentIndex: idx,
          groupIndex: groupIndex - 1,
        ));
        return;
      }
    }

    final targetSlide = getSlide(idx - 1, null);
    if (targetSlide != null) {
      if (group && targetSlide is SlideGroup) {
        await updateState(state.copyWith(
          currentIndex: idx - 1,
          groupIndex: targetSlide.children.length - 1,
        ));
        return;
      }

      await updateState(state.copyWith(
        currentIndex: idx - 1,
        groupIndex: 0,
      ));
      return;
    }

    // Start of presentation
  }

  Future<void> preload(BuildContext context) async {
    if (loading) return;
    final state = this.state.value;
    final idx = max(0, min(state.slides.length - 1, state.currentIndex));

    // Check next
    if (idx < state.slides.length - 1) {
      final nextSlide = state.slides[idx + 1];
      if (nextSlide is ImageSlide) {
        await nextSlide.preload(context);
      }
      // Check if group
      if (nextSlide is SlideGroup) {
        final groupSlides = nextSlide.children;
        final groupIndex =
            max(0, min(groupSlides.length - 1, state.groupIndex));

        if (groupIndex < groupSlides.length - 1) {
          final nextGroupSlide = groupSlides[groupIndex + 1];
          if (nextGroupSlide is ImageSlide) {
            await nextGroupSlide.preload(context);
          }
        }
      }
    }

    // Check previous
    if (idx > 0) {
      final prevSlide = state.slides[idx - 1];
      if (prevSlide is ImageSlide) {
        await prevSlide.preload(context);
      }
      // Check if group
      if (prevSlide is SlideGroup) {
        final groupSlides = prevSlide.children;
        final groupIndex =
            max(0, min(groupSlides.length - 1, state.groupIndex));

        if (groupIndex > 0) {
          final prevGroupSlide = groupSlides[groupIndex - 1];
          if (prevGroupSlide is ImageSlide) {
            await prevGroupSlide.preload(context);
          }
        }
      }
    }
  }

  Future<void> end(BuildContext context) async {
    await widget.onEnd();
  }

  Future<void> updateState(SlidesState value) async {
    state.value = value;
    loading = true;
    updateDebounce?.cancel();
    updateDebounce = Timer(const Duration(milliseconds: 10), () async {
      await widget.onChange(value).catchError((error) {});
    });
    loading = false;
  }

  Future<void> setSlideState(int index, int groupIndex) async {
    debugPrint('state: $index-$groupIndex');
    await updateState(state.value.copyWith(
      groupIndex: groupIndex,
      currentIndex: index,
    ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showControls();
      setSlideState(0, 0);
    });
  }

  BaseSlide? getSlide(int index, int? groupIndex) {
    try {
      final item = widget.slides[index];
      if (item is SlideGroup && groupIndex != null) {
        return item.children[groupIndex];
      }
      return item;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SlidesState>(
      valueListenable: state,
      builder: (context, state, child) {
        final current = buildCurrent(context, state);
        const bgColor = Colors.black;
        final fgColor = loading
            ? Colors.white.withOpacity(0.20)
            : Colors.white.withOpacity(0.50);
        return LayoutBuilder(builder: (context, dimens) {
          final slideControls = <Widget>[
            IconButton(
              tooltip: 'Previous group',
              icon: const Icon(Icons.navigate_before),
              onPressed: loading ? null : () => previous(context, false),
            ),
            IconButton(
              tooltip: 'Previous slide',
              icon: const Icon(Icons.skip_previous),
              onPressed: loading ? null : () => previous(context),
            ),
            IconButton(
              tooltip: 'Enter fullscreen',
              icon: const Icon(Icons.fullscreen),
              onPressed: loading
                  ? null
                  : () => updateState(state.copyWith(fullScreen: true)),
            ),
            IconButton(
              tooltip: 'Next slide',
              icon: const Icon(Icons.skip_next),
              onPressed: loading ? null : () => next(context),
            ),
            IconButton(
              tooltip: 'Next group',
              icon: const Icon(Icons.navigate_next),
              onPressed: loading ? null : () => next(context, false),
            ),
          ];
          final isMobile = dimens.maxWidth < 600;
          return Scaffold(
            appBar: state.fullScreen
                ? null
                : AppBar(
                    title: widget.title,
                    actions: [
                      ...widget.actions,
                      if (!isMobile) ...slideControls,
                    ],
                    bottom: !isMobile
                        ? null
                        : PreferredSize(
                            preferredSize: const Size.fromHeight(48),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: slideControls,
                            ),
                          ),
                  ),
            body: Container(
              color: bgColor,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onLongPress: () => updateState(state.copyWith(
                  fullScreen: !state.fullScreen,
                )),
                onTapUp: (details) {
                  final width = dimens.maxWidth;
                  final x = details.localPosition.dx;
                  const ratio = 2 / 3;
                  if (x >= width * ratio) {
                    next(context);
                  } else {
                    previous(context);
                  }
                  showControls();
                },
                child: KeyboardListener(
                  focusNode: focusNode,
                  autofocus: true,
                  onKeyEvent: (event) {
                    if (event is KeyUpEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                          event.logicalKey == LogicalKeyboardKey.space ||
                          event.logicalKey == LogicalKeyboardKey.keyD) {
                        next(context);
                      }
                      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                          event.logicalKey == LogicalKeyboardKey.keyA) {
                        previous(context);
                      }
                      if (event.logicalKey == LogicalKeyboardKey.keyC) {
                        showControls();
                      }
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(child: widget.builder(state, current)),
                      AnimatedPositioned(
                        duration: kThemeAnimationDuration,
                        bottom: state.showControls ? 10 : -100,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Previous group',
                              icon: const Icon(Icons.navigate_before),
                              onPressed: loading
                                  ? null
                                  : () => previous(context, false),
                              color: fgColor,
                            ),
                            IconButton(
                              tooltip: 'Previous slide',
                              icon: const Icon(Icons.skip_previous),
                              onPressed:
                                  loading ? null : () => previous(context),
                              color: fgColor,
                            ),
                            IconButton(
                              tooltip:
                                  '${state.fullScreen ? 'Exit' : 'Enter'} fullscreen',
                              icon: Icon(state.fullScreen
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen),
                              onPressed: () => updateState(state.copyWith(
                                fullScreen: !state.fullScreen,
                              )),
                              color: fgColor,
                            ),
                            IconButton(
                              tooltip: 'Next slide',
                              icon: const Icon(Icons.skip_next),
                              onPressed: loading ? null : () => next(context),
                              color: fgColor,
                            ),
                            IconButton(
                              tooltip: 'Next group',
                              icon: const Icon(Icons.navigate_next),
                              onPressed:
                                  loading ? null : () => next(context, false),
                              color: fgColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget buildCurrent(BuildContext context, SlidesState state) {
    if (state.slides.isEmpty) {
      return const Center(child: Text('No slides found'));
    }
    if (state.currentIndex < 0 || state.currentIndex >= state.slides.length) {
      return const Center(child: Text('Slide not found'));
    }
    final current = state.slides[state.currentIndex];
    return renderSlide(context, state, current);
  }

  Widget renderSlide(BuildContext context, SlidesState state, BaseSlide slide) {
    if (slide is ImageSlide) {
      return slide.build(context);
    }
    if (slide is TextSlide) {
      return slide.build(context);
    }
    if (slide is ColorSlide) {
      return slide.build(context);
    }
    if (slide is SlideGroup) {
      final child = slide.children[state.groupIndex];
      return renderSlide(context, state, child);
    }
    return const Center(child: Text('Slide not supported'));
  }
}
