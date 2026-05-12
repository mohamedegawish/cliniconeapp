import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../constants/endpoints.dart';
import '../models/user_model.dart';
import '../utils/api_exception.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _client = ApiClient();

  bool _isLoading = true;
  bool _isAuthenticated = false;
  UserModel? _user;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  UserModel? get user => _user;
  String? get role => _user?.role;
  String? get error => _error;

  AuthProvider() {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      try {
        final res = await _client.get(Endpoints.user);
        // Handle both wrapped {success, data: {...}} and flat {id, name, ...}
        final raw = res['data'] as Map<String, dynamic>? ?? res;
        _user = UserModel.fromJson(raw);
        _isAuthenticated = true;
      } on ApiException {
        await _storage.delete(key: 'auth_token');
        _isAuthenticated = false;
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _error = null;
    try {
      final res = await _client.post(Endpoints.login, data: {
        'email': email,
        'password': password,
      });

      // Accommodate both {data: {token, user}} and {token, user} shapes
      final payload = res['data'] as Map<String, dynamic>? ?? res;
      final token = (payload['access_token'] ?? payload['token']) as String?;
      final userData = payload['user'] as Map<String, dynamic>?;

      if (token == null) {
        _error = 'لم يتم استلام رمز المصادقة من الخادم';
        notifyListeners();
        return false;
      }

      await _storage.write(key: 'auth_token', value: token);
      _user = userData != null ? UserModel.fromJson(userData) : null;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.displayMessage;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _client.post(Endpoints.logout);
    } catch (_) {
      // Ignore — always clear local state
    }
    await _storage.delete(key: 'auth_token');
    _isAuthenticated = false;
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
