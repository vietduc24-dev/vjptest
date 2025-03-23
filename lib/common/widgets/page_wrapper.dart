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
        // Nếu không cho pop, chặn lại
        if (!didPop && !canPop) {
          // Chặn gesture back
        }
      },
      child: child,
    );
  }
}
