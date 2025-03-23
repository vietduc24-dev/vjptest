import '../../../../services/api/friends/friends_load/list_friends.dart';
import '../../../../services/api/friends/friends_service.dart';
import '../../../../services/base/base_reponse.dart';
import '../../../../services/base/paginated_list.dart';

class FriendsRepository {
  final FriendsService _friendsService;

  FriendsRepository({
    required FriendsService friendsService,
  }) : _friendsService = friendsService;

  Future<PaginatedList<Friend>> getFriendsList({int page = 1, int pageSize = 10}) async {
    return await _friendsService.getFriendsList(page: page, pageSize: pageSize);
  }

  Future<PaginatedList<Friend>> getFriendRequests({int page = 1, int pageSize = 10}) async {
    return await _friendsService.getFriendRequests(page: page, pageSize: pageSize);
  }

  Future<List<Friend>> searchUsers(String query) async {
    return await _friendsService.searchUsers(query);
  }

  Future<BaseResponse> sendFriendRequest(String toUsername) async {
    return await _friendsService.sendFriendRequest(toUsername);
  }

  Future<BaseResponse> acceptFriendRequest(String username) async {
    return await _friendsService.acceptFriendRequest(username);
  }

  Future<BaseResponse> rejectFriendRequest(String username) async {
    return await _friendsService.rejectFriendRequest(username);
  }

  void clearCache() {
    _friendsService.clearCache();
  }
}
