import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class ScaffoldWithNavBar extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  DateTime? _lastBackPressed;

  Future<bool> _onWillPop() async {
    // Nếu có thể pop màn hình hiện tại (có màn hình con), thực hiện pop
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return false;
    }

    // Nếu không ở tab Home → chuyển về Home
    if (widget.navigationShell.currentIndex != 0) {
      widget.navigationShell.goBranch(0);
      return false;
    }

    // Chặn gesture back nếu đang thao tác vuốt
    if (Navigator
        .of(context)
        .userGestureInProgress) {
      return false;
    }

    // Kiểm tra double back để thoát
    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nhấn back lần nữa để thoát'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    // Thoát app
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          return;
        }

        if (widget.navigationShell.currentIndex != 0) {
          widget.navigationShell.goBranch(0);
          return;
        }

        final now = DateTime.now();
        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nhấn back lần nữa để thoát'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        Navigator.of(context).maybePop(); // Thoát app
      },
      child: Builder(
        builder: (context) {
          final location = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;

          final hideNavBarRoutes = [
            '/friends/search',
            '/friends/requests',
            '/friends/chat', // will match with /friends/chat/:username
          ];

          final shouldHideNavBar =
          hideNavBarRoutes.any((path) => location.startsWith(path));

          return Scaffold(
            // ❌ Không cần AppBar nếu không dùng
            body: widget.navigationShell,
            bottomNavigationBar: shouldHideNavBar
                ? null
                : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: SalomonBottomBar(
                  currentIndex: widget.navigationShell.currentIndex,
                  onTap: (index) {
                    widget.navigationShell.goBranch(
                      index,
                      initialLocation:
                      index == widget.navigationShell.currentIndex,
                    );
                  },
                  selectedItemColor: Colors.blue[700],
                  unselectedItemColor: Colors.grey[600],
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  items: [
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.home_outlined),
                      activeIcon: const Icon(Icons.home),
                      title: const Text("Trang chủ"),
                      selectedColor: Colors.blue[700],
                    ),
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.chat_bubble_outline),
                      activeIcon: const Icon(Icons.chat_bubble),
                      title: const Text("Tin nhắn"),
                      selectedColor: Colors.blue[700],
                    ),
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.group_outlined),
                      activeIcon: const Icon(Icons.group),
                      title: const Text("Nhóm"),
                      selectedColor: Colors.blue[700],
                    ),
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.person_outline),
                      activeIcon: const Icon(Icons.person),
                      title: const Text("Hồ sơ"),
                      selectedColor: Colors.blue[700],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}