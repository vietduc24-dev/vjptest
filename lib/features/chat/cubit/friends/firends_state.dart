import 'package:equatable/equatable.dart';
import '../../../../common/bloc_status.dart';
import '../../../../services/api/friends/friends_load/list_friends.dart';
import '../../../../services/base/paginated_list.dart';

class FriendsState extends Equatable {
  final BlocStatus status;
  final PaginatedList<Friend> friends;
  final PaginatedList<Friend> friendRequests;
  final List<Friend> searchResults;
  final String? errorMessage;
  final String? successMessage;
  final bool isLoadingMore;

  const FriendsState({
    this.status = BlocStatus.initial,
    this.friends = PaginatedList.emptyList,
    this.friendRequests = PaginatedList.emptyList,
    this.searchResults = const [],
    this.errorMessage,
    this.successMessage,
    this.isLoadingMore = false,
  });

  bool get isInitialLoading => status == BlocStatus.loading && !isLoadingMore;
  bool get hasError => status == BlocStatus.failure && errorMessage != null;
  bool get isSuccess => status == BlocStatus.success;

  FriendsState copyWith({
    BlocStatus? status,
    PaginatedList<Friend>? friends,
    PaginatedList<Friend>? friendRequests,
    List<Friend>? searchResults,
    String? errorMessage,
    String? successMessage,
    bool? isLoadingMore,
  }) {
    return FriendsState(
      status: status ?? this.status,
      friends: friends ?? this.friends,
      friendRequests: friendRequests ?? this.friendRequests,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: errorMessage,  // Null để clear error
      successMessage: successMessage,  // Null để clear message
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    status,
    friends,
    friendRequests,
    searchResults,
    errorMessage,
    successMessage,
    isLoadingMore,
  ];
}
