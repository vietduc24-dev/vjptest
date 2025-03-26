import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/authentication/pages/login_page.dart';
import '../features/authentication/pages/register_page.dart';
import '../features/company/pages/profile_page.dart';
import '../features/home/pages/home_page.dart';
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
import '../services/api/groups/group_service.dart';
import '../features/chat/cubit/groups/groups_cubit.dart';
import '../features/chat/repository/groups/group_repository.dart';
import '../features/chat/pages/groups/create_group_screen.dart';
import '../features/chat/pages/groups/group_chat_screen.dart';
import '../services/websocket/WebSocketConfig.dart';
import '../services/api/groups/models/group.dart';
import '../features/company/repository/company_repository.dart';
import '../features/company/cubit/company_cubit.dart';
import '../features/authentication/repository/authentication_repository.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  redirect: (context, state) async {
    // Lấy AuthenticationRepository từ context
    final authRepo = context.read<AuthenticationRepository>();

    // Các route không cần auth
    final publicRoutes = ['/login', '/register'];
    final isPublicRoute = publicRoutes.contains(state.matchedLocation);

    // Kiểm tra token
    final token = await authRepo.getAccessToken();
    final isAuthenticated = token != null;

    if (!isAuthenticated && !isPublicRoute) {
      // Chưa đăng nhập và đang truy cập route cần auth
      // => Chuyển về login
      return '/login';
    }

    if (isAuthenticated && isPublicRoute) {
      // Đã đăng nhập nhưng đang ở login/register
      // => Chuyển về home
      return '/home';
    }

    // Các trường hợp còn lại giữ nguyên route
    return null;
  },
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
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider(
              create: (context) => CompanyRepository(),
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => CompanyCubit(
                  companyRepository: context.read<CompanyRepository>(),
                )..fetchCompanies(),
              ),
            ],
            child: ScaffoldWithNavBar(
              navigationShell: navigationShell,
            ),
          ),
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
                  child: Builder(
                    builder: (context) {
                      final apiProvider = context.read<ApiProvider>();
                      final friendsService = FriendsService(apiProvider: apiProvider);
                      final friendsRepository = FriendsRepository(friendsService: friendsService);
                      
                      return BlocProvider(
                        create: (context) => FriendsCubit(
                          friendsRepository: friendsRepository,
                        )..loadFriends(),
                        child: const FriendsListScreen(),
                      );
                    },
                  ),
                ),
              ),
              routes: [
                GoRoute(
                  path: 'requests',
                  name: 'friend_requests',
                  pageBuilder: (context, state) => MaterialPage(
                    child: PageWrapper(
                      child: Builder(
                        builder: (context) {
                          final apiProvider = context.read<ApiProvider>();
                          final friendsService = FriendsService(apiProvider: apiProvider);
                          final friendsRepository = FriendsRepository(friendsService: friendsService);
                          
                          return BlocProvider(
                            create: (context) => FriendsCubit(
                              friendsRepository: friendsRepository,
                            )..loadFriends(),
                            child: const FriendRequestsScreen(),
                          );
                        },
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
              builder: (context, state) => MultiRepositoryProvider(
                providers: [
                  RepositoryProvider(
                    create: (context) => GroupService(
                      context.read<ApiProvider>(),
                    ),
                  ),
                  RepositoryProvider(
                    create: (context) => GroupRepository(
                      context.read<GroupService>(),
                    ),
                  ),
                ],
                child: BlocProvider(
                  create: (context) => GroupsCubit(
                    context.read<GroupRepository>(),
                  )..loadGroups(),
                  child: Builder(
                    builder: (context) => const GroupListScreen(),
                  ),
                ),
              ),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'create_group',
                  pageBuilder: (context, state) => MaterialPage(
                    child: PageWrapper(
                      child: MultiRepositoryProvider(
                        providers: [
                          RepositoryProvider(
                            create: (context) => GroupService(
                              context.read<ApiProvider>(),
                            ),
                          ),
                          RepositoryProvider(
                            create: (context) => GroupRepository(
                              context.read<GroupService>(),
                            ),
                          ),
                          RepositoryProvider(
                            create: (context) => FriendsService(
                              apiProvider: context.read<ApiProvider>(),
                            ),
                          ),
                          RepositoryProvider(
                            create: (context) => FriendsRepository(
                              friendsService: context.read<FriendsService>(),
                            ),
                          ),
                        ],
                        child: MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create: (context) => GroupsCubit(
                                context.read<GroupRepository>(),
                              ),
                            ),
                            BlocProvider(
                              create: (context) => FriendsCubit(
                                friendsRepository: context.read<FriendsRepository>(),
                              ),
                            ),
                          ],
                          child: const CreateGroupScreen(),
                        ),
                      ),
                    ),
                  ),
                ),
                GoRoute(
                  path: 'chat/:groupId',
                  name: 'group_chat',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final group = state.extra as Group;
                    final currentUserId = state.uri.queryParameters['currentUserId'] ?? '';
                    return MultiRepositoryProvider(
                      providers: [
                        RepositoryProvider(
                          create: (context) => GroupService(
                            context.read<ApiProvider>(),
                          ),
                        ),
                        RepositoryProvider(
                          create: (context) => GroupRepository(
                            context.read<GroupService>(),
                          ),
                        ),
                      ],
                      child: BlocProvider(
                        create: (context) => GroupsCubit(
                          context.read<GroupRepository>(),
                        )..initializeGroupChat(
                            groupId: group.id,
                            wsUrl: WebSocketConfig.wsUrl,
                            currentUserId: currentUserId,
                          ),
                        child: Builder(
                          builder: (context) => GroupChatScreen(
                            group: group,
                            currentUserId: currentUserId,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // Tab Profile
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              pageBuilder: (context, state) => const MaterialPage(
                child: PageWrapper(
                  canPop: false,
                  child: ProfilePage(),
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
  
  static void goToProfile(BuildContext context) => context.goNamed('profile');
  
  static void goToChat(
      BuildContext context, Friend friend, String currentUserId) {
    context.goNamed(
      'chat',
      pathParameters: {'username': friend.username},
      queryParameters: {'currentUserId': currentUserId},
      extra: friend,
    );
  }

  static void goToCreateGroup(BuildContext context) => context.goNamed('create_group');

  static void goToGroupChat(BuildContext context, Group group, String currentUserId) {
    context.goNamed(
      'group_chat',
      pathParameters: {'groupId': group.id},
      queryParameters: {'currentUserId': currentUserId}, // 👈 Thêm dòng này
      extra: group,
    );
  }

  static void pop(BuildContext context) => context.pop();
}
