import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:com_mock/mock_utils.dart' as mock;
import '../models/chat_message.dart';
import '../models/contact.dart';

/// Very small mock of a SignalR-like service that holds in-memory conversations
class SignalRMock {
  SignalRMock._();
  static final SignalRMock instance = SignalRMock._();

  final _conversations = <String, List<ChatMessage>>{};
  final _controllers = <String, StreamController<ChatMessage>>{};

  // Create mock contacts and initial messages
  void seed(List<Contact> contacts) {
    for (var c in contacts) {
      _conversations.putIfAbsent(c.id, () {
        if (kReleaseMode) {
          return [
            ChatMessage(
              id: '${c.id}-m1',
              fromId: c.id,
              text: 'Xin chào từ ${c.name}',
            ),
          ];
        }

        // In debug/dev use random messages
        return [
          ChatMessage(
            id: '${c.id}-m1',
            fromId: c.id,
            text: mock.randomMessage(),
          ),
        ];
      });
      _controllers.putIfAbsent(c.id, () => StreamController.broadcast());
    }
  }

  /// Seed conversations using a list of users (from MockAuthService). Expects objects with `id`, `name`, `avatarUrl`.
  void seedFromUsers(List<dynamic> users) {
    final contacts = users
        .map(
          (u) => Contact(
            id: u.id ?? u['id'],
            name: u.name ?? u['name'] ?? u['email'],
            avatarUrl: u.avatarUrl ?? '',
          ),
        )
        .toList();
    seed(contacts);
  }

  /// Simulate an auto-reply from the remote side after a short delay.
  void simulateAutoReply(String conversationId) {
    Future.delayed(const Duration(milliseconds: 800), () {
      final reply = ChatMessage(
        id: '${conversationId}-reply-${DateTime.now().millisecondsSinceEpoch}',
        fromId: conversationId,
        text: mock.randomMessage(),
      );
      sendMessage(conversationId, reply);
    });
  }

  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List<ChatMessage>.from(_conversations[conversationId] ?? []);
  }

  Stream<ChatMessage> subscribe(String conversationId) {
    return _controllers
        .putIfAbsent(conversationId, () => StreamController.broadcast())
        .stream;
  }

  Future<void> sendMessage(String conversationId, ChatMessage msg) async {
    _conversations.putIfAbsent(conversationId, () => []).add(msg);
    _controllers
        .putIfAbsent(conversationId, () => StreamController.broadcast())
        .add(msg);
  }
}
