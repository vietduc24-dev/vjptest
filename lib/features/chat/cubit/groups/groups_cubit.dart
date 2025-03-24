import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:io';
import '../../../../services/websocket/chatgroup/group_message.dart';
import '../../../../features/chat/repository/groups/group_repository.dart';
import 'groups_state.dart';

class GroupsCubit extends Cubit<GroupsState> {
  final GroupRepository _groupRepository;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;
  int _currentPage = 1;
  static const int _messagesPerPage = 20;

  GroupsCubit(this._groupRepository) : super(const GroupsState());

  Future<void> loadGroups() async {
    try {
      emit(state.copyWith(status: GroupsStatus.loading));
      final groups = await _groupRepository.getGroups();
      emit(state.copyWith(
        groups: groups,
        status: GroupsStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GroupsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> createGroup(String name, List<String> members) async {
    try {
      emit(state.copyWith(status: GroupsStatus.creating));
      final group = await _groupRepository.createGroup(name, members);
      final updatedGroups = [...state.groups, group];
      emit(state.copyWith(
        groups: updatedGroups,
        status: GroupsStatus.created,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GroupsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> selectGroup(String groupId) async {
    try {
      final group = await _groupRepository.getGroupInfo(groupId);
      emit(state.copyWith(selectedGroup: group));
    } catch (e) {
      emit(state.copyWith(
        status: GroupsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> addMember(String username) async {
    if (state.selectedGroup == null) return;
    
    try {
      emit(state.copyWith(status: GroupsStatus.addingMember));
      await _groupRepository.addMember(state.selectedGroup!.id, username);
      
      // Refresh group info
      final updatedGroup = await _groupRepository.getGroupInfo(state.selectedGroup!.id);
      emit(state.copyWith(
        selectedGroup: updatedGroup,
        status: GroupsStatus.memberAdded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GroupsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> removeMember(String username) async {
    if (state.selectedGroup == null) return;

    try {
      emit(state.copyWith(status: GroupsStatus.removingMember));
      await _groupRepository.removeMember(state.selectedGroup!.id, username);
      
      // Refresh group info
      final updatedGroup = await _groupRepository.getGroupInfo(state.selectedGroup!.id);
      emit(state.copyWith(
        selectedGroup: updatedGroup,
        status: GroupsStatus.memberRemoved,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GroupsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> leaveGroup() async {
    if (state.selectedGroup == null) return;

    try {
      emit(state.copyWith(status: GroupsStatus.leaving));
      await _groupRepository.leaveGroup(state.selectedGroup!.id);
      
      // Remove group from list
      final updatedGroups = state.groups
          .where((group) => group.id != state.selectedGroup!.id)
          .toList();
      
      emit(state.copyWith(
        groups: updatedGroups,
        selectedGroup: null,
        status: GroupsStatus.left,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GroupsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> initializeGroupChat({
    required String groupId,
    required String wsUrl,
    required String currentUserId,
  }) async {
    try {
      await _groupRepository.initializeGroupChat(
        groupId: groupId,
        wsUrl: wsUrl,
        currentUserId: currentUserId,
      );

      _messageSubscription?.cancel();
      _typingSubscription?.cancel();

      _messageSubscription = _groupRepository.messageStream?.listen(_handleNewMessage);
      _typingSubscription = _groupRepository.typingStream?.listen(_handleTypingStatus);

      emit(state.copyWith(status: GroupsStatus.chatting));
    } catch (e) {
      emit(state.copyWith(
        status: GroupsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _handleNewMessage(GroupMessage message) {
    print('GroupsCubit handling new message:');
    print('- sender: ${message.sender}');
    print('- content: ${message.content}');
    print('- attachmentUrl: ${message.attachmentUrl}');
    print('- attachmentType: ${message.attachmentType}');

    final updatedMessages = [message, ...state.messages];
    emit(state.copyWith(
      messages: updatedMessages,
      status: GroupsStatus.chatting,
    ));

    print('GroupsCubit state updated, messages count: ${state.messages.length}');
  }

  void _handleTypingStatus(Map<String, dynamic> status) {
    final userId = status['userId'] as String;
    final isTyping = status['isTyping'] as bool;
    
    final updatedTypingUsers = Map<String, bool>.from(state.typingUsers);
    updatedTypingUsers[userId] = isTyping;
    
    emit(state.copyWith(typingUsers: updatedTypingUsers));
  }

  void sendMessage(String content, {File? imageFile}) {
    try {
      if (_groupRepository == null) {
        throw Exception('Chat service not initialized');
      }
      print('Sending message through socket service');
      _groupRepository!.sendMessage(content, imageFile: imageFile);
    } catch (e) {
      emit(state.copyWith(
        status: GroupsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void updateTypingStatus(bool isTyping) {
    _groupRepository!.sendTypingStatus(isTyping);
  }

  Future<void> loadGroupMessages(String groupId, {bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        emit(state.copyWith(
          messages: [],
          hasMoreMessages: true,
        ));
      }

      if (!state.hasMoreMessages && !refresh) return;

      emit(state.copyWith(isLoadingMessages: true));

      final result = await _groupRepository!.getGroupMessages(
        groupId,
        page: _currentPage,
        limit: _messagesPerPage,
      );

      final newMessages = result['messages'] as List<GroupMessage>;
      final hasMore = result['hasMore'] as bool;
      final total = result['total'] as int;

      if (refresh) {
        emit(state.copyWith(
          messages: newMessages,
          isLoadingMessages: false,
          hasMoreMessages: hasMore,
          totalMessages: total,
        ));
      } else {
        emit(state.copyWith(
          messages: [...state.messages, ...newMessages],
          isLoadingMessages: false,
          hasMoreMessages: hasMore,
          totalMessages: total,
        ));
      }

      _currentPage++;
    } catch (e) {
      emit(state.copyWith(
        status: GroupsStatus.error,
        errorMessage: e.toString(),
        isLoadingMessages: false,
      ));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _groupRepository.disposeChat();
    return super.close();
  }
} 