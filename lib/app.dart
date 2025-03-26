import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/authentication/cubit/login/login_cubit.dart';
import 'features/authentication/cubit/register/register_cubit.dart';
import 'features/authentication/repository/authentication_repository.dart';
import 'routes/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = context.read<AuthenticationRepository>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LoginCubit(authRepository: authRepo)),
        BlocProvider(create: (_) => RegisterCubit(authRepository: authRepo)),
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
    );
  }
}

