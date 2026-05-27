class Contact {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isGroup;

  Contact({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.isGroup = false,
  });
}
