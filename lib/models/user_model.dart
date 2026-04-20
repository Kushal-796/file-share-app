class UserModel {
  final String uid;
  final String shortCode;
  final String? fcmToken;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.shortCode,
    this.fcmToken,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'shortCode': shortCode,
      'fcmToken': fcmToken,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      shortCode: map['shortCode'] ?? '',
      fcmToken: map['fcmToken'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
