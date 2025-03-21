import '../api_provider.dart';

import '../../base/base_reponse.dart';
import 'authentication_endpoint.dart';
import 'vjpload/sign_in_vjpload.dart';
import 'vjpload/sign_up_vjpload.dart';

class AuthService {
  final ApiProvider _apiProvider;

  AuthService(this._apiProvider);

  Future<BaseResponse> login(SignInVjpload payload) async {
    return _apiProvider.post(
      AuthenticationEndpoint.login,
      data: payload.toJson(),
    );
  }

  Future<BaseResponse> register(SignUpVjpload payload) async {
    return _apiProvider.post(
      AuthenticationEndpoint.register,
      data: payload.toJson(),
    );
  }

  Future<BaseResponse> logout() async {
    return _apiProvider.post(AuthenticationEndpoint.logout);
  }

  Future<BaseResponse> refreshToken(String refreshToken) async {
    return _apiProvider.post(
      AuthenticationEndpoint.refreshToken,
      data: {
        'refresh_token': refreshToken,
      },
    );
  }
} 