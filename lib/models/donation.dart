class Donation {
  final String id;
  final String userId;
  final String campaignId;
  final String campaignTitle;
  final String category;
  final double amount;
  final String paymentMethod; // bank_transfer, e_wallet, qris
  final String status; // pending, completed, failed
  final DateTime transactionDate;
  final String? notes;
  final String? receiptUrl;

  Donation({
    required this.id,
    required this.userId,
    required this.campaignId,
    required this.campaignTitle,
    required this.category,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.transactionDate,
    this.notes,
    this.receiptUrl,
  });

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] as String,
      userId: json['userId'] as String,
      campaignId: json['campaignId'] as String,
      campaignTitle: json['campaignTitle'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      notes: json['notes'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'campaignId': campaignId,
      'campaignTitle': campaignTitle,
      'category': category,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionDate': transactionDate.toIso8601String(),
      'notes': notes,
      'receiptUrl': receiptUrl,
    };
  }
}
