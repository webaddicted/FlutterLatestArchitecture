class ChatMessageModel {
  String? messageId;
  String? friendId; // The friend document ID (email1-email2)
  String? senderEmail;
  String? receiverEmail;
  String? message;
  MessageType? messageType;
  DateTime? timestamp;
  bool? isRead;
  String? mediaUrl;
  String? mediaType;
  
  ChatMessageModel({
    this.messageId,
    this.friendId,
    this.senderEmail,
    this.receiverEmail,
    this.message,
    this.messageType,
    this.timestamp,
    this.isRead,
    this.mediaUrl,
    this.mediaType,
  });

  ChatMessageModel.fromJson(Map<String, dynamic> json) {
    messageId = json['messageId'];
    friendId = json['friendId'];
    senderEmail = json['senderEmail'];
    receiverEmail = json['receiverEmail'];
    message = json['message'];
    messageType = json['messageType'] != null ? 
        MessageType.values.firstWhere((e) => e.name == json['messageType']) : 
        MessageType.text;
    timestamp = json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null;
    isRead = json['isRead'] ?? false;
    mediaUrl = json['mediaUrl'];
    mediaType = json['mediaType'];
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'friendId': friendId,
      'senderEmail': senderEmail,
      'receiverEmail': receiverEmail,
      'message': message,
      'messageType': messageType?.name,
      'timestamp': timestamp?.toIso8601String(),
      'isRead': isRead,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
    };
  }
}

enum MessageType {
  text,
  image,
  video,
  audio,
  document
} 