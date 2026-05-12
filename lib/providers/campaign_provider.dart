import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Campaign {
  final String id;
  final String title;
  final String description;
  final String category; // Pendidikan, Kesehatan, Kemanusiaan, Lingkungan
  final String imageUrl;
  final double targetAmount;
  final double currentAmount;
  final String status; // active, completed, pending
  final DateTime createdDate;
  final DateTime targetDate;
  final String organizationName;
  final int donorCount;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.targetAmount,
    required this.currentAmount,
    required this.status,
    required this.createdDate,
    required this.targetDate,
    required this.organizationName,
    required this.donorCount,
  });

  double get progressPercentage {
    if (targetAmount == 0) return 0;
    final percentage = (currentAmount / targetAmount) * 100;
    return percentage > 100 ? 100 : percentage;
  }

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'status': status,
      'createdDate': createdDate.toIso8601String(),
      'targetDate': targetDate.toIso8601String(),
      'organizationName': organizationName,
      'donorCount': donorCount,
    };
  }

  factory Campaign.fromMap(Map<String, dynamic> map) {
    return Campaign(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      imageUrl: map['imageUrl'] as String,
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currentAmount: (map['currentAmount'] as num).toDouble(),
      status: map['status'] as String,
      createdDate: DateTime.parse(map['createdDate'] as String),
      targetDate: DateTime.parse(map['targetDate'] as String),
      organizationName: map['organizationName'] as String,
      donorCount: map['donorCount'] as int? ?? 0,
    );
  }
}

class CampaignProvider extends ChangeNotifier {
  static const String _campaignsKey = 'campaigns';
  
  List<Campaign> _campaigns = [];
  SharedPreferences? _prefs;

  List<Campaign> get campaigns => _campaigns;

  List<Campaign> getCampaignsByCategory(String category) {
    return _campaigns.where((c) => c.category == category).toList();
  }

  List<Campaign> getActiveCampaigns() {
    return _campaigns.where((c) => c.isActive).toList();
  }

  Campaign? getCampaignById(String id) {
    try {
      return _campaigns.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadCampaigns();
    
    // Seed data jika belum ada
    if (_campaigns.isEmpty) {
      await _seedCampaigns();
    }
  }

  Future<void> _loadCampaigns() async {
    final stored = _prefs?.getString(_campaignsKey);
    if (stored != null && stored.isNotEmpty) {
      final decoded = jsonDecode(stored) as List;
      _campaigns.clear();
      _campaigns.addAll(
        decoded.map((c) => Campaign.fromMap(c as Map<String, dynamic>))
      );
      notifyListeners();
    }
  }

  Future<void> _saveCampaigns() async {
    final encoded = jsonEncode(_campaigns.map((c) => c.toMap()).toList());
    await _prefs?.setString(_campaignsKey, encoded);
  }

  Future<void> _seedCampaigns() async {
    final now = DateTime.now();
    final campaigns = [
      Campaign(
        id: '1',
        title: 'Program Beasiswa Penuh SMA Terpencil',
        description: 'Membantu 100 anak SMA di daerah terpencil mendapat akses pendidikan berkualitas.',
        category: 'Pendidikan',
        imageUrl: 'assets/images/education.jpg',
        targetAmount: 500000000,
        currentAmount: 250000000,
        status: 'active',
        createdDate: now.subtract(const Duration(days: 30)),
        targetDate: now.add(const Duration(days: 30)),
        organizationName: 'Yayasan Pendidikan Indonesia',
        donorCount: 1250,
      ),
      Campaign(
        id: '2',
        title: 'Vaksinasi & Kesehatan Gratis Desa Terpencil',
        description: 'Memberikan akses kesehatan dasar dan vaksinasi lengkap untuk 500 keluarga.',
        category: 'Kesehatan',
        imageUrl: 'assets/images/health.jpg',
        targetAmount: 300000000,
        currentAmount: 150000000,
        status: 'active',
        createdDate: now.subtract(const Duration(days: 15)),
        targetDate: now.add(const Duration(days: 45)),
        organizationName: 'Klinik Kesehatan Masyarakat',
        donorCount: 890,
      ),
      Campaign(
        id: '3',
        title: 'Rehabilitasi Rumah Korban Bencana Alam',
        description: 'Membangun kembali 50 rumah yang rusak akibat bencana alam tahun lalu.',
        category: 'Kemanusiaan',
        imageUrl: 'assets/images/house.jpg',
        targetAmount: 1000000000,
        currentAmount: 600000000,
        status: 'active',
        createdDate: now.subtract(const Duration(days: 45)),
        targetDate: now.add(const Duration(days: 15)),
        organizationName: 'Relawan Kemanusiaan Indonesia',
        donorCount: 3450,
      ),
      Campaign(
        id: '4',
        title: 'Penanaman 10.000 Pohon di Hutan Lindung',
        description: 'Program reboisasi untuk mengembalikan ekosistem hutan yang terdegradasi.',
        category: 'Lingkungan',
        imageUrl: 'assets/images/tree.jpg',
        targetAmount: 200000000,
        currentAmount: 120000000,
        status: 'active',
        createdDate: now.subtract(const Duration(days: 60)),
        targetDate: now.add(const Duration(days: 60)),
        organizationName: 'Gerakan Hijau Indonesia',
        donorCount: 2100,
      ),
      Campaign(
        id: '5',
        title: 'Perpustakaan Keliling untuk Anak Jalanan',
        description: 'Menyediakan akses buku dan pendidikan informal untuk anak-anak di jalanan.',
        category: 'Pendidikan',
        imageUrl: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?q=80&w=2228&auto=format&fit=crop',
        targetAmount: 150000000,
        currentAmount: 150000000,
        status: 'completed',
        createdDate: now.subtract(const Duration(days: 90)),
        targetDate: now.subtract(const Duration(days: 10)),
        organizationName: 'Yayasan Literasi Anak',
        donorCount: 5230,
      ),
    ];
    
    _campaigns.addAll(campaigns);
    await _saveCampaigns();
    notifyListeners();
  }

  Future<void> addCampaign(Campaign campaign, {required bool isAdmin}) async {
    if (!isAdmin) throw Exception("Hanya Admin yang dapat membuat kampanye!");
    _campaigns.add(campaign);
    await _saveCampaigns();
    notifyListeners();
  }

  Future<void> updateCampaign(String id, Campaign campaign, {required bool isAdmin}) async {
    if (!isAdmin) throw Exception("Hanya Admin yang dapat mengubah kampanye!");
    final index = _campaigns.indexWhere((c) => c.id == id);
    if (index != -1) {
      _campaigns[index] = campaign;
      await _saveCampaigns();
      notifyListeners();
    }
  }

  Future<void> deleteCampaign(String id, {required bool isAdmin}) async {
    if (!isAdmin) throw Exception("Hanya Admin yang dapat menghapus kampanye!");
    _campaigns.removeWhere((c) => c.id == id);
    await _saveCampaigns();
    notifyListeners();
  }
}
