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
  if (widget.navigationShell.currentIndex != 0) {
    widget.navigationShell.goBranch(0);
    return false;
  }

  // Kiểm tra nếu đang dùng gesture điều hướng hệ thống
  if (Navigator.of(context).userGestureInProgress) {
    return false;
  }

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
  return true;
}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: widget.navigationShell.currentIndex != 0
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => widget.navigationShell.goBranch(0),
                ),
                title: Text(
                  widget.navigationShell.currentIndex == 1 ? 'Friends' : 'Groups',
                ),
              )
            : null,
        body: widget.navigationShell,
        bottomNavigationBar: Container(
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
                  initialLocation: index == widget.navigationShell.currentIndex,
                );
              },
              items: [
                SalomonBottomBarItem(
                  icon: const Icon(Icons.home),
                  title: const Text("Home"),
                  selectedColor: Theme.of(context).primaryColor,
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.people),
                  title: const Text("Friends"),
                  selectedColor: Theme.of(context).primaryColor,
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.group),
                  title: const Text("Groups"),
                  selectedColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}