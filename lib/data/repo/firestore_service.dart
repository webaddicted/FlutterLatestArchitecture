import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pingmexx/utils/common/global_utilities.dart';
import '../bean/user/user_model.dart';
import '../bean/friend/friend_model.dart';
import '../bean/chat/chat_message_model.dart';
import '../bean/spam/spam_model.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // App name as parent collection
  static const String appName = 'pingmexx';

  static const String usersCollection = 'users';
  static const String friendsCollection = 'friends';
  static const String messagesCollection = 'messages';
  static const String spamCollection = 'spam_reports';
  
  // Helper method to get collection reference under app name
  static CollectionReference _getCollection(String collectionName) {
    return _firestore.collection(appName).doc(usersCollection).collection(collectionName);
  }

  // Public getter for users collection reference
  static CollectionReference get usersCollectionRef =>
      _firestore.collection(appName).doc(usersCollection).collection(usersCollection);

  // User operations
  static Future<void> createUser(UserModel user) async {
    try {
      await _getCollection(usersCollection).doc(user.uid).set(user.toJson());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  static Future<UserModel?> getUser(String? uid) async {
    try {
      DocumentSnapshot doc = await _getCollection(usersCollection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Alias for getUser for consistency
  static Future<UserModel?> getUserById(String uid) async {
    return await getUser(uid);
  }

  // Update user data
  static Future<void> updateUser(UserModel user) async {
    try {
      await _getCollection(usersCollection).doc(user.uid).update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  static Future<List<UserModel>> searchUsers(String query) async {
    try {
      QuerySnapshot snapshot = await _getCollection(usersCollection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();

      List<UserModel> users = [];
      for (var doc in snapshot.docs) {
        users.add(UserModel.fromJson(doc.data() as Map<String, dynamic>));
      }
      return users;
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  static Future<List<UserModel>> searchUsersByEmail(String email) async {
    try {
      QuerySnapshot snapshot = await _getCollection(usersCollection)
          .where('email', isEqualTo: email)
          .get();

      List<UserModel> users = [];
      for (var doc in snapshot.docs) {
        users.add(UserModel.fromJson(doc.data() as Map<String, dynamic>));
      }
      return users;
    } catch (e) {
      throw Exception('Failed to search users by email: $e');
    }
  }

  static Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _getCollection(usersCollection)
          .orderBy('createdAt', descending: true)
          .get();

      List<UserModel> users = [];
      for (var doc in snapshot.docs) {
        users.add(UserModel.fromJson(doc.data() as Map<String, dynamic>));
      }
      return users;
    } catch (e) {
      throw Exception('Failed to get all users: $e');
    }
  }

  // Friend operations
  static String generateFriendId(String email1, String email2) {
    List<String> emails = [email1, email2];
    emails.sort();
    return '${emails[0]}-${emails[1]}';
  }

  static Future<void> sendFriendRequest(String receiverEmail) async {
    try {
      String currentUserEmail = _auth.currentUser?.email ?? '';
      if (currentUserEmail.isEmpty) throw Exception('User not authenticated');

      String friendId = generateFriendId(currentUserEmail, receiverEmail);
      
      // Get current user and receiver user details
      UserModel? currentUser = await getUser(_auth.currentUser!.uid);
      List<UserModel> receiverUsers = await searchUsersByEmail(receiverEmail);

      if (receiverUsers.isEmpty) {
        throw Exception('User not found');
      }
      printLog(msg: "sendFriendRequest ");
      UserModel receiverUser = receiverUsers.first;

      FriendModel friendRequest = FriendModel(
        friendId: friendId,
        senderEmail: currentUserEmail,
        receiverEmail: receiverEmail,
        senderUid: currentUser?.uid,
        receiverUid: receiverUser.uid,
        senderName: currentUser?.name,
        receiverName: receiverUser.name,
        senderProfileImage: currentUser?.profileImage,
        receiverProfileImage: receiverUser.profileImage,
        status: FriendStatus.pending,
        requestedAt: DateTime.now(),
      );

      await _getCollection(friendsCollection).doc(friendId).set(friendRequest.toJson());
    } catch (e) {
      printLog(msg: "sendFriendRequest $e");
      throw Exception('Failed to send friend request: $e');
    }
  }

  static Future<void> acceptFriendRequest(String friendId) async {
    try {
      await _getCollection(friendsCollection).doc(friendId).update({
        'status': FriendStatus.accepted.name,
        'acceptedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to accept friend request: $e');
    }
  }

  static Future<void> declineFriendRequest(String friendId) async {
    try {
      await _getCollection(friendsCollection).doc(friendId).update({
        'status': FriendStatus.declined.name,
      });
    } catch (e) {
      throw Exception('Failed to decline friend request: $e');
    }
  }

  static Future<List<FriendModel>> getFriends() async {
    try {
      String currentUserEmail = _auth.currentUser?.email ?? '';
      if (currentUserEmail.isEmpty) throw Exception('User not authenticated');

      QuerySnapshot snapshot = await _getCollection(friendsCollection)
          .where('status', isEqualTo: FriendStatus.accepted.name)
          .where('senderEmail', isEqualTo: currentUserEmail)
          .get();

      QuerySnapshot snapshot2 = await _getCollection(friendsCollection)
          .where('status', isEqualTo: FriendStatus.accepted.name)
          .where('receiverEmail', isEqualTo: currentUserEmail)
          .get();

      List<FriendModel> friends = [];
      for (var doc in snapshot.docs) {
        friends.add(FriendModel.fromJson(doc.data() as Map<String, dynamic>));
      }
      for (var doc in snapshot2.docs) {
        friends.add(FriendModel.fromJson(doc.data() as Map<String, dynamic>));
      }

      // Sort by last message time
      friends.sort((a, b) {
        if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });

      return friends;
    } catch (e) {
      throw Exception('Failed to get friends: $e');
    }
  }

  static Future<List<FriendModel>> getPendingFriendRequests() async {
    try {
      String currentUserEmail = _auth.currentUser?.email ?? '';
      if (currentUserEmail.isEmpty) throw Exception('User not authenticated');

      QuerySnapshot snapshot = await _getCollection(friendsCollection)
          .where('status', isEqualTo: FriendStatus.pending.name)
          .where('receiverEmail', isEqualTo: currentUserEmail)
          .get();

      List<FriendModel> requests = [];
      for (var doc in snapshot.docs) {
        requests.add(FriendModel.fromJson(doc.data() as Map<String, dynamic>));
      }
      return requests;
    } catch (e) {
      throw Exception('Failed to get pending friend requests: $e');
    }
  }

  static Future<List<FriendModel>> getSentFriendRequests() async {
    try {
      String currentUserEmail = _auth.currentUser?.email ?? '';
      if (currentUserEmail.isEmpty) throw Exception('User not authenticated');

      QuerySnapshot snapshot = await _getCollection(friendsCollection)
          .where('status', isEqualTo: FriendStatus.pending.name)
          .where('senderEmail', isEqualTo: currentUserEmail)
          .get();

      List<FriendModel> requests = [];
      for (var doc in snapshot.docs) {
        requests.add(FriendModel.fromJson(doc.data() as Map<String, dynamic>));
      }
      return requests;
    } catch (e) {
      throw Exception('Failed to get sent friend requests: $e');
    }
  }

  static Future<void> cancelFriendRequest(String friendId) async {
    try {
      await _getCollection(friendsCollection).doc(friendId).delete();
    } catch (e) {
      throw Exception('Failed to cancel friend request: $e');
    }
  }

  // Message operations
  static Future<void> sendMessage(ChatMessageModel message) async {
    try {
      String messageId = _getCollection(messagesCollection).doc().id;
      message.messageId = messageId;
      message.timestamp = DateTime.now();

      printLog(msg: "Sending message with ID: $messageId");
      printLog(msg: "Message friendId: ${message.friendId}");
      printLog(msg: "Message content: ${message.message}");
      printLog(msg: "Message sender: ${message.senderEmail}");
      printLog(msg: "Message receiver: ${message.receiverEmail}");

      // First, ensure the message document exists
      await _getCollection(messagesCollection).doc(messageId).set(message.toJson());
      printLog(msg: "Message document created successfully");

      // Then update the friend document
      try {
        await _getCollection(friendsCollection).doc(message.friendId).update({
          'lastMessage': message.message,
          'lastMessageTime': message.timestamp!.toIso8601String(),
          'lastMessageSender': message.senderEmail,
        });
        printLog(msg: "Friend document updated successfully");
      } catch (e) {
        printLog(msg: "Warning: Failed to update friend document: $e");
        // Continue even if friend document update fails
      }
    } catch (e) {
      printLog(msg: "Failed to send message: $e");
      throw Exception('Failed to send message: $e');
    }
  }

  static Stream<List<ChatMessageModel>> getMessages(String friendId) {
    printLog(msg: "Getting messages for friendId: $friendId");
    return _getCollection(messagesCollection)
        .where('friendId', isEqualTo: friendId)
        .snapshots()
        .map((snapshot) {
      printLog(msg: "Received ${snapshot.docs.length} messages");
      List<ChatMessageModel> messages = snapshot.docs.map((doc) {
        ChatMessageModel message = ChatMessageModel.fromJson(doc.data() as Map<String, dynamic>);
        printLog(msg: "Processing message: ${message.messageId} - ${message.message}");
        return message;
      }).toList();
      // Sort messages in memory instead of using orderBy
      messages.sort((a, b) => (b.timestamp ?? DateTime.now()).compareTo(a.timestamp ?? DateTime.now()));
      return messages;
    });
  }

  static Stream<List<FriendModel>> getFriendsStream() {
    String currentUserEmail = _auth.currentUser?.email ?? '';
    if (currentUserEmail.isEmpty) {
      // printLog(msg: "getFriendsStream: No current user email found");
      return Stream.value([]);
    }

    // printLog(msg: "getFriendsStream: Starting stream for user: $currentUserEmail");
    return _getCollection(friendsCollection)
        .where('status', isEqualTo: FriendStatus.accepted.name)
        .snapshots()
        .map((snapshot) {
      // printLog(msg: "getFriendsStream: Received ${snapshot.docs.length} documents");
      List<FriendModel> friends = [];
      for (var doc in snapshot.docs) {
        FriendModel friend = FriendModel.fromJson(doc.data() as Map<String, dynamic>);
        // printLog(msg: "getFriendsStream: Processing friend: ${friend.friendId} - ${friend.senderEmail} - ${friend.receiverEmail}");
        // Only include friends where current user is sender or receiver
        if (friend.senderEmail == currentUserEmail || friend.receiverEmail == currentUserEmail) {
          friends.add(friend);
          // printLog(msg: "getFriendsStream: Added friend to list: ${friend.friendId}");
        }
      }
      
      // Sort by last message time
      friends.sort((a, b) {
        if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });
      
      // printLog(msg: "getFriendsStream: Returning ${friends.length} friends");
      return friends;
    });
  }

  static Future<FriendModel?> getFriendById(String friendId) async {
    try {
      DocumentSnapshot doc = await _getCollection(friendsCollection).doc(friendId).get();
      if (doc.exists) {
        return FriendModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      printLog(msg: "getFriendById error: $e");
      return null;
    }
  }

  static Future<ChatMessageModel?> getMessageById(String messageId) async {
    try {
      DocumentSnapshot doc = await _getCollection(messagesCollection).doc(messageId).get();
      if (doc.exists) {
        return ChatMessageModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get message by id: $e');
    }
  }

  // Spam operations
  static Future<void> reportSpam({
    required String reporterEmail,
    required String reportedEmail,
    required String friendId,
    String? reason,
  }) async {
    try {
      // Check for duplicate report
      QuerySnapshot existingReports = await _getCollection(spamCollection)
          .where('reporterEmail', isEqualTo: reporterEmail)
          .where('reportedEmail', isEqualTo: reportedEmail)
          .where('friendId', isEqualTo: friendId)
          .get();

      if (existingReports.docs.isNotEmpty) {
        throw Exception('already_reported');
      }

      // Create spam report
      final report = SpamModel(
        reporterEmail: reporterEmail,
        reportedEmail: reportedEmail,
        friendId: friendId,
        reason: reason,
        reportedAt: DateTime.now(),
        status: SpamStatus.reported,
      );

      await _getCollection(spamCollection).add(report.toJson());

      // Update reporter's report count
      final reporterDoc = await _getCollection(usersCollection)
          .where('email', isEqualTo: reporterEmail)
          .get();
      
      if (reporterDoc.docs.isNotEmpty) {
        final reporterData = reporterDoc.docs.first.data() as Map<String, dynamic>?;
        if (reporterData != null) {
          final currentReportCount = reporterData['spamMeReportedOtherCount'] ?? 0;
          await reporterDoc.docs.first.reference.update({
            'spamMeReportedOtherCount': currentReportCount + 1
          });
        }
      }


      // Update reported user's reported count
      final reportedDoc = await _getCollection(usersCollection)
          .where('email', isEqualTo: reportedEmail)
          .get();
      
      if (reportedDoc.docs.isNotEmpty) {
        final reportedData = reportedDoc.docs.first.data() as Map<String, dynamic>?;
        if (reportedData != null) {
          final currentReportedCount = reportedData['spamOtherReportedMeCount'] ?? 0;
          await reportedDoc.docs.first.reference.update({
            'spamOtherReportedMeCount': currentReportedCount + 1
          });
        }
      }

      // Get current friend document
      DocumentSnapshot friendDoc = await _getCollection(friendsCollection).doc(friendId).get();
      if (friendDoc.exists) {
        final friendData = friendDoc.data() as Map<String, dynamic>?;
        if (friendData != null) {
          final spamInfoData = friendData['spamInfo'] as Map<String, dynamic>?;
          SpamInfo currentSpamInfo = SpamInfo.fromJson(spamInfoData ?? {});

          // Update friend document with new spam information
          await _getCollection(friendsCollection).doc(friendId).update({
            'spamInfo': SpamInfo(
              isReported: true,
              reportedAt: DateTime.now(),
              reportedBy: reporterEmail,
              reportReason: reason,
              reportCount: currentSpamInfo.reportCount + 1,
              status: SpamStatus.reported,
            ).toJson(),
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to report spam: $e');
    }
  }

  static Future<void> updateSpamStatus(String reportId, SpamStatus newStatus) async {
    try {
      // Create update map
      Map<String, dynamic> updateData = {
        'status': newStatus.name,
      };

      // Add resolution data if status is resolved
      if (newStatus == SpamStatus.resolved) {
        updateData['isResolved'] = true;
        updateData['resolvedAt'] = FieldValue.serverTimestamp();
      }

      // Update spam report status
      await _getCollection(spamCollection).doc(reportId).update(updateData);

      // Get the spam report to find the friendId
      DocumentSnapshot spamDoc = await _getCollection(spamCollection).doc(reportId).get();
      if (spamDoc.exists) {
        SpamModel spamReport = SpamModel.fromJson(spamDoc.data() as Map<String, dynamic>);
        
        // Update friend document's spam status
        DocumentSnapshot friendDoc = await _getCollection(friendsCollection).doc(spamReport.friendId).get();
        if (friendDoc.exists) {
          Map<String, dynamic> friendData = friendDoc.data() as Map<String, dynamic>;
          SpamInfo currentSpamInfo = SpamInfo.fromJson(friendData['spamInfo'] ?? {});

          await _getCollection(friendsCollection).doc(spamReport.friendId).update({
            'spamInfo': currentSpamInfo.copyWith(
              status: newStatus,
            ).toJson(),
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to update spam status: $e');
    }
  }

  static Future<List<SpamModel>> getSpamReportsByReporter(String reporterEmail) async {
    try {
      QuerySnapshot snapshot = await _getCollection(spamCollection)
          .where('reporterEmail', isEqualTo: reporterEmail)
          // .orderBy('reportedAt', descending: true)
          .get();

      List<SpamModel> reports = [];
      for (var doc in snapshot.docs) {
        reports.add(SpamModel.fromJson(doc.data() as Map<String, dynamic>));
      }
      return reports;
    } catch (e) {
      throw Exception('Failed to get spam reports by reporter: $e');
    }
  }

  static Future<List<SpamModel>> getSpamReportsByReported(String reportedEmail) async {
    try {
      QuerySnapshot snapshot = await _getCollection(spamCollection)
          .where('reportedEmail', isEqualTo: reportedEmail)
          // .orderBy('reportedAt', descending: true)
          .get();

      List<SpamModel> reports = [];
      for (var doc in snapshot.docs) {
        reports.add(SpamModel.fromJson(doc.data() as Map<String, dynamic>));
      }
      return reports;
    } catch (e) {
      throw Exception('Failed to get spam reports by reported: $e');
    }
  }

  static Future<int> getSpamReportCount(String email) async {
    try {
      QuerySnapshot snapshot = await _getCollection(spamCollection)
          .where('reporterEmail', isEqualTo: email)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get spam report count: $e');
    }
  }

  static Future<int> getSpamReportsAgainstCount(String email) async {
    try {
      QuerySnapshot snapshot = await _getCollection(spamCollection)
          .where('reportedEmail', isEqualTo: email)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get spam reports against count: $e');
    }
  }

  // Get report counts for a user
  static Future<Map<String, int>> getUserReportCounts(String? uid) async {
    try {
      DocumentSnapshot doc = await _getCollection(usersCollection).doc(uid).get();
      printLog(msg: "getUserReportCounts : ${doc.exists} $uid");
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        printLog(msg: "getUserReportCounts : ${data}");
        return {
          'spamMeReportedOtherCount': data['spamMeReportedOtherCount'] ?? 0,
          'spamOtherReportedMeCount': data['spamOtherReportedMeCount'] ?? 0,
        };
      }

      return {'spamMeReportedOtherCount': 0, 'spamOtherReportedMeCount': 0};
    } catch (e) {
      throw Exception('Failed to get report counts: $e');
    }
  }

  // Update online status and last seen
  static Future<void> setUserOnlineStatus(String uid, bool isOnline) async {
    try {
      await _getCollection(usersCollection).doc(uid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update online status: $e');
    }
  }

  // Set onDisconnect handler (Realtime Database workaround)
  static Future<void> setOnDisconnectOffline(String uid) async {
    // Firestore does not support onDisconnect, so use Realtime Database for presence
    // (You must add firebase_database to your pubspec.yaml)
    // This is a stub for now, you can implement it if you want true presence
  }

  // Delete a single message
  static Future<void> deleteMessage(String friendId, String messageId) async {
    try {
      await _getCollection(messagesCollection)
        .doc(friendId)
        .collection('messages')
        .doc(messageId)
        .delete();
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  // Clear all messages in a chat
  static Future<void> clearChat(String friendId) async {
    try {
      final messagesRef = _getCollection(messagesCollection)
        .doc(friendId)
        .collection('messages');
      final batch = _firestore.batch();
      final snapshot = await messagesRef.get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear chat: $e');
    }
  }

  // Set typing status
  static Future<void> setTypingTo(String uid, String? typingTo) async {
    try {
      await _getCollection(usersCollection).doc(uid).update({
        'typingTo': typingTo,
      });
    } catch (e) {
      throw Exception('Failed to set typing status: $e');
    }
  }

  // Mark all messages as read for a chat
  static Future<void> markMessagesAsRead(String friendId, String currentUserEmail) async {
    try {
      final messagesRef = _getCollection(messagesCollection)
        .doc(friendId)
        .collection('messages')
        .where('receiverEmail', isEqualTo: currentUserEmail)
        .where('isRead', isEqualTo: false);
      final snapshot = await messagesRef.get();
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  // Block a user
  static Future<void> blockUser(String myUid, String otherUid) async {
    try {
      await _getCollection(usersCollection).doc(myUid).update({
        'blockedUsers': FieldValue.arrayUnion([otherUid]),
      });
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  // Unblock a user
  static Future<void> unblockUser(String myUid, String otherUid) async {
    try {
      await _getCollection(usersCollection).doc(myUid).update({
        'blockedUsers': FieldValue.arrayRemove([otherUid]),
      });
    } catch (e) {
      throw Exception('Failed to unblock user: $e');
    }
  }

  // Check if a user is blocked
  static Future<bool> isUserBlocked(String myUid, String otherUid) async {
    try {
      final doc = await _getCollection(usersCollection).doc(myUid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final blocked = data['blockedUsers'] as List<dynamic>?;
        return blocked != null && blocked.contains(otherUid);
      }
      return false;
    } catch (e) {
      throw Exception('Failed to check block status: $e');
    }
  }

  // Save FCM token for a user
  static Future<void> saveFcmToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    } catch (e) {
      print('Error saving FCM token: $e');
      rethrow;
    }
  }

  // Remove FCM token when user logs out
  static Future<void> removeFcmToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
    } catch (e) {
      print('Error removing FCM token: $e');
      rethrow;
    }
  }

  // Get all FCM tokens for a user
  static Future<List<String>> getUserFcmTokens(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        List<dynamic> tokens = doc.get('fcmTokens') ?? [];
        return tokens.cast<String>();
      }
      return [];
    } catch (e) {
      print('Error getting FCM tokens: $e');
      return [];
    }
  }

  // Send notification to a user
  static Future<void> sendNotification({
    required String receiverUid,
    required String title,
    required String body,
    required String chatId,
  }) async {
    try {
      // Get receiver's FCM tokens
      List<String> tokens = await getUserFcmTokens(receiverUid);
      if (tokens.isEmpty) return;

      // Create notification document
      await _firestore.collection('notifications').add({
        'receiverUid': receiverUid,
        'title': title,
        'body': body,
        'chatId': chatId,
        'tokens': tokens,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      print('Error sending notification: $e');
      rethrow;
    }
  }

  // Get user's notifications
  static Stream<List<Map<String, dynamic>>> getUserNotifications(String uid) {
    return _firestore
        .collection('notifications')
        .where('receiverUid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'read': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }
}