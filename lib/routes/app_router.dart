import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/authentication/pages/login_page.dart';
import '../features/authentication/pages/register_page.dart';
import '../features/company/pages/home_page.dart';
import '../features/chat/pages/friends/friends_list_screen.dart';
import '../features/chat/pages/groups/group_list_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(
          navigationShell: navigationShell,
        );
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(), // Mỗi branch có navigator riêng
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            GoRoute(
              path: '/friends',
              name: 'friends',
              builder: (context, state) => const FriendsListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            GoRoute(
              path: '/groups',
              name: 'groups',
              builder: (context, state) => const GroupListScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class AppRouter {
  AppRouter._();

  static void goToLogin(BuildContext context) => context.goNamed('login');
  
  static void goToRegister(BuildContext context) => context.goNamed('register');
  
  static void goToHome(BuildContext context) => context.goNamed('home');

  static void goToFriends(BuildContext context) => context.goNamed('friends');

  static void goToGroups(BuildContext context) => context.goNamed('groups');
  
  static void pop(BuildContext context) => context.pop();
} 