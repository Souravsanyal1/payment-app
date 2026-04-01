import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/admin_controller.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize AdminController when entering this screen
    final controller = Get.put(AdminController());
    final TextEditingController _referralInput = TextEditingController();

    // Sync referral percent to text input once it's loaded
    ever(controller.referralPercent, (val) {
      _referralInput.text = val.toString();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Command Center', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 60),
                const SizedBox(height: 16),
                Text(controller.error.value, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: () => controller.fetchStats(), child: const Text('Retry')),
              ],
            ),
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildLiveStats(controller),
                    const SizedBox(height: 30),
                    _buildReferralCommandCard(controller, _referralInput),
                    const SizedBox(height: 40),
                    const Row(
                      children: [
                        Icon(Icons.notifications_active_rounded, color: AppColors.secondary, size: 22),
                        SizedBox(width: 12),
                        Text('Incoming Requests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildLiveFeed(controller),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      }),
    );
  }

  Widget _buildReferralCommandCard(AdminController controller, TextEditingController input) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars_rounded, color: Colors.orange, size: 24),
              SizedBox(width: 12),
              Text('Referral System Config', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Set the commission percentage for all partner referrals.', style: TextStyle(color: AppColors.textBody, fontSize: 12)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextFormField(
                    controller: input,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      suffixText: '%',
                      suffixStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      hintText: '0.0',
                      hintStyle: TextStyle(color: Colors.white24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              SizedBox(
                height: 55,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () {
                    final val = double.tryParse(input.text);
                    if (val != null) controller.updateReferralPercent(val);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: controller.isLoading.value 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('UPDATE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStats(AdminController controller) {
    return Row(
      children: [
        Expanded(
          child: _statBox(
            'Total Users', 
            '${controller.totalUsers.value}', 
            Icons.people_alt_rounded, 
            AppColors.primary
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _statBox(
            'Total Volume', 
            '\$${controller.totalVolume.value.toStringAsFixed(1)}k', 
            Icons.account_balance_wallet_rounded, 
            AppColors.success
          ),
        ),
      ],
    );
  }

  Widget _statBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 20),
          Text(label, style: const TextStyle(color: AppColors.textBody, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildLiveFeed(AdminController controller) {
    final docs = controller.pendingTransactions;
    
    if (docs.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(
              children: [
                Icon(Icons.done_all_rounded, color: Colors.white.withOpacity(0.1), size: 60),
                const SizedBox(height: 15),
                const Text('All caught up! No pending requests.', style: TextStyle(color: AppColors.textBody)),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final tx = docs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _notificationCard(context, controller, tx),
            );
          },
          childCount: docs.length,
        ),
      ),
    );
  }

  Widget _notificationCard(BuildContext context, AdminController controller, Map<String, dynamic> tx) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(tx['user_name']?[0].toUpperCase() ?? 'U', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx['user_name'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(tx['user_email'] ?? 'No email available', style: const TextStyle(fontSize: 11, color: AppColors.textBody)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${tx['amount'].toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.success),
                  ),
                  Text(
                    '৳${(tx['amount'] * 115.0).toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12, color: AppColors.success.withOpacity(0.7), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white12),
          Text(
            'Type: ${tx['type'].toString().toUpperCase()}',
            style: const TextStyle(fontSize: 11, color: AppColors.textBody, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            'TRX ID: ${tx['trx_id']}',
            style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.reject(tx['id']),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('REJECT', style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.approve(tx['id'], tx['user_id'], tx['amount'].toDouble()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('APPROVE', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
