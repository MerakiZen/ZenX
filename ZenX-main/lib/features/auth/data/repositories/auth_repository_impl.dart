import '../../../../core/data/repositories/base_repository.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Authentication repository implementation
class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  AsyncResult<User> login(String email, String password) async {
    try {
      final result = await remoteDataSource.login(email, password);
      return result.when(
        success: (user) async {
          // Save token to local storage
          // await localDataSource.saveToken(user.token);
          return Result.success(user);
        },
        failure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return handleNetworkError(e);
    }
  }

  @override
  AsyncResult<User> register(String email, String password, String name) async {
    try {
      final result = await remoteDataSource.register(email, password, name);
      return result.when(
        success: (user) async {
          // Save token to local storage
          // await localDataSource.saveToken(user.token);
          return Result.success(user);
        },
        failure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return handleNetworkError(e);
    }
  }

  @override
  AsyncVoidResult logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearAuthData();
      return const Result.success(null);
    } catch (e) {
      return handleNetworkError(e);
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await localDataSource.isLoggedIn();
  }
}









