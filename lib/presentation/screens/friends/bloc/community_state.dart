// lib/presentation/screens/friends/bloc/community_state.dart
part of 'community_bloc.dart';

class CommunityState {
  final List<User> searchResults;
  final List<FriendRequest> receivedRequests;
  final bool isLoading;
  final String? message; // Thông báo (SnackBar)

  CommunityState({
    this.searchResults = const [], 
    this.receivedRequests = const [],
    this.isLoading = false,
    this.message,
  });
}