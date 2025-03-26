import '../../base/base_enpoint.dart';

class AuthenticationEndpoint {
  // Authentication endpoints
  static String get login => BaseEndpoint.getFullUrl('/auth/login');
  static String get register => BaseEndpoint.getFullUrl('/auth/register');
  static String get logout => BaseEndpoint.getFullUrl('/auth/logout');
  static String get refreshToken => BaseEndpoint.getFullUrl('/auth/refresh-token');
  static String get currentUser => BaseEndpoint.getFullUrl('/auth/me');
}
