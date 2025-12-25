import '../../../../core/domain/repository.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/user.dart';

/// Authentication repository interface
abstract class AuthRepository implements Repository {
  /// Login user
  AsyncResult<User> login(String email, String password);

  /// Register new user
  AsyncResult<User> register(String email, String password, String name);

  /// Logout user
  AsyncVoidResult logout();

  /// Check if user is logged in
  Future<bool> isLoggedIn();
}









