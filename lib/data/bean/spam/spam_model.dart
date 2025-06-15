import 'package:cloud_firestore/cloud_firestore.dart';
import '../friend/friend_model.dart';

class SpamModel {
  String? id;
  String? reporterEmail;
  String? reportedEmail;
  String? friendId;
  DateTime? reportedAt;
  String? reason;
  bool? isResolved;
  DateTime? resolvedAt;
  SpamStatus status;

  SpamModel({
    this.id,
    this.reporterEmail,
    this.reportedEmail,
    this.friendId,
    this.reportedAt,
    this.reason,
    this.isResolved = false,
    this.resolvedAt,
    this.status = SpamStatus.reported,
  });

  factory SpamModel.fromJson(Map<String, dynamic> json) {
    return SpamModel(
      id: json['id'],
      reporterEmail: json['reporterEmail'],
      reportedEmail: json['reportedEmail'],
      friendId: json['friendId'],
      reportedAt: json['reportedAt'] != null ? (json['reportedAt'] as Timestamp).toDate() : null,
      reason: json['reason'],
      isResolved: json['isResolved'] ?? false,
      resolvedAt: json['resolvedAt'] != null ? (json['resolvedAt'] as Timestamp).toDate() : null,
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
      'id': id,
      'reporterEmail': reporterEmail,
      'reportedEmail': reportedEmail,
      'friendId': friendId,
      'reportedAt': reportedAt,
      'reason': reason,
      'isResolved': isResolved,
      'resolvedAt': resolvedAt,
      'status': status.name,
    };
  }

  SpamModel copyWith({
    String? id,
    String? reporterEmail,
    String? reportedEmail,
    String? friendId,
    DateTime? reportedAt,
    String? reason,
    bool? isResolved,
    DateTime? resolvedAt,
    SpamStatus? status,
  }) {
    return SpamModel(
      id: id ?? this.id,
      reporterEmail: reporterEmail ?? this.reporterEmail,
      reportedEmail: reportedEmail ?? this.reportedEmail,
      friendId: friendId ?? this.friendId,
      reportedAt: reportedAt ?? this.reportedAt,
      reason: reason ?? this.reason,
      isResolved: isResolved ?? this.isResolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      status: status ?? this.status,
    );
  }
} 