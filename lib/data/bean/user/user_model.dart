class UserModel {
  String? uid;
  String? email;
  String? name;
  String? profileImage;
  String? phoneNumber;
  String? bio;
  String? gender;
  DateTime? lastSeen;
  bool? isOnline;
  DateTime? createdAt;
  int? spamMeReportedOtherCount; // Number of users this user has reported
  int? spamOtherReportedMeCount; // Number of times this user has been reported
  List<String>? fcmTokens;
  
  UserModel({
    this.uid,
    this.email,
    this.name,
    this.profileImage,
    this.phoneNumber,
    this.bio,
    this.gender,
    this.lastSeen,
    this.isOnline,
    this.createdAt,
    this.spamMeReportedOtherCount = 0,
    this.spamOtherReportedMeCount = 0,
    this.fcmTokens = const [],
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    email = json['email'];
    name = json['name'];
    profileImage = json['profileImage'];
    phoneNumber = json['phoneNumber'];
    bio = json['bio'];
    gender = json['gender'];
    lastSeen = json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null;
    isOnline = json['isOnline'] ?? false;
    createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    spamMeReportedOtherCount = json['spamMeReportedOtherCount'] ?? 0;
    spamOtherReportedMeCount = json['spamOtherReportedMeCount'] ?? 0;
    fcmTokens = List<String>.from(json['fcmTokens'] ?? []);
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profileImage': profileImage,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'gender': gender,
      'lastSeen': lastSeen?.toIso8601String(),
      'isOnline': isOnline,
      'createdAt': createdAt?.toIso8601String(),
      'spamMeReportedOtherCount': spamMeReportedOtherCount,
      'spamOtherReportedMeCount': spamOtherReportedMeCount,
      'fcmTokens': fcmTokens,
    };
  }
} 