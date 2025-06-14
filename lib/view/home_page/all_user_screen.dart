import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pingmexx/data/bean/friend/friend_model.dart';
import 'package:pingmexx/utils/common/global_utilities.dart';

import '../../controller/chat_controller.dart';
import '../../data/bean/user/user_model.dart';
import '../../data/repo/firestore_service.dart';

class AllUsersScreen extends StatefulWidget {
  const AllUsersScreen({Key? key}) : super(key: key);

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {
  final ChatController controller = Get.find<ChatController>();
  final TextEditingController _searchController = TextEditingController();
  RxList<UserModel> allUsers = <UserModel>[].obs;
  RxList<UserModel> filteredUsers = <UserModel>[].obs;
  RxBool isLoading = true.obs;
  RxString searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
    _searchController.addListener(() {
      searchQuery.value = _searchController.text;
      _filterUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadAllUsers() async {
    try {
      isLoading.value = true;
      List<UserModel> users = await controller.getAllUsers();
      String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      users.removeWhere((user) => user.email == currentUserEmail);
      allUsers.value = users;
      filteredUsers.value = users;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load users: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _filterUsers() {
    if (searchQuery.value.isEmpty) {
      filteredUsers.value = allUsers;
    } else {
      filteredUsers.value = allUsers
          .where((user) =>
              user.name!
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              user.email!
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111B21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF202C33),
        elevation: 0,
        title: const Text(
          'All Users',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAllUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF111B21),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A3942),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search users...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.people,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'All Users',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Find and connect with other users',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: Obx(() {
              if (isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF25D366),
                  ),
                );
              }

              if (filteredUsers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        searchQuery.value.isEmpty
                            ? Icons.people_outline
                            : Icons.search_off,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        searchQuery.value.isEmpty
                            ? 'No users found'
                            : 'No users match your search',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        searchQuery.value.isEmpty
                            ? 'Users will appear here when they join'
                            : 'Try a different search term',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: const Color(0xFF25D366),
                backgroundColor: const Color(0xFF2A3942),
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 500));
                  _loadAllUsers();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    UserModel user = filteredUsers[index];
                    return _buildUserItem(user);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          FutureBuilder<FriendModel?>(
            future: FirestoreService.getFriendById(controller.generateFriendId(
                FirebaseAuth.instance.currentUser?.email ?? '', user.email!)),
            builder: (context, snapshot) {
              FriendModel? existingFriend = snapshot.data;
              String currentUserEmail =
                  FirebaseAuth.instance.currentUser?.email ?? '';
              String friendId =
                  controller.generateFriendId(currentUserEmail, user.email!);
              String statusText = '';
              Color statusColor = Colors.grey;
              String buttonText = 'Add';
              Color buttonColor = const Color(0xFF25D366);
              bool isButtonEnabled = true;

              if (existingFriend != null) {
                switch (existingFriend.status) {
                  case FriendStatus.pending:
                    statusText = existingFriend.senderEmail == currentUserEmail
                        ? 'Pending Request Sent'
                        : 'Pending Request Received';
                    statusColor = Colors.orange;
                    if (existingFriend.senderEmail == currentUserEmail) {
                      buttonText = 'Request Sent';
                      buttonColor = Colors.orange;
                      isButtonEnabled = false;
                    } else {
                      buttonText = 'Accept';
                      isButtonEnabled = true;
                      buttonColor = const Color(0xFF25D366);
                      buttonColor = Colors.orange;
                    }
                    break;
                  case FriendStatus.accepted:
                    statusText = 'Friends';
                    statusColor = const Color(0xFF25D366);
                    buttonColor = Colors.grey[600]!;
                    isButtonEnabled = false;
                    break;
                  case FriendStatus.blocked:
                    statusText = 'Blocked';
                    statusColor = Colors.red;
                    buttonText = 'Blocked';
                    buttonColor = Colors.red;
                    isButtonEnabled = false;
                    break;
                  case FriendStatus.declined:
                    statusText = 'Declined';
                    statusColor = Colors.grey;
                    buttonText = 'Declined Add Again';
                    buttonColor = const Color(0xFF25D366);
                    isButtonEnabled = true;
                    break;
                  default:
                    statusText = 'unknown';
                    buttonText = 'Add';
                    buttonColor = const Color(0xFF25D366);
                    isButtonEnabled = true;
                }
              }
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: const Color(0xFF202C33),
                leading: user.profileImage != null &&
                        user.profileImage!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: user.profileImage!,
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          radius: 25,
                          backgroundImage: imageProvider,
                          backgroundColor: Colors.grey[600],
                        ),
                        placeholder: (context, url) => CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey[600],
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (context, url, error) => CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey[600],
                          child: Text(
                            user.name?.substring(0, 1).toUpperCase() ?? 'U',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[600],
                        child: Text(
                          user.name?.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                title: Text(
                  user.name ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.email ?? '',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (user.bio != null && user.bio!.isNotEmpty)
                      Text(
                        user.bio!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    if (!isEmpty(statusText))
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: statusColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ))
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: user.isOnline == true
                            ? const Color(0xFF25D366)
                            : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF202C33), width: 2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 80,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isButtonEnabled) {
                            if (buttonText == 'Accept') {
                              FriendModel? request = controller.pendingRequests
                                  .firstWhereOrNull((request) =>
                                      request.friendId ==
                                      controller.generateFriendId(
                                          user.email!, currentUserEmail));
                              if (request != null) {
                                controller
                                    .acceptFriendRequest(request.friendId!);
                              }
                            } else if(buttonText.contains('Add')){
                              controller.sendFriendRequest(user.email!);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: const Size(80, 32),
                        ),
                        child: Text(
                          buttonText,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
