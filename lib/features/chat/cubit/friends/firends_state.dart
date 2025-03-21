import '../../../../services/api/friends/friends_load/list_friends.dart';
import '../../../../services/base/paginated_list.dart';

abstract class FriendsState {}

class FriendsInitial extends FriendsState {}

class FriendsLoading extends FriendsState {
  final bool isFirstLoad;
  final bool isLoadingMore;

  FriendsLoading({
    this.isFirstLoad = true,
    this.isLoadingMore = false,
  });
}

class FriendsLoaded extends FriendsState {
  final PaginatedList<Friend> friends;
  final PaginatedList<Friend> friendRequests;

  FriendsLoaded({
    required this.friends,
    required this.friendRequests,
  });
}

class FriendsError extends FriendsState {
  final String message;

  FriendsError(this.message);
}

class FriendRequestSent extends FriendsState {
  final String message;

  FriendRequestSent(this.message);
}

class FriendRequestResponded extends FriendsState {
  final String message;

  FriendRequestResponded(this.message);
}
