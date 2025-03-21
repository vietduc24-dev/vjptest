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
        emit(FriendRequestSent(response.message ?? 'Friend request sent successfully'));
        loadFriends(refresh: true); // Reload the lists
      } else {
        emit(FriendsError(response.message ?? 'Failed to send friend request'));
      }
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> acceptFriendRequest(String username) async {
    try {
      final response = await _friendsRepository.acceptFriendRequest(username);
      if (response.success) {
        emit(FriendRequestResponded(response.message ?? 'Friend request accepted'));
        loadFriends(refresh: true); // Reload the lists
      } else {
        emit(FriendsError(response.message ?? 'Failed to accept friend request'));
      }
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> rejectFriendRequest(String username) async {
    try {
      final response = await _friendsRepository.rejectFriendRequest(username);
      if (response.success) {
        emit(FriendRequestResponded(response.message ?? 'Friend request rejected'));
        loadFriends(refresh: true); // Reload the lists
      } else {
        emit(FriendsError(response.message ?? 'Failed to reject friend request'));
      }
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }
}
