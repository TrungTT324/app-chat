import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:com_mock/mock_utils.dart' as mock;
import '../models/contact.dart';
import '../chat/chat_screen.dart';
import '../../message/services/signalr_mock.dart';

class ContactsPage extends StatelessWidget {
  ContactsPage({super.key}) {
    // seed mock contacts once
    _seeded = true;
  }

  static bool _seeded = false;

  late final List<Contact> _contacts = _buildContacts();

  List<Contact> _buildContacts() {
    // In release mode, keep deterministic small list. In debug/develop use mock utils.
    if (kReleaseMode) {
      return [
        Contact(
          id: 'u1',
          name: 'Anh Trung',
          avatarUrl: 'https://i.pravatar.cc/150?img=1',
        ),
        Contact(
          id: 'u2',
          name: 'Lan',
          avatarUrl: 'https://i.pravatar.cc/150?img=2',
        ),
      ];
    }

    final generated = List.generate(8, (i) {
      final id = 'u\$i';
      return Contact(
        id: id,
        name: mock.randomName(),
        avatarUrl: mock.randomImage(w: 150, h: 150),
      );
    });

    // Always ensure ChatBot is the first contact
    final chatbot = Contact(
      id: 'chatbot',
      name: 'ChatBot',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
    );
    return [chatbot, ...generated];
  }

  @override
  Widget build(BuildContext context) {
    if (!_seeded) SignalRMock.instance.seed(_contacts);

    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: ListView.separated(
        itemCount: _contacts.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final c = _contacts[index];
          return ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(c.avatarUrl)),
            title: Text(c.name),
            subtitle: Text(c.isGroup ? 'Group' : 'Contact'),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => ChatScreen(contact: c)));
            },
          );
        },
      ),
    );
  }
}
