import 'package:equatable/equatable.dart';
import '../../../../services/api/groups/models/group.dart';
import '../../../../services/websocket/chatgroup/group_message.dart';

enum GroupsStatus {
  initial,
  loading,
  loaded,
  creating,
  created,
  error,
  addingMember,
  memberAdded,
  removingMember,
  memberRemoved,
  leaving,
  left,
  chatting,
}

class GroupsState extends Equatable {
  final List<Group> groups;
  final Group? selectedGroup;
  final GroupsStatus status;
  final String? errorMessage;
  final List<GroupMessage> messages;
  final Map<String, bool> typingUsers;
  final bool isLoadingMessages;
  final bool hasMoreMessages;
  final int totalMessages;

  const GroupsState({
    this.groups = const [],
    this.selectedGroup,
    this.status = GroupsStatus.initial,
    this.errorMessage,
    this.messages = const [],
    this.typingUsers = const {},
    this.isLoadingMessages = false,
    this.hasMoreMessages = true,
    this.totalMessages = 0,
  });

  GroupsState copyWith({
    List<Group>? groups,
    Group? selectedGroup,
    GroupsStatus? status,
    String? errorMessage,
    List<GroupMessage>? messages,
    Map<String, bool>? typingUsers,
    bool? isLoadingMessages,
    bool? hasMoreMessages,
    int? totalMessages,
  }) {
    return GroupsState(
      groups: groups ?? this.groups,
      selectedGroup: selectedGroup ?? this.selectedGroup,
      status: status ?? this.status,
      errorMessage: errorMessage,
      messages: messages ?? this.messages,
      typingUsers: typingUsers ?? this.typingUsers,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      totalMessages: totalMessages ?? this.totalMessages,
    );
  }

  @override
  List<Object?> get props => [
    groups,
    selectedGroup,
    status,
    errorMessage,
    messages,
    typingUsers,
    isLoadingMessages,
    hasMoreMessages,
    totalMessages,
  ];
}