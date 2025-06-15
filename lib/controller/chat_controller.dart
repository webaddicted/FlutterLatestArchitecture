import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pingmexx/utils/common/global_utilities.dart';
import '../data/repo/firestore_service.dart';
import '../data/bean/user/user_model.dart';
import '../data/bean/friend/friend_model.dart';
import '../services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/bean/chat/chat_message_model.dart';
import 'package:pingmexx/utils/widgethelper/widget_helper.dart';

class ChatController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  
  RxList<FriendModel> friends = <FriendModel>[].obs;
  RxList<UserModel> searchResults = <UserModel>[].obs;
  RxList<FriendModel> pendingRequests = <FriendModel>[].obs;
  RxList<FriendModel> sentRequests = <FriendModel>[].obs;
  
  RxBool isLoading = false.obs;
  RxBool isSearching = false.obs;
  RxString searchQuery = ''.obs;
  
  RxMap<String, FriendModel?> friendDetails = <String, FriendModel?>{}.obs;

  // final NotificationService _notificationService = Get.find<NotificationService>();

  @override
  void onInit() {
    super.onInit();
    getFriends();
    getPendingRequests();
    getSentRequests();
    
    // Listen to search query changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      if (searchController.text.isNotEmpty) {
        searchUsers(searchController.text);
      } else {
        searchResults.clear();
        isSearching.value = false;
      }
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    messageController.dispose();
    super.onClose();
  }

  void getFriends() {
    isLoading.value = true;
    try {
      FirestoreService.getFriendsStream().listen((friendsList) {
        friends.value = friendsList;
        isLoading.value = false;
      });
    } catch (e) {
      isLoading.value = false;
      showSnackBar(Get.context!, 'Failed to load friends: $e');
    }
  }

  void searchUsers(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;
    try {
      List<UserModel> users = await FirestoreService.searchUsers(query);
      
      // Filter out current user
      String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      users.removeWhere((user) => user.email == currentUserEmail);
      
      searchResults.value = users;
    } catch (e) {
      showSnackBar(Get.context!, 'Failed to search users: $e');
    } finally {
      isSearching.value = false;
    }
  }

  void sendFriendRequest(String receiverEmail) async {
    try {
      // Check if friend request already exists
      String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      String friendId = FirestoreService.generateFriendId(currentUserEmail, receiverEmail);
      
      // Check if they are already friends or have pending request
      bool alreadyExists = friends.any((friend) => friend.friendId == friendId) ||
                          pendingRequests.any((request) => request.friendId == friendId);
      
      if (alreadyExists) {
        showSnackBar(Get.context!, 'Friend request already sent or you are already friends');
        return;
      }

      await FirestoreService.sendFriendRequest(receiverEmail);
      
      showSnackBar(Get.context!, 'Friend request sent successfully');
      getFriends();
      // Refresh pending requests
      getPendingRequests();
      
    } catch (e) {
      showSnackBar(Get.context!, 'Failed to send friend request: $e');
    }
  }

  void acceptFriendRequest(String friendId) async {
    try {
      await FirestoreService.acceptFriendRequest(friendId);
      
      showSnackBar(Get.context!, 'Friend request accepted');
      
      // Refresh both lists
      getFriends();
      getPendingRequests();
      
    } catch (e) {
      showSnackBar(Get.context!, 'Failed to accept friend request: $e');
    }
  }

  void declineFriendRequest(String friendId) async {
    try {
      await FirestoreService.declineFriendRequest(friendId);
      
      showSnackBar(Get.context!, 'Friend request declined');
      
      // Refresh pending requests
      getPendingRequests();
      
    } catch (e) {
      showSnackBar(Get.context!, 'Failed to decline friend request: $e');
    }
  }

  void getPendingRequests() async {
    try {
      List<FriendModel> requests = await FirestoreService.getPendingFriendRequests();
      pendingRequests.value = requests;
    } catch (e) {
      showSnackBar(Get.context!, 'Failed to load pending requests: $e');
    }
  }

  void getSentRequests() async {
    try {
      List<FriendModel> requests = await FirestoreService.getSentFriendRequests();
      sentRequests.value = requests;
    } catch (e) {
      showSnackBar(Get.context!, 'Failed to load sent requests: $e');
    }
  }

  void cancelFriendRequest(String friendId) async {
    try {
      await FirestoreService.cancelFriendRequest(friendId);
      
      showSnackBar(Get.context!, 'Friend request cancelled');
      
      // Refresh sent requests
      getSentRequests();
      
    } catch (e) {
      showSnackBar(Get.context!, 'Failed to cancel friend request: $e');
    }
  }

  void clearSearch() {
    searchController.clear();
    searchResults.clear();
    isSearching.value = false;
    searchQuery.value = '';
  }

  String getOtherUserName(FriendModel friend) {
    String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    if (friend.senderEmail == currentUserEmail) {
      return friend.receiverName ?? 'Unknown';
    } else {
      return friend.senderName ?? 'Unknown';
    }
  }

  String getOtherUserImage(FriendModel friend) {
    String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    if (friend.senderEmail == currentUserEmail) {
      return friend.receiverProfileImage ?? '';
    } else {
      return friend.senderProfileImage ?? '';
    }
  }

  String getOtherUserEmail(FriendModel friend) {
    String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    if (friend.senderEmail == currentUserEmail) {
      return friend.receiverEmail ?? '';
    } else {
      return friend.senderEmail ?? '';
    }
  }

  String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      return await FirestoreService.getAllUsers();
    } catch (e) {
      showSnackBar(Get.context!, 'Failed to load all users: $e');
      return [];
    }
  }

  String generateFriendId(String email1, String email2) {
    return FirestoreService.generateFriendId(email1, email2);
  }

  void getFriendDetails(String userEmail) {
    String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    String friendId = generateFriendId(currentUserEmail, userEmail);
    printLog(msg: "friendIddddd $friendId");
    FirestoreService.getFriendById(friendId).then((friend) {
      friendDetails[friendId] = friend;
    });
  }


  FriendModel? getFriendDetail(String userEmail) {
    String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    String friendId = generateFriendId(currentUserEmail, userEmail);
    return friendDetails[friendId];
  }

  // Get report counts for current user
  Future<Map<String, int>> getMyReportCounts() async {
    try {
      String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (currentUserUid.isEmpty) {
        showSnackBar(Get.context!, 'User not authenticated');
        throw Exception('User not authenticated');
      }
      return await FirestoreService.getUserReportCounts(currentUserUid);
    } catch (e) {
      showSnackBar(Get.context!, 'Failed to get report counts: $e');
      return {'reportCount': 0, 'reportedCount': 0};
    }
  }

  // Get report counts for another user
  Future<Map<String, int>> getUserReportCounts(String? uid) async {
    try {
      return await FirestoreService.getUserReportCounts(uid);
    } catch (e) {
      showSnackBar(Get.context!, 'Failed to get user report counts: $e');
      return {'reportCount': 0, 'reportedCount': 0};
    }
  }

  Future<void> sendMessage(String message, String receiverEmail, String chatId) async {
    try {
      if (message.trim().isEmpty) return;

      String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserUid == null) {
        showSnackBar(Get.context!, 'User not authenticated');
        return;
      }

      // Get current user data
      UserModel? currentUser = await FirestoreService.getUser(currentUserUid);
      if (currentUser == null) {
        showSnackBar(Get.context!, 'User data not found');
        return;
      }

      // Get receiver's UID from email
      List<UserModel> receiverUsers = await FirestoreService.searchUsersByEmail(receiverEmail);
      if (receiverUsers.isEmpty) {
        showSnackBar(Get.context!, 'Receiver not found');
        return;
      }
      String receiverUid = receiverUsers.first.uid!;

      // Create message using ChatMessageModel
      ChatMessageModel messageModel = ChatMessageModel(
        friendId: chatId,
        senderEmail: currentUser.email,
        receiverEmail: receiverEmail,
        message: message.trim(),
        messageType: MessageType.text,
        isRead: false,
        isReply: false,
        replyToMsgDoc: null,
        sd: false,
        rd: false,
        isForward: false,
        sname: currentUser.name,
        isPrivate: false,
      );

      // Send message using FirestoreService
      await FirestoreService.sendMessage(messageModel);

      // Send notification to receiver
      // await _notificationService.sendNotification(
      //   receiverUid: receiverUid,
      //   title: 'New message from ${currentUser.name}',
      //   body: message.trim(),
      //   chatId: chatId,
      // );

      // Clear message input
      messageController.clear();
    } catch (e) {
      printLog(msg: 'Error sending message: $e');
      showSnackBar(Get.context!, 'Failed to send message');
    }
  }
} 