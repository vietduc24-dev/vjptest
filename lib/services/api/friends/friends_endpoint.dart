import '../../base/base_enpoint.dart';
import '../../base/method_request.dart';

class FriendsEndpoint {
  // Get all friends
  static EndpointType getFriendsList() => EndpointType(
        path: BaseEndpoint.getFullUrl('/friends'),
        httpMethod: HttpMethod.get,
        header: DefaultHeader.instance.addDefaultHeader(),
      );

  // Get friend requests
  static EndpointType getFriendRequests() => EndpointType(
        path: BaseEndpoint.getFullUrl('/friends/requests'),
        httpMethod: HttpMethod.get,
        header: DefaultHeader.instance.addDefaultHeader(),
      );

  // Send friend request
  static EndpointType sendFriendRequest() => EndpointType(
        path: BaseEndpoint.getFullUrl('/friends/requests'),
        httpMethod: HttpMethod.post,
        header: DefaultHeader.instance.addDefaultHeader(),
      );

  // Accept friend request
  static EndpointType acceptFriendRequest(String username) => EndpointType(
        path: BaseEndpoint.getFullUrl('/friends/requests/$username/accept'),
        httpMethod: HttpMethod.put,
        header: DefaultHeader.instance.addDefaultHeader(),
      );

  // Reject friend request
  static EndpointType rejectFriendRequest(String username) => EndpointType(
        path: BaseEndpoint.getFullUrl('/friends/requests/$username'),
        httpMethod: HttpMethod.delete,
        header: DefaultHeader.instance.addDefaultHeader(),
      );
}
