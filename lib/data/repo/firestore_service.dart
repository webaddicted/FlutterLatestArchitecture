import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pingmexx/utils/common/global_utilities.dart';
import '../bean/user/user_model.dart';
import '../bean/friend/friend_model.dart';
import '../bean/chat/chat_message_model.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // App name as parent collection
  static const String appName = 'pingmexx';

  static const String usersCollection = 'users';
  static const String friendsCollection = 'friends';
  static const String messagesCollection = 'messages';
  
  // Helper method to get collection reference under app name
  static CollectionReference _getCollection(String collectionName) {
    return _firestore.collection(appName).doc(usersCollection).collection(collectionName);
  }

  // User operations
  static Future<void> createUser(UserModel user) async {
    try {
      await _getCollection(usersCollection).doc(user.uid).set(user.toJson());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  static Future<UserModel?> getUser(String uid) async {
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
      
      UserModel receiverUser = receiverUsers.first;

      FriendModel friendRequest = FriendModel(
        friendId: friendId,
        senderEmail: currentUserEmail,
        receiverEmail: receiverEmail,
        senderName: currentUser?.name,
        receiverName: receiverUser.name,
        senderProfileImage: currentUser?.profileImage,
        receiverProfileImage: receiverUser.profileImage,
        status: FriendStatus.pending,
        requestedAt: DateTime.now(),
      );

      await _getCollection(friendsCollection).doc(friendId).set(friendRequest.toJson());
    } catch (e) {
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

  // Message operations
  static Future<void> sendMessage(ChatMessageModel message) async {
    try {
      String messageId = _getCollection(messagesCollection).doc().id;
      message.messageId = messageId;
      message.timestamp = DateTime.now();

      await _getCollection(messagesCollection).doc(messageId).set(message.toJson());

      // Update last message in friends collection
      await _getCollection(friendsCollection).doc(message.friendId).update({
        'lastMessage': message.message,
        'lastMessageTime': message.timestamp!.toIso8601String(),
        'lastMessageSender': message.senderEmail,
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  static Stream<List<ChatMessageModel>> getMessages(String friendId) {
    return _getCollection(messagesCollection)
        .where('friendId', isEqualTo: friendId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => 
          ChatMessageModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  static Stream<List<FriendModel>> getFriendsStream() {
    String currentUserEmail = _auth.currentUser?.email ?? '';
    if (currentUserEmail.isEmpty) {
      return Stream.value([]);
    }

    return _getCollection(friendsCollection)
        .where('status', isEqualTo: FriendStatus.accepted.name)
        .snapshots()
        .map((snapshot) {
      List<FriendModel> friends = [];
      for (var doc in snapshot.docs) {
        FriendModel friend = FriendModel.fromJson(doc.data() as Map<String, dynamic>);
        // Only include friends where current user is sender or receiver
        if (friend.senderEmail == currentUserEmail || friend.receiverEmail == currentUserEmail) {
          friends.add(friend);
        }
      }
      
      // Sort by last message time
      friends.sort((a, b) {
        if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });
      
      return friends;
    });
  }

}