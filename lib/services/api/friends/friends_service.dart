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
      final endpoint = FriendsEndpoint.getFriendsList();
      debugPrint('🔍 [GET Friends List] URL: ${endpoint.path}');
      final response = await _apiProvider.get(
        endpoint.path!,
        params: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );
      
      debugPrint('📥 [GET Friends List] Response received: $response');
      
      List<Friend> friends = [];
      if (response is BaseResponse) {
        debugPrint('📦 [GET Friends List] Parsing BaseResponse...');
        if (response.success) {
          try {
            if (response.data is List) {
              friends = (response.data as List).map((item) {
                debugPrint('🔄 [GET Friends List] Parsing item: $item');
                return Friend.fromJson(item as Map<String, dynamic>);
              }).toList();
            }
          } catch (e) {
            debugPrint('❌ [GET Friends List] Error parsing friends: $e');
            throw Exception('Failed to parse friends data: $e');
          }
        } else {
          throw Exception(response.message ?? 'Failed to get friends list');
        }
      } else if (response is List) {
        // Handle direct array response
        debugPrint('📦 [GET Friends List] Parsing direct array response...');
        try {
          friends = response.map((item) {
            debugPrint('🔄 [GET Friends List] Parsing item: $item');
            return Friend.fromJson(item as Map<String, dynamic>);
          }).toList();
        } catch (e) {
          debugPrint('❌ [GET Friends List] Error parsing friends: $e');
          throw Exception('Failed to parse friends data: $e');
        }
      } else {
        throw Exception('Unexpected response type: ${response.runtimeType}');
      }
      
      debugPrint('✅ [GET Friends List] Parsed ${friends.length} friends');
      return PaginatedList.fromList(friends, page: page, pageSize: pageSize);
    } catch (e) {
      debugPrint('❌ [GET Friends List] Error: $e');
      rethrow;
    }
  }

  // Get friend requests with pagination
  Future<PaginatedList<Friend>> getFriendRequests({int page = 1, int pageSize = 10}) async {
    try {
      final endpoint = FriendsEndpoint.getFriendRequests();
      debugPrint('🔍 [GET Friend Requests] URL: ${endpoint.path}');
      final response = await _apiProvider.get(
        endpoint.path!,
        params: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );
      
      debugPrint('📥 [GET Friend Requests] Response received: $response');
      
      List<Friend> requests = [];
      if (response is BaseResponse) {
        debugPrint('📦 [GET Friend Requests] Parsing BaseResponse...');
        if (response.success) {
          try {
            if (response.data is List) {
              requests = (response.data as List).map((item) {
                debugPrint('🔄 [GET Friend Requests] Parsing item: $item');
                return Friend.fromJson(item as Map<String, dynamic>);
              }).toList();
            }
          } catch (e) {
            debugPrint('❌ [GET Friend Requests] Error parsing requests: $e');
            throw Exception('Failed to parse friend requests data: $e');
          }
        } else {
          throw Exception(response.message ?? 'Failed to get friend requests');
        }
      } else if (response is List) {
        // Handle direct array response
        debugPrint('📦 [GET Friend Requests] Parsing direct array response...');
        try {
          requests = response.map((item) {
            debugPrint('🔄 [GET Friend Requests] Parsing item: $item');
            return Friend.fromJson(item as Map<String, dynamic>);
          }).toList();
        } catch (e) {
          debugPrint('❌ [GET Friend Requests] Error parsing requests: $e');
          throw Exception('Failed to parse friend requests data: $e');
        }
      } else {
        throw Exception('Unexpected response type: ${response.runtimeType}');
      }
      
      debugPrint('✅ [GET Friend Requests] Parsed ${requests.length} requests');
      return PaginatedList.fromList(requests, page: page, pageSize: pageSize);
    } catch (e) {
      debugPrint('❌ [GET Friend Requests] Error: $e');
      rethrow;
    }
  }

  // Search users
  Future<List<Friend>> searchUsers(String query) async {
    try {
      final endpoint = FriendsEndpoint.searchUsers(query);
      debugPrint('🔍 [Search Users] URL: ${endpoint.path}');
      final response = await _apiProvider.get(
        endpoint.path!,
        params: {'q': query},
      );
      
      debugPrint('searchUsers response type: ${response.runtimeType}');
      debugPrint('searchUsers response: $response');
      
      if (response is List) {
        return _parseFriendsList(response);
      } else if (response is BaseResponse && response.success) {
        return _parseFriendsList(response.data);
      }
      return [];
    } catch (e) {
      debugPrint('searchUsers error: $e');
      throw Exception('Failed to search users: $e');
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
        data: {
          'to': toUsername,
        },
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
