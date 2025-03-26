import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/bloc_status.dart';
import '../../../../services/api/friends/friends_load/list_friends.dart';
import '../../../../services/base/paginated_list.dart';
import '../../repository/friends/friends_repository.dart';
import 'firends_state.dart';

class FriendsCubit extends Cubit<FriendsState> {
  final FriendsRepository _friendsRepository;

  FriendsCubit({
    required FriendsRepository friendsRepository,
  })  : _friendsRepository = friendsRepository,
        super(const FriendsState());

  Future<void> loadFriends({bool refresh = false}) async {
    try {
      if (refresh) {
        print('🔄 Refreshing friends list...');
        _friendsRepository.clearCache();
      }

      emit(state.copyWith(
        status: BlocStatus.loading,
        isLoadingMore: false,
      ));

      PaginatedList<Friend>? friends;
      PaginatedList<Friend>? requests;

      // Load friends first
      try {
        print('🔄 Fetching friends list...');
        friends = await _friendsRepository.getFriendsList();
        print('✅ Friends list loaded: ${friends.items.length} friends');
      } catch (e, stackTrace) {
        print('❌ Error loading friends: $e');
        print('Stack trace: $stackTrace');
      }

      // Then load requests
      try {
        print('🔄 Fetching friend requests...');
        requests = await _friendsRepository.getFriendRequests();
        print('✅ Friend requests loaded: ${requests.items.length} requests');
      } catch (e, stackTrace) {
        print('❌ Error loading requests: $e');
        print('Stack trace: $stackTrace');
      }

      // Emit state with whatever data we have
      if (friends != null || requests != null) {
        print('✅ Emitting success state');
        print('Friends count: ${friends?.items.length ?? 0}');
        print('Requests count: ${requests?.items.length ?? 0}');

        emit(state.copyWith(
          status: BlocStatus.success,
          friends: friends ?? PaginatedList.empty(),
          friendRequests: requests ?? PaginatedList.empty(),
          errorMessage: null,
        ));
      } else {
        // Only emit error if both calls failed
        print('❌ Both friends and requests failed to load');
        emit(state.copyWith(
          status: BlocStatus.failure,
          errorMessage: 'Không thể tải danh sách bạn bè',
        ));
      }
    } catch (e, stackTrace) {
      print('❌ Unexpected error in loadFriends: $e');
      print('Stack trace: $stackTrace');
      emit(state.copyWith(
        status: BlocStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadMoreFriends() async {
    try {
      if (!state.friends.hasMore || state.isLoadingMore) return;

      emit(state.copyWith(
        isLoadingMore: true,
      ));

      final nextPage = state.friends.page + 1;
      final friends = await _friendsRepository.getFriendsList(page: nextPage);

      emit(state.copyWith(
        status: BlocStatus.success,
        friends: friends,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BlocStatus.failure,
        errorMessage: e.toString(),
        isLoadingMore: false,
      ));
    }
  }

  Future<void> sendFriendRequest(String username) async {
    try {
      final response = await _friendsRepository.sendFriendRequest(username);
      if (response.success) {
        final updatedResults = state.searchResults.map((user) {
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

        emit(state.copyWith(
          status: BlocStatus.success,
          searchResults: updatedResults,
          successMessage: response.message ?? 'Đã gửi lời mời kết bạn',
        ));
      } else {
        emit(state.copyWith(
          status: BlocStatus.failure,
          errorMessage: response.message ?? 'Không thể gửi lời mời kết bạn',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BlocStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> acceptFriendRequest(String username) async {
    try {
      final response = await _friendsRepository.acceptFriendRequest(username);
      if (response.success) {
        // Cập nhật trạng thái kết bạn trong searchResults
        final updatedResults = state.searchResults.map((user) {
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

        // Cập nhật danh sách friend requests
        final updatedRequests = PaginatedList(
          items: state.friendRequests.items.where((req) => req.username != username).toList(),
          page: state.friendRequests.page,
          pageSize: state.friendRequests.pageSize,
          hasMore: state.friendRequests.hasMore,
          total: state.friendRequests.total - 1,
        );

        emit(state.copyWith(
          status: BlocStatus.success,
          searchResults: updatedResults,
          friendRequests: updatedRequests,
          successMessage: response.message ?? 'Đã chấp nhận lời mời kết bạn',
        ));

        // Reload friends list để cập nhật bạn mới
        loadFriends();
      } else {
        emit(state.copyWith(
          status: BlocStatus.failure,
          errorMessage: response.message ?? 'Không thể chấp nhận lời mời kết bạn',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BlocStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> rejectFriendRequest(String username) async {
    try {
      final response = await _friendsRepository.rejectFriendRequest(username);
      if (response.success) {
        // Cập nhật trạng thái kết bạn trong searchResults
        final updatedResults = state.searchResults.map((user) {
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

        // Cập nhật danh sách friend requests
        final updatedRequests = PaginatedList(
          items: state.friendRequests.items.where((req) => req.username != username).toList(),
          page: state.friendRequests.page,
          pageSize: state.friendRequests.pageSize,
          hasMore: state.friendRequests.hasMore,
          total: state.friendRequests.total - 1,
        );

        emit(state.copyWith(
          status: BlocStatus.success,
          searchResults: updatedResults,
          friendRequests: updatedRequests,
          successMessage: response.message ?? 'Đã từ chối lời mời kết bạn',
        ));
      } else {
        emit(state.copyWith(
          status: BlocStatus.failure,
          errorMessage: response.message ?? 'Không thể từ chối lời mời kết bạn',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BlocStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> searchUsers(String query) async {
    emit(state.copyWith(
      status: BlocStatus.loading,
    ));
    
    try {
      final results = await _friendsRepository.searchUsers(query);
      emit(state.copyWith(
        status: BlocStatus.success,
        searchResults: results,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BlocStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
