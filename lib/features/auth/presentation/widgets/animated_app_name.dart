import 'package:flutter/material.dart';

/// Reveals [text] one character at a time (fade + slide-up), staggered
/// across a single [AnimationController] so every letter's `Interval`
/// occupies its own slice of the timeline. Used by [SplashScreen] for the
/// app name — the **only** `StatefulWidget` here, since it must own the
/// `AnimationController`'s lifecycle.
class AnimatedAppName extends StatefulWidget {
  const AnimatedAppName({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  State<AnimatedAppName> createState() => _AnimatedAppNameState();
}

class _AnimatedAppNameState extends State<AnimatedAppName>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500 + widget.text.length * 80),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characters = widget.text.split('');
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(characters.length, (index) {
            final start = index / characters.length;
            final end = (index + 1) / characters.length;
            final progress = Interval(start, end, curve: Curves.easeOut).transform(_controller.value);
            return Opacity(
              opacity: progress,
              child: Transform.translate(
                offset: Offset(0, (1 - progress) * 14),
                child: Text(characters[index], style: widget.style),
              ),
            );
          }),
        );
      },
    );
  }
}
