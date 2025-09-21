import 'package:flutter/foundation.dart';
import '../models/thing.dart';
import '../models/user.dart';
import '../services/datasource_service.dart';

class StrayProvider extends ChangeNotifier {
  final DatasourceService _datasourceService = DatasourceService();

  final List<Thing> _things = [];
  final List<User> _users = [];
  bool _isLoading = false;

  List<Thing> get things {
    return _things;
  }

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _datasourceService.loadData();
    // _pins = _dataService.getAllPins();
    // _users = _dataService.users;

    _isLoading = false;
    notifyListeners();
  }

  Thing? getThingById(int id) => _datasourceService.getThingById(id);
  User? getUserById(int id) => _datasourceService.getUserById(id);

  // Create Post functionality
  Future<Thing> createPost({
    required String desc,
    required String location,
    required String img,
    required String picker,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newThing = await _datasourceService.createPost(desc: desc, location: location, img: img, picker: picker);

      // Refresh pins to include the new post
      // _pins = _dataService.getAllPins();
      _isLoading = false;
      notifyListeners();

      return newThing;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
