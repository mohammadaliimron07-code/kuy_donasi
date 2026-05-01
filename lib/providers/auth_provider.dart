import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  String? _email;

  String? get email => _email;
  bool get isAuthenticated => _email != null;

  Future<bool> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (email.isNotEmpty && password.isNotEmpty) {
      _email = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (email.isNotEmpty && password.isNotEmpty) {
      _email = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _email = null;
    notifyListeners();
  }
}
