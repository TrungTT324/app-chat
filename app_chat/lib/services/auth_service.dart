import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:com_mock/mock_utils.dart' as mock;

/// Simple user model for the mock auth service.
class MockUser {
  final String id;
  final String email;
  final String name;
  final String password;
  final String token;
  final String avatarUrl;

  MockUser({
    required this.id,
    required this.email,
    required this.name,
    required this.password,
    required this.token,
    required this.avatarUrl,
  });
}

/// Simple auth result used by the mock service.
class AuthResult {
  final bool success;
  final String? token;
  final String? message;

  AuthResult.success(this.token) : success = true, message = null;

  AuthResult.failure(this.message) : success = false, token = null;
}

/// Authentication service interface. For now we expose a mock implementation.
abstract class AuthService {
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> register(String email, String password, {String? name});
  MockUser? currentUser();
  Future<void> logout();
}

/// A mock implementation of [AuthService] with in-memory mock users.
/// This simulates network latency and returns success when email/password
/// match one of the entries in [_mockUsers].
class MockAuthService implements AuthService {
  MockAuthService._() {
    _init();
  }
  static final MockAuthService instance = MockAuthService._();

  final List<MockUser> _users = [];
  MockUser? _current;

  void _init() {
    // Seed a couple of deterministic users for release/demo
    _users.addAll([
      MockUser(
        id: 'u_test',
        email: 'test@example.com',
        name: 'Test User',
        password: 'password123',
        token: 'mock-token-abc-123',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
      ),
      MockUser(
        id: 'u_trung',
        email: 'trung@xsofts.com',
        name: 'Trung',
        password: '123456',
        token: 'token-trung-456',
        avatarUrl: 'https://i.pravatar.cc/150?img=6',
      ),
    ]);

    // In debug/develop mode we can seed additional random users
    if (!kReleaseMode) seedMockUsers(6);
  }

  /// Seed additional mock users using the local mock package.
  void seedMockUsers([int count = 5]) {
    if (kReleaseMode) return;
    for (var i = 0; i < count; i++) {
      final name = mock.randomName();
      final id = 'u_mock_\$i';
      _users.add(
        MockUser(
          id: id,
          email: name.replaceAll(' ', '.').toLowerCase() + '@example.com',
          name: name,
          password: 'password',
          token: 'token-\$id',
          avatarUrl: mock.randomImage(w: 150, h: 150),
        ),
      );
    }
  }

  @override
  Future<AuthResult> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final user = _users.firstWhere(
        (u) =>
            u.email.toLowerCase() == email.trim().toLowerCase() &&
            u.password == password,
      );
      _current = user;
      return AuthResult.success(user.token);
    } catch (_) {
      return AuthResult.failure('Email hoặc mật khẩu không đúng');
    }
  }

  @override
  Future<AuthResult> register(
    String email,
    String password, {
    String? name,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final id = 'u_reg_\${DateTime.now().millisecondsSinceEpoch}';
    final user = MockUser(
      id: id,
      email: email,
      name: name ?? email.split('@').first,
      password: password,
      token: 'token-\$id',
      avatarUrl: mock.randomImage(w: 150, h: 150),
    );
    _users.add(user);
    _current = user;
    return AuthResult.success(user.token);
  }

  @override
  MockUser? currentUser() => _current;

  @override
  Future<void> logout() async {
    _current = null;
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// Return a copy of mock users (for debug/testing)
  List<MockUser> listUsers() => List<MockUser>.from(_users);
}
