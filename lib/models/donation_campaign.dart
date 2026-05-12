class DonationCampaign {
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

  DonationCampaign({
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

  factory DonationCampaign.fromJson(Map<String, dynamic> json) {
    return DonationCampaign(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      status: json['status'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
      targetDate: DateTime.parse(json['targetDate'] as String),
      organizationName: json['organizationName'] as String,
      donorCount: json['donorCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
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
}
