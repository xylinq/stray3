import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_user.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final _apiService = ApiService();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  AuthUser? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';

  AuthUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');

      if (userJson != null) {
        final userData = json.decode(userJson);
        _currentUser = AuthUser.fromJson(userData);
        notifyListeners();
      }
    } catch (e) {
      print('Error initializing auth: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      Map res = await _apiService.post('users/login', {'email': email, 'password': password});

      if (res['code'] != 200) {
         _errorMessage = res['msg'];
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = AuthUser.fromJson(res['data']);

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', json.encode(_currentUser!.toJson()));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '登录失败，请重试';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      Map res = await _apiService.post('users/register', {'name': name, 'email': email, 'password': password});

      if (res['code'] != 200) {
        _errorMessage = res['msg'];
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // // Create new user
      // final newUser = {
      //   'id': DateTime.now().millisecondsSinceEpoch.toString(),
      //   'email': email,
      //   'password': password,
      //   'name': name,
      //   'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&h=200&fit=crop&crop=face',
      //   'bio': 'New Pinterest user',
      //   'followers': 0,
      //   'following': 0,
      //   'pins': 0,
      //   'verified': false,
      //   'website': '',
      //   'createdAt': DateTime.now().toIso8601String(),
      // };

      _currentUser = AuthUser.fromJson(res['data']);

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', json.encode(_currentUser!.toJson()));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '注册失败，请重试！';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;

    // Clear from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');

    notifyListeners();
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '发送重置密码邮件出错';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  Future<bool> updateProfile({String? name, String? bio, String? website}) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Update current user
      _currentUser = AuthUser(
        id: _currentUser!.id,
        email: _currentUser!.email,
        name: name ?? _currentUser!.name,
        role: _currentUser!.role,
        createdAt: _currentUser!.createdAt,
      );

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', json.encode(_currentUser!.toJson()));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
