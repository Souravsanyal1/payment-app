import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';

class AffiliateScreen extends StatelessWidget {
  const AffiliateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController _authController = Get.find();
    final FirestoreService _firestore = FirestoreService();

    return Obx(() {
      final firebaseUser = _authController.firebaseUser;
      if (firebaseUser == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

      return StreamBuilder<UserModel>(
        stream: _firestore.userStream(firebaseUser.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          final userData = snapshot.data!;
          final referralLink = 'https://guru-pay.web.app/register?ref=${userData.id}';

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: _firestore.userTransactionsStream(userData.id),
            builder: (context, txSnapshot) {
              return Scaffold(
                backgroundColor: AppColors.background,
                appBar: AppBar(
                  title: const Text('Partner Program', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
                    onPressed: () => Get.back(),
                  ),
                ),
                body: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 20),
                          _buildPremiumCommissionCard(userData),
                          const SizedBox(height: 40),
                          const Text('GROW YOUR NETWORK', style: TextStyle(color: AppColors.textBody, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          const SizedBox(height: 15),
                          _buildReferralSection(context, referralLink),
                          const SizedBox(height: 40),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Recent Referrals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                              Text('Live Feed', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ]),
                      ),
                    ),
                    _buildReferralHistory(txSnapshot),
                    const SliverToBoxAdapter(child: SizedBox(height: 30)),
                  ],
                ),
              );
            },
          );
        }
      );
    });
  }

  Widget _buildReferralHistory(AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
    if (!snapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
    final refs = snapshot.data!.where((tx) => tx['type'] == 'referral_bonus').toList();
    
    if (refs.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: Text('No referral earnings yet', style: TextStyle(color: Colors.white38)),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final tx = refs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _historyTile(tx['user_email'] ?? 'Referral Bonus', '+\$${tx['amount'].toStringAsFixed(2)}', 'Success'),
            );
          },
          childCount: refs.length,
        ),
      ),
    );
  }

  Widget _buildPremiumCommissionCard(UserModel user) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              height: 160,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL EARNINGS', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  Text(
                    '\$${user.referralEarnings.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1),
                  ),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('WITHDRAW COMMISSION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralSection(BuildContext context, String link) {
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
          const Text('Your uniquely generated partner link:', style: TextStyle(color: AppColors.textBody, fontSize: 13)),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(child: Text(link, style: const TextStyle(fontSize: 12, color: Colors.white70, overflow: TextOverflow.ellipsis))),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: link));
                    Get.snackbar('Copied', 'Link Copied!', snackPosition: SnackPosition.TOP, backgroundColor: AppColors.primary, colorText: Colors.white);
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyTile(String name, String amount, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.people_alt_rounded, color: AppColors.success, size: 18),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                Text(status, style: const TextStyle(color: AppColors.textBody, fontSize: 11)),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
