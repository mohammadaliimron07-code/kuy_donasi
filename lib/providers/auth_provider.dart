import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { admin, member }

class AuthProvider extends ChangeNotifier {
  static const String _usersKey = 'databaseUser';
  static const String _savedAccountsKey = 'savedAccounts';

  String? _name;
  String? _email;
  UserRole? _role;
  String? _focus;
  SharedPreferences? _prefs;

  // Persistent storage for user data
  Map<String, Map<String, String>> databaseUser = {};
  List<String> _savedAccounts = [];

  String? get name => _name;
  String? get email => _email;
  UserRole? get role => _role;
  String? get focus => _focus;
  bool get isAuthenticated => _email != null;
  bool get isAdmin => _role == UserRole.admin;
  List<String> get savedAccounts => _savedAccounts;

  int get totalUsers => databaseUser.length;

  Map<String, int> get focusCounts {
    final counts = <String, int>{
      'Pendidikan': 0,
      'Kesehatan': 0,
      'Kemanusiaan': 0,
      'Lingkungan': 0,
    };
    for (final entry in databaseUser.values) {
      final focus = entry['focus'];
      if (focus != null && counts.containsKey(focus)) {
        counts[focus] = counts[focus]! + 1;
      }
    }
    return counts;
  }

  String get topFocus {
    if (databaseUser.isEmpty) return 'Tidak ada data';
    final sorted = focusCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.value == 0 ? 'Tidak ada data' : sorted.first.key;
  }

  List<Map<String, String>> get registeredUsers {
    return databaseUser.entries.map((entry) {
      return {
        'name': entry.value['name'] ?? '',
        'email': entry.key,
        'focus': entry.value['focus'] ?? '-',
      };
    }).toList();
  }

  // Initialize shared preferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Load stored users
    final storedUsers = _prefs?.getString(_usersKey);
    if (storedUsers != null && storedUsers.isNotEmpty) {
      final decoded = jsonDecode(storedUsers) as Map<String, dynamic>;
      databaseUser = decoded.map((key, value) => MapEntry(
            key,
            Map<String, String>.from(value as Map),
          ));
    }

    // Load saved accounts
    final savedAccountsJson = _prefs?.getString(_savedAccountsKey);
    if (savedAccountsJson != null && savedAccountsJson.isNotEmpty) {
      _savedAccounts = List<String>.from(jsonDecode(savedAccountsJson) as List);
    }

    // Check if user was previously logged in
    final savedEmail = _prefs?.getString('email');
    final savedName = _prefs?.getString('name');
    final savedRole = _prefs?.getString('role');
    final savedFocus = _prefs?.getString('focus');
    if (savedEmail != null && savedName != null && savedRole != null) {
      _email = savedEmail;
      _name = savedName;
      _role = savedRole == 'admin' ? UserRole.admin : UserRole.member;
      _focus = savedFocus;
      notifyListeners();
    }
  }

  Future<void> _saveUsers() async {
    final encoded = jsonEncode(databaseUser);
    await _prefs?.setString(_usersKey, encoded);
  }

  Future<bool> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Special case for admin
    if (email == 'admin@kuy.com' && password == 'admin') {
      _email = email;
      _name = 'Administrator';
      _role = UserRole.admin;
      _focus = null;
      await _saveSession();
      notifyListeners();
      return true;
    }

    // Check stored user credentials
    if (databaseUser.containsKey(email) && databaseUser[email]!['password'] == password) {
      _email = email;
      _name = databaseUser[email]!['name'];
      _role = UserRole.member;
      _focus = databaseUser[email]!['focus'];
      await _saveSession();
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<bool> register({required String name, required String email, required String password, required String focus}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if email already exists
    if (databaseUser.containsKey(email)) {
      return false; // Email already taken
    }

    // Save new user data to persistent storage
    databaseUser[email] = {
      'name': name,
      'password': password,
      'focus': focus,
    };
    await _saveUsers();

    // Auto-login after register
    _email = email;
    _name = name;
    _role = UserRole.member;
    _focus = focus;
    await _saveSession();
    notifyListeners();
    return true;
  }

  Future<void> _saveSession() async {
    await _prefs?.setString('email', _email!);
    await _prefs?.setString('name', _name!);
    await _prefs?.setString('role', _role == UserRole.admin ? 'admin' : 'member');
    if (_focus != null) {
      await _prefs?.setString('focus', _focus!);
    }
    // Save account to saved accounts list
    await _addToSavedAccounts(_email!);
  }

  Future<void> _addToSavedAccounts(String email) async {
    if (!_savedAccounts.contains(email)) {
      _savedAccounts.add(email);
      await _prefs?.setString(_savedAccountsKey, jsonEncode(_savedAccounts));
      notifyListeners();
    }
  }

  Future<void> removeSavedAccount(String email) async {
    _savedAccounts.remove(email);
    await _prefs?.setString(_savedAccountsKey, jsonEncode(_savedAccounts));
    notifyListeners();
  }

  Future<bool> quickLogin({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Special case for admin
    if (email == 'admin@kuy.com') {
      _email = email;
      _name = 'Administrator';
      _role = UserRole.admin;
      _focus = null;
      await _saveSession();
      notifyListeners();
      return true;
    }

    // Check stored user credentials
    if (databaseUser.containsKey(email)) {
      _email = email;
      _name = databaseUser[email]!['name'];
      _role = UserRole.member;
      _focus = databaseUser[email]!['focus'];
      await _saveSession();
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<void> logout() async {
    _name = null;
    _email = null;
    _role = null;
    _focus = null;
    await _prefs?.remove('email');
    await _prefs?.remove('name');
    await _prefs?.remove('role');
    await _prefs?.remove('focus');
    notifyListeners();
  }

  Future<void> deleteUser(String email, {required bool isAdmin}) async {
    if (!isAdmin) throw Exception("Hanya Admin yang dapat menghapus user!");
    databaseUser.remove(email);
    await _saveUsers();
    notifyListeners();
  }
}
