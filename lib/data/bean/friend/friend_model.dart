import 'package:cloud_firestore/cloud_firestore.dart';

enum SpamStatus {
  reported,
  underReview,
  confirmed,
  resolved,
  falseReport
}

class SpamInfo {
  final bool isReported;
  final DateTime? reportedAt;
  final String? reportedBy;
  final String? reportReason;
  final int reportCount;
  final SpamStatus status;

  SpamInfo({
    this.isReported = false,
    this.reportedAt,
    this.reportedBy,
    this.reportReason,
    this.reportCount = 0,
    this.status = SpamStatus.reported,
  });

  factory SpamInfo.fromJson(Map<String, dynamic> json) {
    return SpamInfo(
      isReported: json['isReported'] ?? false,
      reportedAt: json['reportedAt'] != null ? (json['reportedAt'] as Timestamp).toDate() : null,
      reportedBy: json['reportedBy'],
      reportReason: json['reportReason'],
      reportCount: json['reportCount'] ?? 0,
      status: json['status'] != null 
          ? SpamStatus.values.firstWhere(
              (e) => e.name == json['status'],
              orElse: () => SpamStatus.reported,
            )
          : SpamStatus.reported,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isReported': isReported,
      'reportedAt': reportedAt,
      'reportedBy': reportedBy,
      'reportReason': reportReason,
      'reportCount': reportCount,
      'status': status.name,
    };
  }

  SpamInfo copyWith({
    bool? isReported,
    DateTime? reportedAt,
    String? reportedBy,
    String? reportReason,
    int? reportCount,
    SpamStatus? status,
  }) {
    return SpamInfo(
      isReported: isReported ?? this.isReported,
      reportedAt: reportedAt ?? this.reportedAt,
      reportedBy: reportedBy ?? this.reportedBy,
      reportReason: reportReason ?? this.reportReason,
      reportCount: reportCount ?? this.reportCount,
      status: status ?? this.status,
    );
  }
}

enum FriendStatus {
  pending,
  accepted,
  declined,
  blocked
}

class FriendModel {
  String? friendId;
  String? senderEmail;
  String? receiverEmail;
  String? senderUid;
  String? receiverUid;
  String? senderName;
  String? receiverName;
  String? senderProfileImage;
  String? receiverProfileImage;
  FriendStatus? status;
  DateTime? requestedAt;
  DateTime? acceptedAt;
  String? lastMessage;
  DateTime? lastMessageTime;
  String? lastMessageSender;
  SpamInfo? spamInfo;

  FriendModel({
    this.friendId,
    this.senderEmail,
    this.receiverEmail,
    this.senderUid,
    this.receiverUid,
    this.senderName,
    this.receiverName,
    this.senderProfileImage,
    this.receiverProfileImage,
    this.status,
    this.requestedAt,
    this.acceptedAt,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSender,
    this.spamInfo,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      friendId: json['friendId'],
      senderEmail: json['senderEmail'],
      receiverEmail: json['receiverEmail'],
      senderUid: json['senderUid'],
      receiverUid: json['receiverUid'],
      senderName: json['senderName'],
      receiverName: json['receiverName'],
      senderProfileImage: json['senderProfileImage'],
      receiverProfileImage: json['receiverProfileImage'],
      status: json['status'] != null ? FriendStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FriendStatus.pending,
      ) : null,
      requestedAt: json['requestedAt'] != null ? DateTime.parse(json['requestedAt']) : null,
      acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt']) : null,
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null ? DateTime.parse(json['lastMessageTime']) : null,
      lastMessageSender: json['lastMessageSender'],
      spamInfo: json['spamInfo'] != null ? SpamInfo.fromJson(json['spamInfo']) : SpamInfo(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
      'senderEmail': senderEmail,
      'receiverEmail': receiverEmail,
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'senderName': senderName,
      'receiverName': receiverName,
      'senderProfileImage': senderProfileImage,
      'receiverProfileImage': receiverProfileImage,
      'status': status?.name,
      'requestedAt': requestedAt?.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'lastMessageSender': lastMessageSender,
      'spamInfo': spamInfo?.toJson(),
    };
  }

  FriendModel copyWith({
    String? friendId,
    String? senderEmail,
    String? receiverEmail,
    String? senderUid,
    String? receiverUid,
    String? senderName,
    String? receiverName,
    String? senderProfileImage,
    String? receiverProfileImage,
    FriendStatus? status,
    DateTime? requestedAt,
    DateTime? acceptedAt,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSender,
    SpamInfo? spamInfo,
  }) {
    return FriendModel(
      friendId: friendId ?? this.friendId,
      senderEmail: senderEmail ?? this.senderEmail,
      receiverEmail: receiverEmail ?? this.receiverEmail,
      senderUid: senderUid ?? this.senderUid,
      receiverUid: receiverUid ?? this.receiverUid,
      senderName: senderName ?? this.senderName,
      receiverName: receiverName ?? this.receiverName,
      senderProfileImage: senderProfileImage ?? this.senderProfileImage,
      receiverProfileImage: receiverProfileImage ?? this.receiverProfileImage,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSender: lastMessageSender ?? this.lastMessageSender,
      spamInfo: spamInfo ?? this.spamInfo,
    );
  }
} 