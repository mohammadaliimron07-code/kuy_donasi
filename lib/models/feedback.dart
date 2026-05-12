class UserFeedback {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String type; // bug_report, feature_request, general_feedback
  final String subject;
  final String message;
  final String priority; // low, medium, high
  final String status; // pending, in_review, resolved
  final List<String> attachments;
  final DateTime createdDate;
  final DateTime? resolvedDate;
  final String? adminResponse;

  UserFeedback({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.type,
    required this.subject,
    required this.message,
    required this.priority,
    required this.status,
    required this.attachments,
    required this.createdDate,
    this.resolvedDate,
    this.adminResponse,
  });

  factory UserFeedback.fromJson(Map<String, dynamic> json) {
    return UserFeedback(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      type: json['type'] as String,
      subject: json['subject'] as String,
      message: json['message'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      attachments: List<String>.from(json['attachments'] as List? ?? []),
      createdDate: DateTime.parse(json['createdDate'] as String),
      resolvedDate: json['resolvedDate'] != null ? DateTime.parse(json['resolvedDate'] as String) : null,
      adminResponse: json['adminResponse'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'type': type,
      'subject': subject,
      'message': message,
      'priority': priority,
      'status': status,
      'attachments': attachments,
      'createdDate': createdDate.toIso8601String(),
      'resolvedDate': resolvedDate?.toIso8601String(),
      'adminResponse': adminResponse,
    };
  }
}
