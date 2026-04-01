import 'package:get/get.dart';
import '../services/firestore_service.dart';

class AdminController extends GetxController {
  final FirestoreService _firestore = FirestoreService();
  
  final RxInt totalUsers = 0.obs;
  final RxDouble totalVolume = 0.0.obs;
  final RxDouble referralPercent = 5.0.obs;
  final RxList<Map<String, dynamic>> pendingTransactions = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
    bindTransactions();
    fetchReferralPercent();
  }

  void fetchStats() async {
    try {
      totalUsers.value = await _firestore.getTotalUsersCount();
      totalVolume.value = await _firestore.getTotalTransactionVolume();
    } catch (e) {
      error.value = 'Failed to fetch stats: $e';
    }
  }

  void bindTransactions() {
    pendingTransactions.bindStream(_firestore.pendingTransactionsStream());
  }

  void fetchReferralPercent() async {
    referralPercent.value = await _firestore.getReferralBonusPercent();
  }

  Future<void> updateReferralPercent(double percent) async {
    isLoading.value = true;
    try {
      await _firestore.updateReferralBonusPercent(percent);
      referralPercent.value = percent;
      Get.snackbar('Success', 'Referral bonus updated!', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update referral percent: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approve(String id, String userId, double amount) async {
    try {
      await _firestore.approveTransaction(id, userId, amount);
      Get.snackbar('Approved', 'Transaction was successfully approved.', snackPosition: SnackPosition.BOTTOM);
      fetchStats(); // Update volume
    } catch (e) {
      Get.snackbar('Error', 'Approval failed: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> reject(String id) async {
    try {
      await _firestore.rejectTransaction(id);
      Get.snackbar('Rejected', 'Transaction was rejected.', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Rejection failed: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
