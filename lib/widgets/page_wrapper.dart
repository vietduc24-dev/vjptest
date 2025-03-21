import 'package:flutter/material.dart';

class PageWrapper extends StatelessWidget {
  final Widget child;
  final bool canPop;

  const PageWrapper({
    super.key,
    required this.child,
    this.canPop = true,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        if (!didPop) return;
        if (!canPop) {
          // Nếu không thể pop, giữ lại màn hình
          return;
        }
      },
      child: child,
    );
  }
} 