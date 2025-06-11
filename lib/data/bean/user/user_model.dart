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
    };
  }
} 