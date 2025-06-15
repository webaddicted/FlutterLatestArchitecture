import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pingmexx/data/repo/firestore_service.dart';
import 'package:pingmexx/utils/common/global_utilities.dart';
import 'package:pingmexx/utils/constant/routers_const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../controller/chat_controller.dart';
import '../../data/bean/user/user_model.dart';
import '../../utils/sp/sp_manager.dart';
import '../../view/profile/reported_users_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String? uuid;
  const UserProfileScreen({Key? key, this.uuid}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late final ChatController controller;
  UserModel? userData;
  int spamMeReportedOtherCount = 0;
  int spamOtherReportedMeCount = 0;
  bool isLoading = true;
  bool isViewingOtherProfile = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    try {
      controller = Get.find<ChatController>();
    } catch (e) {
      controller = Get.put(ChatController());
    }
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => isLoading = true);

      // Fetch user data from Firestore
      userData = await FirestoreService.getUser(widget.uuid);
      
      if (userData == null) {
        throw Exception('User not found');
      }

      // Get report counts
      final counts = await controller.getUserReportCounts(widget.uuid);
      setState(() {
        spamMeReportedOtherCount = counts['spamMeReportedOtherCount'] ?? 0;
        spamOtherReportedMeCount = counts['spamOtherReportedMeCount'] ?? 0;
      });

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load user data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF111B21),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF25D366),
          ),
        ),
      );
    }

    if (userData == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF111B21),
        body: Center(
          child: Text(
            'User data not found',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111B21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF202C33),
        title: Text(
          isViewingOtherProfile ? 'User Profile' : 'My Profile',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => back(),
        ),
        actions: [
          if (!isViewingOtherProfile)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                // TODO: Navigate to edit profile screen
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                        AppBar().preferredSize.height - 
                        MediaQuery.of(context).padding.top,
            ),
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(20),
                  color: const Color(0xFF202C33),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[600],
                        ),
                        child: userData?.profileImage != null && userData!.profileImage!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: CachedNetworkImage(
                                  imageUrl: userData!.profileImage!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF25D366),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Center(
                                    child: Text(
                                      userData?.name?.substring(0, 1).toUpperCase() ?? 'U',
                                      style: const TextStyle(
                                        fontSize: 40,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  userData?.name?.substring(0, 1).toUpperCase() ?? 'U',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userData?.name ?? 'User',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userData?.email ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // User Details
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF202C33),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailTile(
                        icon: Icons.person,
                        title: 'Bio',
                        value: userData?.bio ?? 'No bio yet',
                      ),
                      _buildDetailTile(
                        icon: Icons.phone,
                        title: 'Phone',
                        value: userData?.phoneNumber ?? 'Not set',
                      ),
                      _buildDetailTile(
                        icon: Icons.wc,
                        title: 'Gender',
                        value: userData?.gender ?? 'Not set',
                      ),
                      _buildDetailTile(
                        icon: Icons.calendar_today,
                        title: 'Joined',
                        value: userData?.createdAt != null
                            ? '${userData!.createdAt!.day}/${userData!.createdAt!.month}/${userData!.createdAt!.year}'
                            : 'Unknown',
                      ),
                    ],
                  ),
                ),

                // Report Statistics
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF202C33),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: (){
                      Get.to(() => ReportedUsersScreen(viewingUser: userData));
                    },
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Report Statistics',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildDetailTile(
                          icon: Icons.flag,
                          title: 'Users Reported',
                          value: spamMeReportedOtherCount.toString(),
                        ),
                        _buildDetailTile(
                          icon: Icons.warning,
                          title: 'Times Reported',
                          value: spamOtherReportedMeCount.toString(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Account Actions - Only show for current user
                if (!isViewingOtherProfile)
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF202C33),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();
                            await SPManager.clearUserData();
                            Get.offAllNamed(RoutersConst.login);
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
} 