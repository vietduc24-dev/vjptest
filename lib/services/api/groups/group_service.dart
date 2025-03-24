import 'package:dio/dio.dart';
import 'models/group.dart';
import '../api_provider.dart';
import 'group_endpoints.dart';
import '../../base/base_reponse.dart';
import '../../base/base_enpoint.dart';
import '../../../services/websocket/chatgroup/group_message.dart';

class GroupService {
  final ApiProvider _apiProvider;

  GroupService(this._apiProvider);

  Future<Group> createGroup(String name, List<String> members) async {
    try {
      final endpoint = GroupEndpoints.createGroup();
      final response = await _apiProvider.post(
        BaseEndpoint.getFullUrl(endpoint.path ?? ''),
        data: {
          'name': name,
          'members': members,
        },
      );
      final baseResponse = BaseResponse.fromJson(response.data);
      return Group.fromJson(baseResponse.data['group']);
    } catch (e) {
      print('Error in createGroup: $e');
      rethrow;
    }
  }

  Future<List<Group>> getGroups() async {
    try {
      final endpoint = GroupEndpoints.getGroups();
      final response = await _apiProvider.get(
        BaseEndpoint.getFullUrl(endpoint.path ?? '')
      );
      if (response is! BaseResponse) {
        return (response as List)
            .map((group) => Group.fromJson(group as Map<String, dynamic>))
            .toList();
      }
      if (response.data == null) {
        return [];
      }
      return (response.data as List)
          .map((group) => Group.fromJson(group as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error in getGroups: $e');
      rethrow;
    }
  }

  Future<Group> getGroupInfo(String groupId) async {
    try {
      final endpoint = GroupEndpoints.getGroupInfo(groupId);
      final response = await _apiProvider.get(
        BaseEndpoint.getFullUrl(endpoint.path ?? '')
      );
      final baseResponse = response is BaseResponse ? response : BaseResponse.fromJson(response);
      if (baseResponse.data == null) {
        throw Exception('Group not found');
      }
      return Group.fromJson(baseResponse.data);
    } catch (e) {
      print('Error in getGroupInfo: $e');
      rethrow;
    }
  }

  Future<void> addMember(String groupId, String username) async {
    try {
      final endpoint = GroupEndpoints.addMember(groupId);
      final response = await _apiProvider.post(
        BaseEndpoint.getFullUrl(endpoint.path ?? ''),
        data: {'username': username},
      );
      if (!response.success) {
        throw Exception(response.message ?? 'Failed to add member');
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 403) {
        throw Exception('Bạn không có quyền thêm thành viên');
      }
      print('Error in addMember: $e');
      rethrow;
    }
  }

  Future<void> removeMember(String groupId, String username) async {
    try {
      final endpoint = GroupEndpoints.removeMember(groupId, username);
      final response = await _apiProvider.delete(
        BaseEndpoint.getFullUrl(endpoint.path ?? '')
      );
      if (!response.success) {
        throw Exception(response.message ?? 'Failed to remove member');
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 403) {
        throw Exception('Bạn không có quyền xóa thành viên');
      }
      print('Error in removeMember: $e');
      rethrow;
    }
  }

  Future<void> leaveGroup(String groupId) async {
    try {
      final endpoint = GroupEndpoints.leaveGroup(groupId);
      final response = await _apiProvider.delete(
        BaseEndpoint.getFullUrl(endpoint.path ?? '')
      );
      if (!response.success) {
        throw Exception(response.message ?? 'Failed to leave group');
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        throw Exception('Creator không thể rời nhóm');
      }
      print('Error in leaveGroup: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getGroupMessages(String groupId, {int page = 1, int limit = 20}) async {
    try {
      final response = await _apiProvider.get(
        '/messages/group/$groupId',
        params: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );
      return {
        'messages': (response.data['messages'] as List)
            .map((msg) => GroupMessage.fromJson(msg))
            .toList(),
        'hasMore': response.data['hasMore'],
        'total': response.data['total'],
      };
    } catch (e) {
      throw Exception('Failed to load group messages: $e');
    }
  }
} 