import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Transaction {
  final String id;
  final String campaignTitle;
  final String category;
  final double amount;
  final DateTime date;
  final String status; // 'Terverifikasi', 'Menunggu Verifikasi', 'Gagal'

  Transaction({
    required this.id,
    required this.campaignTitle,
    required this.category,
    required this.amount,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaignTitle': campaignTitle,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      campaignTitle: map['campaignTitle'],
      category: map['category'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      status: map['status'],
    );
  }
}

class Feedback {
  final String id;
  final String type; // 'bug', 'feature', 'improvement'
  final String title;
  final String description;
  final DateTime date;
  final String status; // 'Baru', 'Ditinjau', 'Disetujui', 'Ditolak'

  Feedback({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'status': status,
    };
  }

  factory Feedback.fromMap(Map<String, dynamic> map) {
    return Feedback(
      id: map['id'],
      type: map['type'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      status: map['status'],
    );
  }
}

class DonationProvider extends ChangeNotifier {
  static const String _transactionsKey = 'donationTransactions';
  static const String _feedbackKey = 'userFeedback';

  List<Transaction> _transactions = [];
  List<Feedback> _feedbackList = [];
  SharedPreferences? _prefs;

  List<Transaction> get transactions => _transactions;
  List<Feedback> get feedbackList => _feedbackList;

  double get totalDonated {
    return _transactions
        .where((t) => t.status == 'Terverifikasi')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  int get totalDonations => _transactions.length;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadTransactions();
    await _loadFeedback();
  }

  Future<void> _loadTransactions() async {
    final data = _prefs?.getString(_transactionsKey);
    if (data != null && data.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(data);
      _transactions = decoded
          .map((item) => Transaction.fromMap(item as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  Future<void> _loadFeedback() async {
    final data = _prefs?.getString(_feedbackKey);
    if (data != null && data.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(data);
      _feedbackList = decoded
          .map((item) => Feedback.fromMap(item as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  Future<void> _saveTransactions() async {
    final encoded = jsonEncode(_transactions.map((t) => t.toMap()).toList());
    await _prefs?.setString(_transactionsKey, encoded);
  }

  Future<void> _saveFeedback() async {
    final encoded = jsonEncode(_feedbackList.map((f) => f.toMap()).toList());
    await _prefs?.setString(_feedbackKey, encoded);
  }

  Future<bool> addTransaction({
    required String campaignTitle,
    required String category,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      campaignTitle: campaignTitle,
      category: category,
      amount: amount,
      date: DateTime.now(),
      status: 'Menunggu Verifikasi',
    );

    _transactions.add(transaction);
    await _saveTransactions();
    notifyListeners();
    return true;
  }

  Future<bool> submitFeedback({
    required String type,
    required String title,
    required String description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final feedback = Feedback(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: title,
      description: description,
      date: DateTime.now(),
      status: 'Baru',
    );

    _feedbackList.add(feedback);
    await _saveFeedback();
    notifyListeners();
    return true;
  }

  List<Transaction> getTransactionsByCategory(String category) {
    return _transactions.where((t) => t.category == category).toList();
  }

  double getTotalByCategory(String category) {
    return getTransactionsByCategory(category)
        .where((t) => t.status == 'Terverifikasi')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<bool> updateFeedbackStatus(String id, String newStatus, {required bool isAdmin}) async {
    if (!isAdmin) throw Exception("Hanya Admin yang dapat mengubah status feedback!");
    final index = _feedbackList.indexWhere((f) => f.id == id);
    if (index != -1) {
      final old = _feedbackList[index];
      _feedbackList[index] = Feedback(
        id: old.id,
        type: old.type,
        title: old.title,
        description: old.description,
        date: old.date,
        status: newStatus,
      );
      await _saveFeedback();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateTransactionStatus(String id, String newStatus, {required bool isAdmin}) async {
    if (!isAdmin) throw Exception("Hanya Admin yang dapat memvalidasi donasi!");
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      final old = _transactions[index];
      _transactions[index] = Transaction(
        id: old.id,
        campaignTitle: old.campaignTitle,
        category: old.category,
        amount: old.amount,
        date: old.date,
        status: newStatus,
      );
      await _saveTransactions();
      notifyListeners();
      return true;
    }
    return false;
  }
}
