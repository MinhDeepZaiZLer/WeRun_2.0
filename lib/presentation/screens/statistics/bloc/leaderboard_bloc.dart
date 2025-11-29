import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/leaderboard_entry.dart';
import '../../../../domain/repositories/leaderboard_repository.dart';
import '../../../../domain/usecases/get_leaderboard_usecase.dart';
import '../../../../domain/repositories/user_repository.dart';

// --- EVENTS ---
abstract class LeaderboardEvent {}

class LoadLeaderboard extends LeaderboardEvent {
  final LeaderboardFilter filter;
  final bool isGlobal; // true: Global, false: Friends only

  LoadLeaderboard({this.filter = LeaderboardFilter.total, this.isGlobal = true});
}

// --- STATE ---
class LeaderboardState {
  final List<LeaderboardEntry> rankings;
  final bool isLoading;
  final LeaderboardFilter currentFilter;
  final bool isGlobal;
  final String? error;

  LeaderboardState({
    this.rankings = const [],
    this.isLoading = false,
    this.currentFilter = LeaderboardFilter.total,
    this.isGlobal = true,
    this.error,
  });

  LeaderboardState copyWith({
    List<LeaderboardEntry>? rankings,
    bool? isLoading,
    LeaderboardFilter? currentFilter,
    bool? isGlobal,
    String? error,
  }) {
    return LeaderboardState(
      rankings: rankings ?? this.rankings,
      isLoading: isLoading ?? this.isLoading,
      currentFilter: currentFilter ?? this.currentFilter,
      isGlobal: isGlobal ?? this.isGlobal,
      error: error,
    );
  }
}

// --- BLOC ---
@injectable
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final GetLeaderboardUsecase _getLeaderboardUsecase;
  final UserRepository _userRepository; // Cần để lấy danh sách bạn bè

  LeaderboardBloc(this._getLeaderboardUsecase, this._userRepository) : super(LeaderboardState()) {
    
    on<LoadLeaderboard>((event, emit) async {
      emit(state.copyWith(
        isLoading: true, 
        currentFilter: event.filter,
        isGlobal: event.isGlobal,
        error: null,
      ));

      try {
        List<String>? friendIds;

        // Nếu chọn chế độ "Friends", cần lấy danh sách ID bạn bè trước
        if (!event.isGlobal) {
          final friends = await _userRepository.getFriends();
          friendIds = friends.map((u) => u.id).toList();
          
          // Nếu chưa có bạn bè nào, trả về rỗng luôn
          if (friendIds.isEmpty) {
             emit(state.copyWith(isLoading: false, rankings: []));
             return;
          }
        }

        // Gọi Usecase tính toán BXH
        final rankings = await _getLeaderboardUsecase.call(
          filter: event.filter,
          friendIds: friendIds,
        );

        emit(state.copyWith(isLoading: false, rankings: rankings));
        
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
  }
}