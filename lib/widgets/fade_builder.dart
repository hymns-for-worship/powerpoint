import 'dart:async';

import 'package:flutter/material.dart';

class FadeBuilder extends StatefulWidget {
  const FadeBuilder({super.key, required this.child});

  final Widget child;

  @override
  State<FadeBuilder> createState() => _FadeBuilderState();
}

class _FadeBuilderState extends State<FadeBuilder> {
  Widget? old;
  late Widget child = widget.child;
  final duration = const Duration(milliseconds: 50);
  var state = CrossFadeState.showSecond;
  Timer? timer;

  @override
  void didUpdateWidget(covariant FadeBuilder oldWidget) {
    if (oldWidget.child != widget.child) {
      if (mounted) {
        setState(() {
          old = child;
          child = widget.child;
          state = CrossFadeState.showSecond;
        });
      }
      timer?.cancel();
      timer = Timer(duration, () {
        if (mounted) {
          setState(() {
            state = CrossFadeState.showFirst;
            old = null;
          });
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: old ?? child,
      secondChild: child,
      firstCurve: Curves.easeIn,
      secondCurve: Curves.easeOut,
      duration: duration,
      crossFadeState: state,
    );
  }
}
