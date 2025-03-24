import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/api/friends/friends_load/list_friends.dart';
import '../../../../services/base/paginated_list.dart';
import '../../repository/friends/friends_repository.dart';
import 'firends_state.dart';

class FriendsCubit extends Cubit<FriendsState> {
  final FriendsRepository _friendsRepository;
  PaginatedList<Friend>? _currentFriends;
  PaginatedList<Friend>? _currentRequests;

  FriendsCubit({
    required FriendsRepository friendsRepository,
  })  : _friendsRepository = friendsRepository,
        super(FriendsInitial());

  Future<void> loadFriends({bool refresh = false}) async {
    try {
      if (refresh) {
        _friendsRepository.clearCache();
        _currentFriends = null;
        _currentRequests = null;
      }

      emit(FriendsLoading(isFirstLoad: _currentFriends == null));
      
      final friends = await _friendsRepository.getFriendsList();
      final requests = await _friendsRepository.getFriendRequests();
      
      _currentFriends = friends;
      _currentRequests = requests;
      
      emit(FriendsLoaded(
        friends: friends,
        friendRequests: requests,
      ));
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> loadMoreFriends() async {
    try {
      if (state is! FriendsLoaded) return;
      final currentState = state as FriendsLoaded;
      
      if (!currentState.friends.hasMore) return;
      
      emit(FriendsLoading(isFirstLoad: false, isLoadingMore: true));
      
      final nextPage = currentState.friends.page + 1;
      final friends = await _friendsRepository.getFriendsList(page: nextPage);
      
      _currentFriends = friends;
      
      emit(FriendsLoaded(
        friends: friends,
        friendRequests: currentState.friendRequests,
      ));
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> sendFriendRequest(String username) async {
    try {
      final response = await _friendsRepository.sendFriendRequest(username);
      if (response.success) {
        final currentState = state;
        if (currentState is FriendsLoaded) {
          final updatedResults = currentState.searchResults.map((user) {
            if (user.username == username) {
              return Friend(
                username: user.username,
                fullName: user.fullName,
                avatar: user.avatar,
                friendshipStatus: 'pending_sent',
              );
            }
            return user;
          }).toList();

          // Emit success message first
          emit(FriendRequestSent(response.message ?? 'Đã gửi lời mời kết bạn'));
          
          // Then restore the state with updated results
          emit(FriendsLoaded(
            friends: currentState.friends,
            friendRequests: currentState.friendRequests,
            searchResults: updatedResults,
          ));
        }
      } else {
        emit(FriendsError(response.message ?? 'Không thể gửi lời mời kết bạn'));
      }
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> acceptFriendRequest(String username) async {
    try {
      final response = await _friendsRepository.acceptFriendRequest(username);
      if (response.success) {
        final currentState = state;
        if (currentState is FriendsLoaded) {
          final updatedResults = currentState.searchResults.map((user) {
            if (user.username == username) {
              return Friend(
                username: user.username,
                fullName: user.fullName,
                avatar: user.avatar,
                friendshipStatus: 'friend',
              );
            }
            return user;
          }).toList();

          // Emit success message first
          emit(FriendRequestResponded(response.message ?? 'Đã chấp nhận lời mời kết bạn'));
          
          // Then restore the state with updated results
          emit(FriendsLoaded(
            friends: currentState.friends,
            friendRequests: currentState.friendRequests,
            searchResults: updatedResults,
          ));
        }
      } else {
        emit(FriendsError(response.message ?? 'Không thể chấp nhận lời mời kết bạn'));
      }
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> rejectFriendRequest(String username) async {
    try {
      final response = await _friendsRepository.rejectFriendRequest(username);
      if (response.success) {
        final currentState = state;
        if (currentState is FriendsLoaded) {
          final updatedResults = currentState.searchResults.map((user) {
            if (user.username == username) {
              return Friend(
                username: user.username,
                fullName: user.fullName,
                avatar: user.avatar,
                friendshipStatus: 'none',
              );
            }
            return user;
          }).toList();

          // Emit success message first
          emit(FriendRequestResponded(response.message ?? 'Đã từ chối lời mời kết bạn'));
          
          // Then restore the state with updated results
          emit(FriendsLoaded(
            friends: currentState.friends,
            friendRequests: currentState.friendRequests,
            searchResults: updatedResults,
          ));
        }
      } else {
        emit(FriendsError(response.message ?? 'Không thể từ chối lời mời kết bạn'));
      }
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> searchUsers(String query) async {
    emit(FriendsLoading());
    try {
      final results = await _friendsRepository.searchUsers(query);
      emit(SearchResultsLoaded(results));
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }
}
