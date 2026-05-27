import 'dart:async';

import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../models/chat_message.dart';
import '../services/signalr_mock.dart';
import '../services/llm_service.dart';

class ChatScreen extends StatefulWidget {
  final Contact contact;

  const ChatScreen({super.key, required this.contact});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <ChatMessage>[];
  StreamSubscription<ChatMessage>? _sub;

  @override
  void initState() {
    super.initState();
    _load();
    _sub = SignalRMock.instance.subscribe(widget.contact.id).listen((m) {
      setState(() => _messages.add(m));
      _scroll.jumpTo(_scroll.position.maxScrollExtent + 80);
    });
  }

  Future<void> _load() async {
    final msgs = await SignalRMock.instance.fetchMessages(widget.contact.id);
    setState(() => _messages.addAll(msgs));
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final msg = ChatMessage(
      id: '${widget.contact.id}-local-${DateTime.now().millisecondsSinceEpoch}',
      fromId: 'me',
      text: text,
    );
    SignalRMock.instance.sendMessage(widget.contact.id, msg);
    _controller.clear();
    setState(() => _messages.add(msg));
    // If ChatBot, use LLM service to generate reply (or mock fallback)
    if (widget.contact.id == 'chatbot') {
      LLMService.instance.chatReply(text).then((replyText) {
        final reply = ChatMessage(
          id: '${widget.contact.id}-llm-${DateTime.now().millisecondsSinceEpoch}',
          fromId: widget.contact.id,
          text: replyText,
        );
        SignalRMock.instance.sendMessage(widget.contact.id, reply);
      });
    } else {
      // Simulate a remote reply for demo purposes for regular contacts
      SignalRMock.instance.simulateAutoReply(widget.contact.id);
    }
    // scroll to bottom
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scroll.hasClients)
        _scroll.jumpTo(_scroll.position.maxScrollExtent + 80);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.contact.avatarUrl),
            ),
            const SizedBox(width: 8),
            Text(widget.contact.name),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final mine = m.fromId == 'me';
                return Align(
                  alignment: mine
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: mine ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(
                        color: mine ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _send, child: const Text('Gửi')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
