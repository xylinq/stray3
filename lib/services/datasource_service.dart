import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/thing.dart';
import '../models/user.dart';

class DatasourceService {
  static final DatasourceService _instance = DatasourceService._internal();
  factory DatasourceService() => _instance;
  DatasourceService._internal();

  final _apiService = ApiService();
  final _authService = AuthService();

  List<Thing> _things = [];
  List<User> _users = [];
  final List<int> _likedThings = [];

  List<Thing> get things => List.unmodifiable(_things);
  List<User> get users => List.unmodifiable(_users);
  List<String> get likedPins => List.unmodifiable(_likedThings);

  Future<void> loadData() async {
    await Future.wait([
      _loadThings(),
      // _loadUsers(),
      // _loadUserData(), // Load saved data from SharedPreferences
    ]);
  }

  Future<void> _loadThings() async {
    try {
      final String response = await rootBundle.loadString('assets/data/pins.json');
      final List<dynamic> data = json.decode(response);
      _things = data.map((json) => Thing.fromJson(json)).toList();
    } catch (e) {
      print('Error loading pins: $e');
    }
  }

  Future<void> _loadUsers() async {
    try {
      final String response = await rootBundle.loadString('assets/data/users.json');
      final List<dynamic> data = json.decode(response);
      _users = data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  Thing? getThingById(int id) {
    try {
      return _things.firstWhere((thing) => thing.id == id);
    } catch (e) {
      return null;
    }
  }

  User? getUserById(int id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadUserData() async {
    // try {
    //   final prefs = await SharedPreferences.getInstance();

    //   // Load saved pins
    //   final savedPinsJson = prefs.getString('saved_pins');
    //   if (savedPinsJson != null) {
    //     final List<dynamic> savedList = json.decode(savedPinsJson);
    //     _savedPins.clear();
    //     _savedPins.addAll(savedList.cast<String>());
    //   }

    //   // Load liked pins
    //   final likedPinsJson = prefs.getString('liked_pins');
    //   if (likedPinsJson != null) {
    //     final List<dynamic> likedList = json.decode(likedPinsJson);
    //     _likedPins.clear();
    //     _likedPins.addAll(likedList.cast<String>());
    //   }

    //   // Load hidden pins
    //   final hiddenPinsJson = prefs.getString('hidden_pins');
    //   if (hiddenPinsJson != null) {
    //     final List<dynamic> hiddenList = json.decode(hiddenPinsJson);
    //     _hiddenPins.clear();
    //     _hiddenPins.addAll(hiddenList.cast<String>());
    //   }

    //   // Load followed users
    //   final followedUsersJson = prefs.getString('followed_users');
    //   if (followedUsersJson != null) {
    //     final List<dynamic> followedList = json.decode(followedUsersJson);
    //     _followedUsers.clear();
    //     _followedUsers.addAll(followedList.cast<String>());
    //   }

    //   // Load user created pins
    //   final userPinsJson = prefs.getString('user_pins');
    //   if (userPinsJson != null) {
    //     final List<dynamic> userPinsList = json.decode(userPinsJson);
    //     final userPins = userPinsList.map((json) => Pin.fromJson(json)).toList();
    //     _pins.addAll(userPins);
    //   }
    // } catch (e) {
    //   print('Error loading user data: $e');
    // }
  }

  // Create Post Functionality
  Future<Thing> createPost({
    required String desc,
    required String location,
    required String img,
    required String picker,
  }) async {
    final res = await _apiService.post('things/create', {
      'desc': desc,
      'location': location,
      'img': img,
      'picker': picker,
      'userId': _authService.currentUser!.id,
    });

    final newThing = Thing.fromJson(res['data']);

    // _pins.insert(0, newPin); // Add to beginning of list
    // await _saveUserData(); // Persist to storage
    return newThing;
  }
}
