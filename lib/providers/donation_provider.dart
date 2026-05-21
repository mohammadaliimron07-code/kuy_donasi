import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Transaction {
  final String id;
  final String campaignTitle;
  final String category;
  final double amount;
  final DateTime date;
  final String status; // 'Terverifikasi', 'Menunggu Verifikasi', 'Ditolak'
  final String userEmail;
  final String paymentMethod;
  final String? receiptUrl;

  Transaction({
    required this.id,
    required this.campaignTitle,
    required this.category,
    required this.amount,
    required this.date,
    required this.status,
    required this.userEmail,
    required this.paymentMethod,
    this.receiptUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaignTitle': campaignTitle,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status,
      'userEmail': userEmail,
      'paymentMethod': paymentMethod,
      'receiptUrl': receiptUrl,
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
      userEmail: map['userEmail'] as String? ?? '',
      paymentMethod: map['paymentMethod'] as String? ?? 'Bank Transfer',
      receiptUrl: map['receiptUrl'] as String?,
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
  static const String _auditLogKey = 'adminAuditLogs';

  List<Transaction> _transactions = [];
  List<Feedback> _feedbackList = [];
  List<String> _auditLogs = [];
  SharedPreferences? _prefs;

  List<Transaction> get transactions => _transactions;
  List<Feedback> get feedbackList => _feedbackList;
  List<String> get auditLogs => _auditLogs;

  double get totalDonated {
    return _transactions
        .where((t) => t.status == 'Terverifikasi')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  int get totalDonations => _transactions.length;

  List<Transaction> get pendingTransactions {
    return _transactions.where((t) => t.status == 'Menunggu Verifikasi').toList();
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadTransactions();
    await _loadFeedback();
    await _loadAuditLogs();
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

  Future<void> _loadAuditLogs() async {
    final data = _prefs?.getString(_auditLogKey);
    if (data != null && data.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(data);
      _auditLogs = decoded.cast<String>().toList();
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

  Future<void> _saveAuditLogs() async {
    await _prefs?.setString(_auditLogKey, jsonEncode(_auditLogs));
  }

  Future<void> addAuditLogEntry(String message) async {
    await _addAuditLog(message);
  }

  Future<bool> addTransaction({
    required String campaignTitle,
    required String category,
    required double amount,
    required String userEmail,
    required String paymentMethod,
    String? receiptUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      campaignTitle: campaignTitle,
      category: category,
      amount: amount,
      date: DateTime.now(),
      status: 'Menunggu Verifikasi',
      userEmail: userEmail,
      paymentMethod: paymentMethod,
      receiptUrl: receiptUrl,
    );

    _transactions.add(transaction);
    await _saveTransactions();
    await _addAuditLog(
      '[${DateTime.now().toIso8601String()}] $userEmail mengirim bukti donasi Rp ${amount.toStringAsFixed(0)} ke program "${campaignTitle}". Status: Menunggu Verifikasi.',
    );
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

  double totalDonatedBy(String email) {
    return _transactions
        .where((t) => t.userEmail == email && t.status == 'Terverifikasi')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<void> _addAuditLog(String message) async {
    _auditLogs.insert(0, message);
    if (_auditLogs.length > 100) {
      _auditLogs = _auditLogs.sublist(0, 100);
    }
    await _saveAuditLogs();
    notifyListeners();
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

  Future<bool> updateTransactionStatus(String id, String newStatus, {required bool isAdmin, String? adminEmail}) async {
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
        userEmail: old.userEmail,
        paymentMethod: old.paymentMethod,
        receiptUrl: old.receiptUrl,
      );
      await _saveTransactions();
      final formattedAmount = old.amount.toStringAsFixed(0);
      await _addAuditLog(
        '[${DateTime.now().toIso8601String()}] ${adminEmail ?? 'Admin'} mengubah status donasi Rp $formattedAmount dari ${old.userEmail} pada program "${old.campaignTitle}" dari ${old.status} menjadi $newStatus.',
      );
      return true;
    }
    return false;
  }
}
