import '../entities/user.dart';

abstract class UserRepository {
  Future<User?> getUser(String userId);
  Future<void> updateUser(User user);

  Future<List<User>> getAllUsers();
  Future<List<User>> getFriends();
}