import 'package:equatable/equatable.dart';
import '../../../../services/api/friends/friends_load/list_friends.dart';
import '../../../../services/base/paginated_list.dart';

abstract class FriendsState extends Equatable {
  const FriendsState();

  @override
  List<Object?> get props => [];
}

class FriendsInitial extends FriendsState {}

class FriendsLoading extends FriendsState {
  final bool isFirstLoad;
  final bool isLoadingMore;

  const FriendsLoading({
    this.isFirstLoad = true,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [isFirstLoad, isLoadingMore];
}

class FriendsLoaded extends FriendsState {
  final PaginatedList<Friend> friends;
  final PaginatedList<Friend> friendRequests;
  final List<Friend> searchResults;

  const FriendsLoaded({
    required this.friends,
    required this.friendRequests,
    this.searchResults = const [],
  });

  @override
  List<Object?> get props => [friends, friendRequests, searchResults];
}

class SearchResultsLoaded extends FriendsState {
  final List<Friend> searchResults;

  const SearchResultsLoaded(this.searchResults);

  @override
  List<Object?> get props => [searchResults];
}

class FriendsError extends FriendsState {
  final String message;

  const FriendsError(this.message);

  @override
  List<Object?> get props => [message];
}

class FriendRequestSent extends FriendsState {
  final String message;

  const FriendRequestSent(this.message);

  @override
  List<Object?> get props => [message];
}

class FriendRequestResponded extends FriendsState {
  final String message;

  const FriendRequestResponded(this.message);

  @override
  List<Object?> get props => [message];
}
