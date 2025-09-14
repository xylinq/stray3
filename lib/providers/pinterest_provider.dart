import 'package:flutter/foundation.dart';
import '../models/pin.dart';
import '../models/user.dart';
import '../models/board.dart';
import '../services/data_service.dart';

class PinterestProvider extends ChangeNotifier {
  final DataService _dataService = DataService();
  
  List<Pin> _pins = [];
  List<Pin> _filteredPins = [];
  List<User> _users = [];
  List<Board> _boards = [];
  String _searchQuery = '';
  String _selectedCategory = '';
  bool _isLoading = false;

  List<Pin> get pins {
    if (_searchQuery.isNotEmpty || _selectedCategory.isNotEmpty) {
      return _filteredPins;
    }
    return _pins;
  }
  List<User> get users => _users;
  List<Board> get boards => _boards;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    await _dataService.loadData();
    _pins = _dataService.getAllPins();
    _users = _dataService.users;
    _boards = _dataService.boards;
    
    _isLoading = false;
    notifyListeners();
  }

  void searchPins(String query) {
    _searchQuery = query;
    _selectedCategory = '';
    
    if (query.isEmpty) {
      _filteredPins = [];
    } else {
      _filteredPins = _dataService.searchPins(query);
    }
    notifyListeners();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _searchQuery = '';
    
    if (category.isEmpty) {
      _filteredPins = [];
    } else {
      _filteredPins = _dataService.getPinsByCategory(category);
    }
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    _filteredPins = [];
    notifyListeners();
  }

  void toggleSavePin(String pinId) {
    _dataService.toggleSavePin(pinId);
    notifyListeners();
  }

  void toggleLikePin(String pinId) {
    _dataService.toggleLikePin(pinId);
    notifyListeners();
  }

  bool isPinSaved(String pinId) => _dataService.isPinSaved(pinId);
  bool isPinLiked(String pinId) => _dataService.isPinLiked(pinId);

  List<Pin> getSavedPins() => _dataService.getSavedPins();
  
  List<Pin> getCreatedPins() => _dataService.getCreatedPins();
  List<String> getCategories() => _dataService.getCategories();
  
  Pin? getPinById(String id) => _dataService.getPinById(id);
  User? getUserById(String id) => _dataService.getUserById(id);
  Board? getBoardById(String id) => _dataService.getBoardById(id);
  
  List<Pin> getRelatedPins(Pin currentPin) => _dataService.getRelatedPins(currentPin);
  
  void hidePin(String pinId) {
    _dataService.hidePin(pinId);
    // Remove from current pins list to hide immediately
    _pins.removeWhere((pin) => pin.id == pinId);
    _filteredPins.removeWhere((pin) => pin.id == pinId);
    notifyListeners();
  }
  
  void unhidePin(String pinId) {
    _dataService.unhidePin(pinId);
    // Reload pins to show the unhidden pin
    _pins = _dataService.getAllPins();
    if (_searchQuery.isNotEmpty) {
      searchPins(_searchQuery);
    } else if (_selectedCategory.isNotEmpty) {
      filterByCategory(_selectedCategory);
    }
    notifyListeners();
  }

  void toggleFollowUser(String userId) {
    _dataService.toggleFollowUser(userId);
    notifyListeners();
  }

  bool isUserFollowed(String userId) => _dataService.isUserFollowed(userId);
  List<String> getFollowedUsers() => _dataService.getFollowedUsers();

  // Create Post functionality
  Future<Pin> createPost({
    required String title,
    required String description,
    required String imageUrl,
    required List<String> tags,
    required String category,
    String? boardId,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final newPin = await _dataService.createPost(
        title: title,
        description: description,
        imageUrl: imageUrl,
        tags: tags,
        category: category,
        boardId: boardId,
      );
      
      // Refresh pins to include the new post
      _pins = _dataService.getAllPins();
      _isLoading = false;
      notifyListeners();
      
      return newPin;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get sample images for post creation
  List<String> getSampleImageUrls() => _dataService.getSampleImageUrls();
  
  // Get categories for post creation
  List<String> getPostCategories() => _dataService.getPostCategories();
}
