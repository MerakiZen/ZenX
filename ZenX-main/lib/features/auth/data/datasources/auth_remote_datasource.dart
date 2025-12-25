import '../../../../core/data/datasource.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/user.dart';

/// Remote data source for authentication
/// Handles GraphQL queries and mutations for auth
abstract class AuthRemoteDataSource implements RemoteDataSource {
  /// Login user
  AsyncResult<User> login(String email, String password);

  /// Register new user
  AsyncResult<User> register(String email, String password, String name);

  /// Logout user
  AsyncVoidResult logout();

  /// Refresh authentication token
  AsyncResult<String> refreshToken(String refreshToken);

  /// Request password reset
  AsyncVoidResult requestPasswordReset(String email);

  /// Reset password with token
  AsyncVoidResult resetPassword(String token, String newPassword);
}









