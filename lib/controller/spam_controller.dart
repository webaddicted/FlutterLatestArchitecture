import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pingmexx/utils/common/global_utilities.dart';
import '../data/repo/firestore_service.dart';
import '../data/bean/spam/spam_model.dart';
import '../data/bean/friend/friend_model.dart';
import 'package:pingmexx/utils/widgethelper/widget_helper.dart';

class SpamController extends GetxController {
  RxList<SpamModel> myReports = <SpamModel>[].obs;
  RxList<SpamModel> reportsAgainstMe = <SpamModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // loadMyReports();
    // loadReportsAgainstMe();
  }

  Future<void> loadMyReports() async {
    try {
      isLoading.value = true;
      String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      if (currentUserEmail.isEmpty) return;

      List<SpamModel> reports = await FirestoreService.getSpamReportsByReporter(currentUserEmail);
      myReports.value = reports;
    } catch (e) {
      printLog(msg: 'Failed to load your reports: $e');
      showSnackBar(Get.context!, 'Failed to load your reports: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadReportsAgainstMe() async {
    try {
      isLoading.value = true;
      String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      if (currentUserEmail.isEmpty) return;

      List<SpamModel> reports = await FirestoreService.getSpamReportsByReported(currentUserEmail);
      reportsAgainstMe.value = reports;
    } catch (e) {
      showSnackBar(Get.context!, 'Failed to load reports against you: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserReports(String userId) async {
    try {
      isLoading.value = true;
      List<SpamModel> reports = await FirestoreService.getSpamReportsByReporter(userId);
      myReports.value = reports;
    } catch (e) {
      printLog(msg: 'Failed to load user reports: $e');
      showSnackBar(Get.context!, 'Failed to load user reports: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadReportsAgainstUser(String userId) async {
    try {
      isLoading.value = true;
      List<SpamModel> reports = await FirestoreService.getSpamReportsByReported(userId);
      reportsAgainstMe.value = reports;
    } catch (e) {
      showSnackBar(Get.context!, 'Failed to load reports against user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, int>> getMyReportCounts() async {
    try {
      String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      if (currentUserEmail.isEmpty) return {'spamMeReportedOtherCount': 0, 'spamOtherReportedMeCount': 0};

      int reportedOthers = await FirestoreService.getSpamReportCount(currentUserEmail);
      int reportedByOthers = await FirestoreService.getSpamReportsAgainstCount(currentUserEmail);

      return {
        'spamMeReportedOtherCount': reportedOthers,
        'spamOtherReportedMeCount': reportedByOthers,
      };
    } catch (e) {
      showSnackBar(Get.context!, 'Failed to get report counts: $e');
      return {'spamMeReportedOtherCount': 0, 'spamOtherReportedMeCount': 0};
    }
  }

  Future<Map<String, int>> getUserReportCounts(String userId) async {
    try {
      int reportedOthers = await FirestoreService.getSpamReportCount(userId);
      int reportedByOthers = await FirestoreService.getSpamReportsAgainstCount(userId);

      return {
        'spamMeReportedOtherCount': reportedOthers,
        'spamOtherReportedMeCount': reportedByOthers,
      };
    } catch (e) {
      showSnackBar(Get.context!, 'Failed to get user report counts: $e');
      return {'spamMeReportedOtherCount': 0, 'spamOtherReportedMeCount': 0};
    }
  }

  Future<void> reportSpam({
    required String reportedEmail,
    required String friendId,
    String? reason,
  }) async {
    try {
      String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      if (currentUserEmail.isEmpty) {
        showSnackBar(Get.context!, 'User not authenticated');
        return;
      }

      await FirestoreService.reportSpam(
        reporterEmail: currentUserEmail,
        reportedEmail: reportedEmail,
        friendId: friendId,
        reason: reason,
      );

      showSnackBar(Get.context!, 'User reported successfully');
      loadMyReports();
    } catch (e) {
      if (e.toString().contains('already_reported')) {
        showSnackBar(Get.context!, 'You have already reported this user');
      } else {
        showSnackBar(Get.context!, 'Failed to report user: $e');
      }
    }
  }

  Future<void> updateSpamStatus(String reportId, SpamStatus newStatus) async {
    try {
      isLoading.value = true;
      await FirestoreService.updateSpamStatus(reportId, newStatus);
      
      String statusMessage = '';
      switch (newStatus) {
        case SpamStatus.resolved:
          statusMessage = 'Report resolved successfully';
          break;
        case SpamStatus.underReview:
          statusMessage = 'Report is now under review';
          break;
        case SpamStatus.confirmed:
          statusMessage = 'Spam has been confirmed';
          break;
        case SpamStatus.falseReport:
          statusMessage = 'Report marked as false';
          break;
        default:
          statusMessage = 'Report status updated';
      }
      
      showSnackBar(Get.context!, statusMessage);
      loadMyReports();
      loadReportsAgainstMe();
    } catch (e) {
      showSnackBar(Get.context!, 'Failed to update report status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Convenience methods for different status updates
  Future<void> resolveSpamReport(String reportId) async {
    await updateSpamStatus(reportId, SpamStatus.resolved);
  }

  Future<void> markAsUnderReview(String reportId) async {
    await updateSpamStatus(reportId, SpamStatus.underReview);
  }

  Future<void> confirmSpam(String reportId) async {
    await updateSpamStatus(reportId, SpamStatus.confirmed);
  }

  Future<void> markAsFalseReport(String reportId) async {
    await updateSpamStatus(reportId, SpamStatus.falseReport);
  }

  Future<int> getMyReportCount() async {
    try {
      String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      if (currentUserEmail.isEmpty) return 0;

      return await FirestoreService.getSpamReportCount(currentUserEmail);
    } catch (e) {
      showSnackBar(Get.context!, 'Failed to get report count: $e');
      return 0;
    }
  }
} 