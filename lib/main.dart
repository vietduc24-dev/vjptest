import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:vjptest/app.dart';
import 'features/authentication/repository/authentication_repository.dart';
import 'services/api/api_provider.dart';
import 'services/api/authentication/auth_service.dart';
import 'services/websocket/chatuser/chat_socket_provider.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await dotenv.load(fileName: ".env");
  Bloc.observer = AppBlocObserver();

  // Khởi tạo các service theo thứ tự phụ thuộc
  final authService = AuthService(null); // Tạm thời pass null
  final apiProvider = await ApiProvider.create(authService);
  
  // Update ApiProvider cho AuthService
  authService.updateApiProvider(apiProvider);

  final authRepository = AuthenticationRepository(authService);
  final chatSocketProvider = ChatSocketProvider(authService);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiProvider>.value(value: apiProvider),
        RepositoryProvider<AuthService>.value(value: authService),
        RepositoryProvider<AuthenticationRepository>.value(value: authRepository),
        RepositoryProvider<ChatSocketProvider>.value(value: chatSocketProvider),
      ],
      child: const MyApp(),
    ),
  );
  debugPrint('✅ App started successfully');
}
