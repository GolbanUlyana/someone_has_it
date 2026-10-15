import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/item.dart';
import '../models/borrow_request.dart';
import '../models/user.dart';

class DatabaseService extends ChangeNotifier {
  static const String _itemsKey = 'items';
  static const String _requestsKey = 'requests';
  static const String _userKey = 'current_user';

  final List<Item> _items = [];
  final List<BorrowRequest> _requests = [];
  User? _currentUser;
  bool _initialized = false;

  List<Item> get items => List.unmodifiable(_items);
  List<BorrowRequest> get requests => List.unmodifiable(_requests);
  User? get currentUser => _currentUser;
  bool get initialized => _initialized;

  List<Item> get myItems =>
      _items.where((i) => i.ownerId == _currentUser?.id).toList();

  List<Item> get availableItems =>
      _items.where((i) => i.status == ItemStatus.available).toList();

  List<BorrowRequest> get incomingRequests =>
      _requests.where((r) => r.ownerId == _currentUser?.id).toList();

  List<BorrowRequest> get outgoingRequests =>
      _requests.where((r) => r.requesterId == _currentUser?.id).toList();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Завантажуємо користувача
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
    } else {
      // Створюємо демо-користувача
      _currentUser = User(
        id: const Uuid().v4(),
        name: 'Ви',
        apartment: 'Кв. 42',
      );
      await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
    }

    // Завантажуємо речі
    final itemsJson = prefs.getString(_itemsKey);
    if (itemsJson != null) {
      final List<dynamic> list = jsonDecode(itemsJson);
      _items.clear();
      _items.addAll(list.map((e) => Item.fromJson(e)));
    } else {
      // Демо-дані
      _loadDemoData();
      await _saveItems();
    }

    // Завантажуємо запити
    final requestsJson = prefs.getString(_requestsKey);
    if (requestsJson != null) {
      final List<dynamic> list = jsonDecode(requestsJson);
      _requests.clear();
      _requests.addAll(list.map((e) => BorrowRequest.fromJson(e)));
    }

    _initialized = true;
    notifyListeners();
  }

  void _loadDemoData() {
    _items.addAll([
      Item(
        id: const Uuid().v4(),
        title: 'Дриль Bosch',
        description: 'Потужний дриль, ідеальний для домашніх робіт',
        category: ItemCategory.tools,
        ownerId: 'demo-1',
        ownerName: 'Олена',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Item(
        id: const Uuid().v4(),
        title: 'Драбина 3м',
        description: 'Алюмінієва драбина, 3 метри',
        category: ItemCategory.tools,
        ownerId: 'demo-2',
        ownerName: 'Михайло',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Item(
        id: const Uuid().v4(),
        title: 'Намет 4 місця',
        description: 'Великий намет для сімейного відпочинку',
        category: ItemCategory.sports,
        ownerId: 'demo-3',
        ownerName: 'Ірина',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Item(
        id: const Uuid().v4(),
        title: 'Блендер Philips',
        description: 'Потужний блендер для смузі',
        category: ItemCategory.kitchen,
        ownerId: 'demo-4',
        ownerName: 'Андрій',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Item(
        id: const Uuid().v4(),
        title: 'Гра "Монополія"',
        description: 'Класична настільна гра',
        category: ItemCategory.games,
        ownerId: 'demo-5',
        ownerName: 'Софія',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }

  Future<void> addItem(Item item) async {
    _items.insert(0, item);
    await _saveItems();
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _saveItems();
    notifyListeners();
  }

  Future<void> updateItem(Item item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
      await _saveItems();
      notifyListeners();
    }
  }

  Future<void> addRequest(BorrowRequest request) async {
    _requests.insert(0, request);
    await _saveRequests();
    notifyListeners();
  }

  Future<void> updateRequest(BorrowRequest request) async {
    final index = _requests.indexWhere((r) => r.id == request.id);
    if (index != -1) {
      _requests[index] = request;
      
      // Оновлюємо статус речі
      if (request.status == RequestStatus.approved) {
        final itemIndex = _items.indexWhere((i) => i.id == request.itemId);
        if (itemIndex != -1) {
          _items[itemIndex] = _items[itemIndex].copyWith(
            status: ItemStatus.borrowed,
            borrowedBy: request.requesterName,
            returnDate: request.returnDate,
          );
          await _saveItems();
        }
      } else if (request.status == RequestStatus.returned) {
        final itemIndex = _items.indexWhere((i) => i.id == request.itemId);
        if (itemIndex != -1) {
          _items[itemIndex] = _items[itemIndex].copyWith(
            status: ItemStatus.available,
            borrowedBy: null,
          );
          await _saveItems();
        }
      }
      
      await _saveRequests();
      notifyListeners();
    }
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_items.map((i) => i.toJson()).toList());
    await prefs.setString(_itemsKey, json);
  }

  Future<void> _saveRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_requests.map((r) => r.toJson()).toList());
    await prefs.setString(_requestsKey, json);
  }
}