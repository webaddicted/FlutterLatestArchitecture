class FriendModel {
  String? friendId; // This will be email1-email2 format
  String? senderEmail;
  String? receiverEmail;
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
  
  FriendModel({
    this.friendId,
    this.senderEmail,
    this.receiverEmail,
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
  });

  FriendModel.fromJson(Map<String, dynamic> json) {
    friendId = json['friendId'];
    senderEmail = json['senderEmail'];
    receiverEmail = json['receiverEmail'];
    senderName = json['senderName'];
    receiverName = json['receiverName'];
    senderProfileImage = json['senderProfileImage'];
    receiverProfileImage = json['receiverProfileImage'];
    status = json['status'] != null ? 
        FriendStatus.values.firstWhere((e) => e.name == json['status']) : 
        FriendStatus.pending;
    requestedAt = json['requestedAt'] != null ? DateTime.parse(json['requestedAt']) : null;
    acceptedAt = json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt']) : null;
    lastMessage = json['lastMessage'];
    lastMessageTime = json['lastMessageTime'] != null ? DateTime.parse(json['lastMessageTime']) : null;
    lastMessageSender = json['lastMessageSender'];
  }

  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
      'senderEmail': senderEmail,
      'receiverEmail': receiverEmail,
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
    };
  }
}

enum FriendStatus {
  pending,
  accepted,
  declined,
  blocked
} 