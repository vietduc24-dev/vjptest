import '../../base/base_enpoint.dart';
import '../../base/method_request.dart';

class GroupEndpoints {
  static String get _basePath => '/groups';

  static EndpointType createGroup() {
    return EndpointType(
      path: _basePath,
      httpMethod: HttpMethod.post,
      header: DefaultHeader.instance.addDefaultHeader(),
    );
  }

  static EndpointType getGroups() {
    return EndpointType(
      path: _basePath,
      httpMethod: HttpMethod.get,
      header: DefaultHeader.instance.addDefaultHeader(),
    );
  }

  static EndpointType getGroupInfo(String groupId) {
    return EndpointType(
      path: '$_basePath/$groupId',
      httpMethod: HttpMethod.get,
      header: DefaultHeader.instance.addDefaultHeader(),
    );
  }

  static EndpointType addMember(String groupId) {
    return EndpointType(
      path: '$_basePath/$groupId/members',
      httpMethod: HttpMethod.post,
      header: DefaultHeader.instance.addDefaultHeader(),
    );
  }

  static EndpointType removeMember(String groupId, String username) {
    return EndpointType(
      path: '$_basePath/$groupId/members/$username',
      httpMethod: HttpMethod.delete,
      header: DefaultHeader.instance.addDefaultHeader(),
    );
  }

  static EndpointType leaveGroup(String groupId) {
    return EndpointType(
      path: '$_basePath/$groupId/leave',
      httpMethod: HttpMethod.delete,
      header: DefaultHeader.instance.addDefaultHeader(),
    );
  }

  static EndpointType getGroupMessages(String groupId) {
    return EndpointType(
      path: '$_basePath/$groupId/messages',
      httpMethod: HttpMethod.get,
      header: DefaultHeader.instance.addDefaultHeader(),
    );
  }

  static EndpointType uploadImage() {
    return EndpointType(
      path: '$_basePath/upload-image',
      httpMethod: HttpMethod.post,
      header: DefaultHeader.instance.addDefaultHeader(),
    );
  }
} 