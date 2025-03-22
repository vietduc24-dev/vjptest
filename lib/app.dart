import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/authentication/cubit/login/login_cubit.dart';
import 'features/authentication/cubit/register/register_cubit.dart';
import 'features/authentication/repository/authentication_repository.dart';
import 'routes/app_router.dart';
import 'services/api/api_provider.dart';
import 'services/api/authentication/auth_service.dart';
import 'services/websocket/chatuser/chat_socket_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => ApiProvider()),
        RepositoryProvider(
          create: (context) => AuthService(context.read<ApiProvider>()),
          lazy: false,
        ),
        RepositoryProvider(
          create: (context) => AuthenticationRepository(context.read<AuthService>()),
          lazy: false,
        ),
        RepositoryProvider(
          create: (context) => ChatSocketProvider(context.read<AuthService>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LoginCubit(authRepository: context.read<AuthenticationRepository>()),
          ),
          BlocProvider(
            create: (context) => RegisterCubit(authRepository: context.read<AuthenticationRepository>()),
          ),
        ],
        child: MaterialApp.router(
          title: 'Authentication Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          routerConfig: goRouter,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
