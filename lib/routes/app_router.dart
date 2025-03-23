import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/authentication/pages/login_page.dart';
import '../features/authentication/pages/register_page.dart';
import '../features/company/pages/home_page.dart';
import '../features/chat/pages/friends/friends_list_screen.dart';
import '../features/chat/pages/friends/friend_requests_screen.dart';
import '../features/chat/pages/groups/group_list_screen.dart';
import '../features/chat/pages/friends/chat_screen.dart';
import '../features/chat/repository/chat_repository.dart';
import '../features/chat/cubit/friends/firends_cubit.dart';
import '../features/chat/repository/friends/friends_repository.dart';
import '../services/api/friends/friends_load/list_friends.dart';
import '../services/api/friends/friends_service.dart';
import '../services/websocket/chatuser/chat_socket_provider.dart';
import '../services/api/api_provider.dart';
import '../common/widgets/scaffold_with_nav_bar.dart';
import '../features/chat/cubit/chat/chat_cubit.dart';
import '../common/widgets/page_wrapper.dart';
import '../features/chat/pages/friends/search_users_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

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
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              pageBuilder: (context, state) => const MaterialPage(
                child: PageWrapper(
                  canPop: false,
                  child: HomePage(),
                ),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            GoRoute(
              path: '/friends',
              name: 'friends',
              pageBuilder: (context, state) => MaterialPage(
                child: PageWrapper(
                  canPop: false,
                  child: MultiRepositoryProvider(
                    providers: [
                      RepositoryProvider(
                        create: (context) => FriendsService(
                            apiProvider: context.read<ApiProvider>()),
                      ),
                      RepositoryProvider(
                        create: (context) => FriendsRepository(
                            friendsService: context.read<FriendsService>()),
                      ),
                    ],
                    child: BlocProvider(
                      create: (context) => FriendsCubit(
                          friendsRepository:
                          context.read<FriendsRepository>())
                        ..loadFriends(),
                      child: const FriendsListScreen(),
                    ),
                  ),
                ),
              ),
              routes: [
                GoRoute(
                  path: 'requests',
                  name: 'friend_requests',
                  pageBuilder: (context, state) => MaterialPage(
                    child: PageWrapper(

                      child: MultiRepositoryProvider(
                        providers: [
                          RepositoryProvider(
                            create: (context) => FriendsService(
                                apiProvider: context.read<ApiProvider>()),
                          ),
                          RepositoryProvider(
                            create: (context) => FriendsRepository(
                                friendsService: context.read<FriendsService>()),
                          ),
                        ],
                        child: BlocProvider(
                          create: (context) => FriendsCubit(
                              friendsRepository: context.read<FriendsRepository>())
                            ..loadFriends(),
                          child: const FriendRequestsScreen(),
                        ),
                      ),
                    ),
                  ),
                ),
                GoRoute(
                  path: 'chat/:username',
                  name: 'chat',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final friend = state.extra as Friend;
                    final currentUserId =
                        state.uri.queryParameters['currentUserId'] ?? '';

                    return Material(
                      child: FutureBuilder(
                        future: context
                            .read<ChatSocketProvider>()
                            .getSocketService(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: \${snapshot.error}'));
                          }

                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          return RepositoryProvider(
                            create: (context) => ChatRepository(
                              socketService: snapshot.data!,
                              currentUserId: currentUserId,
                              receiverId: friend.username,
                            ),
                            child: BlocProvider(
                              create: (context) => ChatCubit(
                                  repository:
                                  context.read<ChatRepository>()),
                              child: ChatScreen(
                                friend: friend,
                                currentUserId: currentUserId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: 'search',
                  name: 'search_users',
                  pageBuilder: (context, state) => MaterialPage(
                    child: PageWrapper(
                      child: MultiRepositoryProvider(
                        providers: [
                          RepositoryProvider(
                            create: (context) => FriendsService(
                                apiProvider: context.read<ApiProvider>()),
                          ),
                          RepositoryProvider(
                            create: (context) => FriendsRepository(
                                friendsService: context.read<FriendsService>()),
                          ),
                        ],
                        child: BlocProvider(
                          create: (context) => FriendsCubit(
                              friendsRepository: context.read<FriendsRepository>())
                            ..loadFriends(),
                          child: const SearchUsersScreen(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            GoRoute(
              path: '/groups',
              name: 'groups',
              pageBuilder: (context, state) => const MaterialPage(
                child: PageWrapper(
                  canPop: false,
                  child: GroupListScreen(),
                ),
              ),
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
  
  static void goToFriendRequests(BuildContext context) => context.goNamed('friend_requests');
  
  static void goToChat(
      BuildContext context, Friend friend, String currentUserId) {
    context.goNamed(
      'chat',
      pathParameters: {'username': friend.username},
      queryParameters: {'currentUserId': currentUserId},
      extra: friend,
    );
  }

  static void pop(BuildContext context) => context.pop();
}
