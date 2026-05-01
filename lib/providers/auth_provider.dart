import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  String? _username;

  String? get username => _username;
  bool get isAuthenticated => _username != null;

  Future<bool> login({required String username, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Validasi dengan credentials spesifik
    if (username == 'admin' && password == '123456') {
      _username = username;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (email.isNotEmpty && password.isNotEmpty) {
      _username = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _username = null;
    notifyListeners();
  }
}
