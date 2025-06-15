import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pingmexx/controller/spam_controller.dart';
import 'package:pingmexx/data/bean/friend/friend_model.dart';
import 'package:pingmexx/data/bean/spam/spam_model.dart';
import 'package:pingmexx/data/repo/firestore_service.dart';
import 'package:pingmexx/utils/widgethelper/widget_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pingmexx/view/chat/chat_detail_screen.dart';
import 'package:pingmexx/data/bean/user/user_model.dart';

class ReportedUsersScreen extends StatefulWidget {
  final UserModel? viewingUser;
  const ReportedUsersScreen({Key? key, this.viewingUser}) : super(key: key);

  @override
  State<ReportedUsersScreen> createState() => _ReportedUsersScreenState();
}

class _ReportedUsersScreenState extends State<ReportedUsersScreen> with SingleTickerProviderStateMixin {
  final SpamController controller = Get.find<SpamController>();
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  late TabController _tabController;
  bool isViewingOtherUser = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    isViewingOtherUser = widget.viewingUser != null;
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = '';
      });

      if (isViewingOtherUser) {
        // Load reports for the viewed user
        await controller.loadUserReports(widget.viewingUser!.email!);
        await controller.loadReportsAgainstUser(widget.viewingUser!.email!);
      } else {
        // Load reports for current user
        await controller.loadMyReports();
        await controller.loadReportsAgainstMe();
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = e.toString();
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111B21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF202C33),
        elevation: 0,
        title: Text(
          isViewingOtherUser ? 'User Reports' : 'My Reports',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadReports,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF25D366),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: isViewingOtherUser ? 'Reports Made' : 'My Reports'),
            Tab(text: isViewingOtherUser ? 'Reports Against' : 'Reports Against Me'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Reports List
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF25D366),
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReports,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildReportsList(controller.myReports),
        _buildReportsList(controller.reportsAgainstMe),
      ],
    );
  }

  Widget _buildReportsList(RxList<SpamModel> reports) {
    return Obx(() {
      if (reports.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                reports == controller.myReports ? Icons.report_off : Icons.security,
                color: Colors.grey,
                size: 80,
              ),
              const SizedBox(height: 16),
              Text(
                reports == controller.myReports
                    ? isViewingOtherUser
                        ? 'No Reports Made'
                        : 'No Reported Users'
                    : isViewingOtherUser
                        ? 'No Reports Against User'
                        : 'No Reports Against You',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reports == controller.myReports
                    ? isViewingOtherUser
                        ? 'This user hasn\'t reported anyone yet'
                        : 'You haven\'t reported any users yet'
                    : isViewingOtherUser
                        ? 'No one has reported this user yet'
                        : 'No one has reported you yet',
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
          _loadReports();
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return _buildReportCard(report);
          },
        ),
      );
    });
  }

  Widget _buildReportCard(SpamModel report) {
    return GestureDetector(
      onTap: () async {
        try {
          String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
          String friendId = FirestoreService.generateFriendId(currentUserEmail, report.reportedEmail!);
          FriendModel? friend = await FirestoreService.getFriendById(friendId);
          if (friend != null) {
            Get.to(() => ChatDetailScreen(friend: friend));
          } else {
            getSnackBar(
              title: 'Error',
              subTitle: 'Could not find chat with this user',
              isSuccess: false,
            );
          }
        } catch (e) {
          getSnackBar(
            title: 'Error',
            subTitle: 'Failed to open chat: $e',
            isSuccess: false,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF202C33),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[600],
            child: Text(
              report.reportedEmail?.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          title: Text(
            report.reportedEmail ?? 'Unknown User',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (report.reason != null && report.reason!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 2),
                  child: Text(
                    report.reason!,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Text(
                'Reported on: ${_formatDate(report.reportedAt)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 6),
              _buildStatusChip(report.status),
            ],
          ),
          trailing: isViewingOtherUser ? null : PopupMenuButton<SpamStatus>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF2A3942),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SpamStatus.underReview,
                child: Text('Mark as Under Review', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: SpamStatus.confirmed,
                child: Text('Confirm as Spam', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: SpamStatus.falseReport,
                child: Text('Mark as False Report', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: SpamStatus.resolved,
                child: Text('Mark as Resolved', style: TextStyle(color: Colors.white)),
              ),
            ],
            onSelected: (status) async {
              try {
                await controller.updateSpamStatus(report.id!, status);
                getSnackBar(
                  title: 'Success',
                  subTitle: 'Report status updated',
                  isSuccess: true,
                );
              } catch (e) {
                getSnackBar(
                  title: 'Error',
                  subTitle: 'Failed to update status: $e',
                  isSuccess: false,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(SpamStatus status) {
    Color color;
    String text;

    switch (status) {
      case SpamStatus.reported:
        color = Colors.orange;
        text = 'Reported';
        break;
      case SpamStatus.underReview:
        color = Colors.blue;
        text = 'Under Review';
        break;
      case SpamStatus.confirmed:
        color = Colors.red;
        text = 'Confirmed Spam';
        break;
      case SpamStatus.falseReport:
        color = Colors.grey;
        text = 'False Report';
        break;
      case SpamStatus.resolved:
        color = Colors.green;
        text = 'Resolved';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    return '${date.day}/${date.month}/${date.year}';
  }
} 