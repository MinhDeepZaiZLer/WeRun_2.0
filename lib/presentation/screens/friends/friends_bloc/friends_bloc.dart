import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/repositories/user_repository.dart';

// --- EVENT ---
abstract class FriendsEvent {}
class LoadFriends extends FriendsEvent {}

// --- STATE ---
class FriendsState {
  final List<User> friends;
  final bool isLoading;
  
  FriendsState({this.friends = const [], this.isLoading = false});
}

// --- BLOC ---
@injectable
class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final UserRepository _userRepository;

  FriendsBloc(this._userRepository) : super(FriendsState()) {
    
    on<LoadFriends>((event, emit) async {
      emit(FriendsState(isLoading: true));
      try {
        final friends = await _userRepository.getFriends();
        emit(FriendsState(friends: friends, isLoading: false));
      } catch (e) {
        print(e);
        emit(FriendsState(isLoading: false));
      }
    });
    
  }
}