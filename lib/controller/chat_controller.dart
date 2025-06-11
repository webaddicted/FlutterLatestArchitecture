import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/repo/firestore_service.dart';
import '../data/bean/user/user_model.dart';
import '../data/bean/friend/friend_model.dart';

class ChatController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  
  RxList<FriendModel> friends = <FriendModel>[].obs;
  RxList<UserModel> searchResults = <UserModel>[].obs;
  RxList<FriendModel> pendingRequests = <FriendModel>[].obs;
  
  RxBool isLoading = false.obs;
  RxBool isSearching = false.obs;
  RxString searchQuery = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    getFriends();
    getPendingRequests();
    
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
      Get.snackbar(
        'Error',
        'Failed to load friends: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      Get.snackbar(
        'Error',
        'Failed to search users: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
        Get.snackbar(
          'Info',
          'Friend request already sent or you are already friends',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      await FirestoreService.sendFriendRequest(receiverEmail);
      
      Get.snackbar(
        'Success',
        'Friend request sent successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Refresh pending requests
      getPendingRequests();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send friend request: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void acceptFriendRequest(String friendId) async {
    try {
      await FirestoreService.acceptFriendRequest(friendId);
      
      Get.snackbar(
        'Success',
        'Friend request accepted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Refresh both lists
      getFriends();
      getPendingRequests();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to accept friend request: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void declineFriendRequest(String friendId) async {
    try {
      await FirestoreService.declineFriendRequest(friendId);
      
      Get.snackbar(
        'Success',
        'Friend request declined',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      
      // Refresh pending requests
      getPendingRequests();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to decline friend request: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void getPendingRequests() async {
    try {
      List<FriendModel> requests = await FirestoreService.getPendingFriendRequests();
      pendingRequests.value = requests;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load pending requests: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      Get.snackbar(
        'Error',
        'Failed to load all users: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return [];
    }
  }

  String generateFriendId(String email1, String email2) {
    return FirestoreService.generateFriendId(email1, email2);
  }
} 