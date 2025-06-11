import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pingmexx/utils/constant/routers_const.dart';
import 'package:pingmexx/utils/sp/sp_manager.dart';
import '../../controller/chat_controller.dart';
import '../../controller/auth_controller.dart';
import '../../data/bean/friend/friend_model.dart';
import '../../data/bean/user/user_model.dart';
import 'chat_detail_screen.dart';
import 'friend_requests_screen.dart';
import 'all_user_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;
  final ChatController controller = Get.put(ChatController());
  final AuthController authController = Get.put(AuthController());

  // User data from SharedPreferences
  String userName = '';
  String userEmail = '';
  String userProfileImage = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadUserData();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    try {
      UserModel? user = await SPManager.getUserData();
      if (user != null) {
        setState(() {
          userName = user.name ?? '';
          userEmail = user.email ?? '';
          userProfileImage = user.profileImage ?? '';
        });
      }
    } catch (e) {
      print('Failed to load user data: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF111B21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF202C33),
        elevation: 0,
        title: Text(
          userName.isNotEmpty ? 'Hi, $userName' : 'PingMeXX',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: GestureDetector(
          onTap: _showUserProfileDialog,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildProfileImage(
              imageUrl: userProfileImage,
              radius: 20,
              fallbackText: userName,
              backgroundColor: const Color(0xFF25D366),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF2A3942),
            onSelected: (String value) {
              switch (value) {
                case 'friend_requests':
                  Get.to(() => const FriendRequestsScreen());
                  break;
                case 'settings':
                  // Navigate to settings
                  break;
                case 'profile':
                  _showUserProfileDialog();
                  break;
                case 'logout':
                  _showLogoutDialog();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'friend_requests',
                child: Text('Friend Requests', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('Profile', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          _buildChatsTab(),
          _buildUpdatesTab(),
          const AllUsersScreen(),
          _buildCallsTab(),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF202C33),
        child: SafeArea(
          child: Container(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => _onTabTapped(0),
                  child: _buildNavItem('Chats', Icons.chat, _selectedIndex == 0),
                ),
                GestureDetector(
                  onTap: () => _onTabTapped(1),
                  child: _buildNavItem('Updates', Icons.update, _selectedIndex == 1),
                ),
                GestureDetector(
                  onTap: () => _onTabTapped(2),
                  child: _buildNavItem('Communities', Icons.people, _selectedIndex == 2),
                ),
                GestureDetector(
                  onTap: () => _onTabTapped(3),
                  child: _buildNavItem('Calls', Icons.call, _selectedIndex == 3),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show search dialog or navigate to add friends
          _showAddFriendDialog(context, controller);
        },
        backgroundColor: const Color(0xFF25D366),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xFF25D366) : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF25D366) : Colors.grey,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(ChatController controller) {
    return Obx(() {
      if (controller.isSearching.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF25D366),
          ),
        );
      }

      if (controller.searchResults.isEmpty) {
        return const Center(
          child: Text(
            'No users found',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.searchResults.length,
        itemBuilder: (context, index) {
          UserModel user = controller.searchResults[index];
          return _buildSearchResultItem(user, controller);
        },
      );
    });
  }

  Widget _buildSearchResultItem(UserModel user, ChatController controller) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[600],
        backgroundImage: user.profileImage != null && user.profileImage!.isNotEmpty
            ? CachedNetworkImageProvider(user.profileImage!)
            : null,
        child: user.profileImage == null || user.profileImage!.isEmpty
            ? Text(
                user.name?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Text(
        user.name ?? 'Unknown',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        user.email ?? '',
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
      trailing: ElevatedButton(
        onPressed: () {
          controller.sendFriendRequest(user.email!);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF25D366),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: const Text('Add Friend'),
      ),
    );
  }

  Widget _buildFriendsList(ChatController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF25D366),
          ),
        );
      }

      if (controller.friends.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No friends exist',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Start by adding some friends!',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.friends.length,
        itemBuilder: (context, index) {
          FriendModel friend = controller.friends[index];
          return _buildFriendItem(friend, controller);
        },
      );
    });
  }

  Widget _buildFriendItem(FriendModel friend, ChatController controller) {
    String otherUserName = controller.getOtherUserName(friend);
    String otherUserImage = controller.getOtherUserImage(friend);
    String lastMessage = friend.lastMessage ?? 'Tap to start chatting';
    String timeAgo = controller.formatTime(friend.lastMessageTime);

    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[600],
        backgroundImage: otherUserImage.isNotEmpty
            ? CachedNetworkImageProvider(otherUserImage)
            : null,
        child: otherUserImage.isEmpty
            ? Text(
                otherUserName.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Text(
        otherUserName,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Row(
        children: [
          if (friend.lastMessageSender != null && friend.lastMessage != null)
            Icon(
              Icons.done_all,
              size: 16,
              color: Colors.blue[300],
            ),
          if (friend.lastMessageSender != null && friend.lastMessage != null)
            const SizedBox(width: 4),
          Expanded(
            child: Text(
              lastMessage,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (timeAgo.isNotEmpty)
            Text(
              timeAgo,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          const SizedBox(height: 4),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF25D366),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      onTap: () {
        Get.to(() => ChatDetailScreen(friend: friend));
      },
    );
  }

  void _showAddFriendDialog(BuildContext context, ChatController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A3942),
          title: const Text(
            'Add Friend',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Search for users by name to send friend requests',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Enter name to search...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF25D366)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.clearSearch();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Search',
                style: TextStyle(color: Color(0xFF25D366)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChatsTab() {
    return Column(
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
              controller: controller.searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Ask Meta AI or Search',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),

        // Archived Section (Static for now)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.archive,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Archived',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content Area
        Expanded(
          child: Obx(() {
            // Show search results when searching
            if (controller.searchQuery.value.isNotEmpty) {
              return _buildSearchResults(controller);
            }
            
            // Show friends list
            return _buildFriendsList(controller);
          }),
        ),
      ],
    );
  }

  Widget _buildUpdatesTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.update,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Updates',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Status updates from your friends will appear here',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCallsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.call,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Calls',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your recent calls will appear here',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Show user profile dialog
  void _showUserProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A3942),
          title: const Text(
            'Profile',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Image
              buildProfileImage(
                imageUrl: userProfileImage,
                radius: 50,
                fallbackText: userName,
                backgroundColor: const Color(0xFF25D366),
              ),
              const SizedBox(height: 16),
              // User Name
              Text(
                userName.isNotEmpty ? userName : 'Unknown User',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // User Email
              Text(
                userEmail.isNotEmpty ? userEmail : 'No email',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              // Login Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Logged In',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showLogoutDialog();
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show logout confirmation dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A3942),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                // Show loading
                Get.dialog(
                  const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF25D366),
                    ),
                  ),
                  barrierDismissible: false,
                );
                
                try {
                  // Use AuthController's logout method
                  await authController.logoutUser();
                  
                  // Close loading dialog and navigate to auth launcher
                  Get.offAllNamed(RoutersConst.welcome);
                  
                  // Show logout success message
                  Get.snackbar(
                    'Logged Out',
                    'You have been logged out successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } catch (e) {
                  // Close loading dialog
                  Get.back();
                  
                  // Show error message
                  Get.snackbar(
                    'Error',
                    'Failed to logout: $e',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
  static Widget buildProfileImage({
    required String? imageUrl,
    required double radius,
    required String fallbackText,
    Color backgroundColor = const Color(0xFF25D366),
    Color fallbackTextColor = Colors.white,
    Color placeholderColor = Colors.white,
  }) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: radius,
          backgroundImage: imageProvider,
          backgroundColor: backgroundColor,
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor,
          child: SizedBox(
            width: radius * 0.6,
            height: radius * 0.6,
            child: CircularProgressIndicator(
              color: placeholderColor,
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          print('Error loading profile image: $error');
          return CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor,
            child: Text(
              fallbackText.isNotEmpty ? fallbackText.substring(0, 1).toUpperCase() : 'U',
              style: TextStyle(
                color: fallbackTextColor,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.6,
              ),
            ),
          );
        },
        // Add retry mechanism
        memCacheWidth: (radius * 2 * 2).toInt(), // 2x for retina displays
        memCacheHeight: (radius * 2 * 2).toInt(),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 100),
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: Text(
          fallbackText.isNotEmpty ? fallbackText.substring(0, 1).toUpperCase() : 'U',
          style: TextStyle(
            color: fallbackTextColor,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.6,
          ),
        ),
      );
    }
  }
} 