import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../base/base_reponse.dart';
import '../../base/paginated_list.dart';
import '../api_provider.dart';
import 'friends_endpoint.dart';
import 'friends_load/list_friends.dart';

class FriendsService {
  final ApiProvider _apiProvider;
  List<Friend> _cachedFriends = [];
  List<Friend> _cachedRequests = [];

  FriendsService({required ApiProvider apiProvider}) : _apiProvider = apiProvider;

  List<Friend> _parseFriendsList(dynamic data) {
    if (data is List) {
      return data.map((item) => Friend.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Get all friends with pagination
  Future<PaginatedList<Friend>> getFriendsList({int page = 1, int pageSize = 10}) async {
    try {
      // If we don't have cached data or it's the first page, fetch from API
      if (_cachedFriends.isEmpty || page == 1) {
        final endpoint = FriendsEndpoint.getFriendsList();
        final response = await _apiProvider.get(endpoint.path!);
        
        debugPrint('getFriendsList response type: ${response.runtimeType}');
        debugPrint('getFriendsList response: $response');
        
        if (response is List) {
          _cachedFriends = _parseFriendsList(response);
        } else if (response is BaseResponse && response.success) {
          _cachedFriends = _parseFriendsList(response.data);
        }
      }
      
      return PaginatedList.fromList(_cachedFriends, page: page, pageSize: pageSize);
    } catch (e) {
      debugPrint('getFriendsList error: $e');
      throw Exception('Failed to load friends list: $e');
    }
  }

  // Get friend requests with pagination
  Future<PaginatedList<Friend>> getFriendRequests({int page = 1, int pageSize = 10}) async {
    try {
      // If we don't have cached data or it's the first page, fetch from API
      if (_cachedRequests.isEmpty || page == 1) {
        final endpoint = FriendsEndpoint.getFriendRequests();
        final response = await _apiProvider.get(endpoint.path!);

        debugPrint('getFriendRequests response type: ${response.runtimeType}');
        debugPrint('getFriendRequests response: $response');

        if (response is List) {
          _cachedRequests = _parseFriendsList(response);
        } else if (response is BaseResponse && response.success) {
          _cachedRequests = _parseFriendsList(response.data);
        }
      }
      
      return PaginatedList.fromList(_cachedRequests, page: page, pageSize: pageSize);
    } catch (e) {
      debugPrint('getFriendRequests error: $e');
      throw Exception('Failed to load friend requests: $e');
    }
  }

  // Clear cache
  void clearCache() {
    _cachedFriends = [];
    _cachedRequests = [];
  }

  // Send friend request
  Future<BaseResponse> sendFriendRequest(String toUsername) async {
    try {
      final endpoint = FriendsEndpoint.sendFriendRequest();
      final response = await _apiProvider.post(
        endpoint.path!,
        data: {'username': toUsername},
      );
      clearCache(); // Clear cache after sending request
      return response;
    } catch (e) {
      throw Exception('Failed to send friend request: $e');
    }
  }

  // Accept friend request
  Future<BaseResponse> acceptFriendRequest(String username) async {
    try {
      final endpoint = FriendsEndpoint.acceptFriendRequest(username);
      final response = await _apiProvider.put(endpoint.path!);
      clearCache(); // Clear cache after accepting request
      return response;
    } catch (e) {
      throw Exception('Failed to accept friend request: $e');
    }
  }

  // Reject friend request
  Future<BaseResponse> rejectFriendRequest(String username) async {
    try {
      final endpoint = FriendsEndpoint.rejectFriendRequest(username);
      final response = await _apiProvider.delete(endpoint.path!);
      clearCache(); // Clear cache after rejecting request
      return response;
    } catch (e) {
      throw Exception('Failed to reject friend request: $e');
    }
  }
}
