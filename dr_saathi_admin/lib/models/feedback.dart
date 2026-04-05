class Feedback {
  final String id;
  final String userId;
  final String userName;
  final String userType; // 'patient' or 'doctor'
  final String subject;
  final String message;
  final String category; // 'bug', 'feature', 'complaint', 'suggestion', 'other'
  final int rating; // 1-5 stars
  final String status; // 'new', 'in_progress', 'resolved', 'closed'
  final String? response;
  final String? respondedBy;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? userEmail;
  final String? userPhone;

  Feedback({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userType,
    required this.subject,
    required this.message,
    required this.category,
    required this.rating,
    required this.status,
    this.response,
    this.respondedBy,
    required this.createdAt,
    this.respondedAt,
    this.userEmail,
    this.userPhone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userType': userType,
      'subject': subject,
      'message': message,
      'category': category,
      'rating': rating,
      'status': status,
      'response': response,
      'respondedBy': respondedBy,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
      'userEmail': userEmail,
      'userPhone': userPhone,
    };
  }

  factory Feedback.fromMap(Map<String, dynamic> map) {
    return Feedback(
      id: map['id'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      userType: map['userType'] as String,
      subject: map['subject'] as String,
      message: map['message'] as String,
      category: map['category'] as String,
      rating: map['rating'] as int,
      status: map['status'] as String,
      response: map['response'] as String?,
      respondedBy: map['respondedBy'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      respondedAt: map['respondedAt'] != null
          ? DateTime.parse(map['respondedAt'] as String)
          : null,
      userEmail: map['userEmail'] as String?,
      userPhone: map['userPhone'] as String?,
    );
  }

  Feedback copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userType,
    String? subject,
    String? message,
    String? category,
    int? rating,
    String? status,
    String? response,
    String? respondedBy,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? userEmail,
    String? userPhone,
  }) {
    return Feedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userType: userType ?? this.userType,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      response: response ?? this.response,
      respondedBy: respondedBy ?? this.respondedBy,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
    );
  }
}
