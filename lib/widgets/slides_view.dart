import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../assets/generate.dart';
import '../classes/index.dart';
import '../extensions/index.dart';
import '../pptx_export/pptx_export.dart';
import 'render_slide.dart';

class SlidesView extends StatefulWidget {
  const SlidesView({
    Key? key,
    required this.slides,
    this.builder,
    this.onChange,
    required this.onEnd,
    this.title,
    this.options = const ExportOptions(),
    this.actions = const [],
    this.background = Colors.black,
  }) : super(key: key);

  final Widget? title;
  final List<Widget> actions;
  final List<BaseSlide> slides;
  final Widget Function(SlidesState state, Widget child)? builder;
  final FutureOr Function(SlidesState state)? onChange;
  final FutureOr Function() onEnd;
  final ExportOptions options;
  final Color background;

  @override
  State<SlidesView> createState() => _SlidesViewState();
}

class _SlidesViewState extends State<SlidesView> {
  late final state = ValueNotifier(SlidesState(
    slides: widget.slides,
    currentSlide: null,
    showControls: true,
    fullScreen: false,
    total: widget.slides.total,
    index: 0,
  ));
  final focusNode = FocusNode(skipTraversal: true);
  Timer? controlsTimer;
  Timer? updateDebounce;
  bool loading = false;
  late List<BaseSlide> slides = widget.slides.flatten();

  void showControls() {
    final current = state.value;
    focusNode.requestFocus();
    updateState(current.copyWith(showControls: true));
    controlsTimer?.cancel();
    controlsTimer = Timer(const Duration(seconds: 4), () {
      updateState(state.value.copyWith(showControls: false));
    });
  }

  Future<void> next(BuildContext context, [bool group = true]) async {
    final state = this.state.value;

    debugPrint('next: ${state.index}/${state.total}');

    // if (state.slides.canGoNext) {
    //   final nextSlide = state.slides.next(state.index);
    //   final nextIdx = state.slides.getIndex(nextSlide);
    //   await updateState(state.copyWith(
    //     currentSlide: nextSlide,
    //     index: nextIdx,
    //   ));
    //   return;
    // }
    final currentIdx = state.index;
    final nextIdx = currentIdx + 1;
    if (nextIdx >= state.total) {
      // ignore: use_build_context_synchronously
      end(context);
      return;
    }

    final nextSlide = slides[nextIdx];
    await updateState(state.copyWith(
      currentSlide: nextSlide,
      index: nextIdx,
    ));
  }

  Future<void> previous(BuildContext context, [bool group = true]) async {
    if (loading) return;
    final state = this.state.value;

    debugPrint('previous: ${state.index}/${state.total}');

    // if (state.slides.canGoPrevious) {
    //   final previousSlide = state.slides.previous(state.index);
    //   final previousIdx = state.slides.getIndex(previousSlide);
    //   await updateState(state.copyWith(
    //     currentSlide: previousSlide,
    //     index: previousIdx,
    //   ));
    //   return;
    // }

    final currentIdx = state.index;
    final previousIdx = currentIdx - 1;
    if (previousIdx < 0) {
      // ignore: use_build_context_synchronously
      // Start of presentation
      return;
    }

    final previousSlide = slides[previousIdx];
    await updateState(state.copyWith(
      currentSlide: previousSlide,
      index: previousIdx,
    ));
  }

  Future<void> preload(BuildContext context) async {
    if (loading) return;

    final images = <ImageSlide>[];
    for (final slide in slides) {
      if (slide is ImageSlide) {
        images.add(slide);
      }
    }

    await Future.wait(images.map((e) => e.preload(context)).toList());
  }

  Future<void> end(BuildContext context) async {
    await widget.onEnd();
  }

  Future<void> start(BuildContext context) async {
    showControls();
    final state = this.state.value;
    updateState(state.copyWith(
      currentSlide: slides.first,
    ));
  }

  Future<void> updateState(SlidesState value) async {
    state.value = value.copyWith();
    loading = true;
    updateDebounce?.cancel();
    updateDebounce = Timer(const Duration(milliseconds: 10), () async {
      await widget.onChange?.call(value);
    });
    loading = false;
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      start(context);
    });
  }

  @override
  void didUpdateWidget(covariant SlidesView oldWidget) {
    if (oldWidget.slides != widget.slides) {
      state.value = state.value.copyWith(
        slides: widget.slides,
        total: widget.slides.total,
      );
      start(context);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SlidesState>(
      valueListenable: state,
      builder: (context, state, child) {
        final current = buildCurrent(context, state);
        final bgColor = widget.background;
        final fgColor = bgColor.computeLuminance() > 0.5
            ? Colors.black
            : Colors.white.withOpacity(0.50);
        return LayoutBuilder(builder: (context, dimens) {
          final slideControls = <Widget>[
            IconButton(
              tooltip: 'Previous slide',
              icon: const Icon(Icons.navigate_before),
              onPressed: loading ? null : () => previous(context),
            ),
            // IconButton(
            //   tooltip: 'Previous group',
            //   icon: const Icon(Icons.skip_previous),
            //   onPressed: loading ? null : () => previous(context, false),
            // ),
            IconButton(
              tooltip: 'Enter fullscreen',
              icon: const Icon(Icons.fullscreen),
              onPressed: loading
                  ? null
                  : () => updateState(state.copyWith(fullScreen: true)),
            ),
            // IconButton(
            //   tooltip: 'Next group',
            //   icon: const Icon(Icons.skip_next),
            //   onPressed: loading ? null : () => next(context, false),
            // ),
            IconButton(
              tooltip: 'Next slide',
              icon: const Icon(Icons.navigate_next),
              onPressed: loading ? null : () => next(context),
            ),
          ];
          final isMobile = dimens.maxWidth < 600;
          return Scaffold(
            appBar: buildAppBar(context, state, isMobile, slideControls),
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
                      Positioned.fill(
                        child: widget.builder?.call(state, current) ?? current,
                      ),
                      if (state.fullScreen)
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
                                tooltip: 'Previous slide',
                                icon: const Icon(Icons.navigate_before),
                                onPressed:
                                    loading ? null : () => previous(context),
                                color: fgColor,
                              ),
                              // IconButton(
                              //   tooltip: 'Previous group',
                              //   icon: const Icon(Icons.skip_previous),
                              //   onPressed: loading
                              //       ? null
                              //       : () => previous(context, false),
                              //   color: fgColor,
                              // ),
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
                              // IconButton(
                              //   tooltip: 'Next group',
                              //   icon: const Icon(Icons.skip_next),
                              //   onPressed:
                              //       loading ? null : () => next(context, false),
                              //   color: fgColor,
                              // ),
                              IconButton(
                                tooltip: 'Next slide',
                                icon: const Icon(Icons.navigate_next),
                                onPressed: loading ? null : () => next(context),
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
    if (slides.isEmpty) {
      return const Center(child: Text('No slides found'));
    }
    final current = slides.getSlide(state.index);
    if (current == null) {
      return const Center(child: Text('Slide not found'));
    }
    return Center(
      child: AspectRatio(
        aspectRatio: widget.options.layout.ratio,
        child: RenderSlide(state: state, slide: current),
      ),
    );
  }

  AppBar? buildAppBar(
    BuildContext context,
    SlidesState state,
    bool mobile,
    List<Widget> actions,
  ) {
    if (state.fullScreen) return null;
    final exportIcon = IconButton(
      icon: const Icon(Icons.file_download),
      tooltip: 'Export',
      onPressed: () {
        final o = widget.options;
        state.toPowerPoint(context, title: o.title, layout: o.layout);
      },
    );
    return AppBar(
      title: widget.title,
      actions: [
        ...widget.actions,
        if (!mobile) ...actions,
        exportIcon,
      ],
      bottom: !mobile
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: actions,
              ),
            ),
    );
  }
}

class ExportOptions {
  const ExportOptions({
    this.title = 'untitled',
    this.layout = LayoutOptions.LAYOUT_16x9,
  });
  final String title;
  final LayoutOptions layout;
}
