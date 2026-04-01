import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';

class MerchantSettingsScreen extends StatefulWidget {
  const MerchantSettingsScreen({super.key});

  @override
  State<MerchantSettingsScreen> createState() => _MerchantSettingsScreenState();
}

class _MerchantSettingsScreenState extends State<MerchantSettingsScreen> {
  bool _isKeyVisible = false;
  final AuthController _authController = Get.find();
  final FirestoreService _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Merchant API Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final firebaseUser = _authController.firebaseUser;
        if (firebaseUser == null) return const Center(child: CircularProgressIndicator());

        return StreamBuilder<UserModel>(
          stream: _firestore.userStream(firebaseUser.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            final user = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildApiCard(context, user.apiKey),
                  const SizedBox(height: 40),
                  const Text('MERCHANT INSIGHTS', style: TextStyle(color: AppColors.textBody, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 20),
                  _summaryTile('Total Earning', '\$${user.dailyEarnings.toStringAsFixed(2)}', Icons.monetization_on_outlined, AppColors.success),
                  const SizedBox(height: 12),
                  _summaryTile('Settlement Status', 'Verified & Active', Icons.verified_user_outlined, AppColors.primary),
                  const SizedBox(height: 40),
                  _buildSecurityAlert(),
                  const SizedBox(height: 50),
                  _buildFooterActions(),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildApiCard(BuildContext context, String apiKey) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('LIVE API SECRET', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() => _isKeyVisible = !_isKeyVisible),
                icon: Icon(_isKeyVisible ? Icons.visibility_off : Icons.visibility, color: Colors.white24, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _isKeyVisible ? apiKey : 'sk_live_••••••••••••••••••••••••••••',
              style: const TextStyle(fontFamily: 'monospace', color: Colors.white70, fontSize: 13, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: apiKey));
                Get.snackbar('Copied', 'API Key copied to clipboard', snackPosition: SnackPosition.TOP, backgroundColor: AppColors.primary, colorText: Colors.white);
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('COPY SECRET KEY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                foregroundColor: AppColors.primary,
                elevation: 0,
                side: const BorderSide(color: AppColors.primary, width: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textBody, fontSize: 12, fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white10, size: 14),
        ],
      ),
    );
  }

  Widget _buildSecurityAlert() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              'Keep your API Secret safe! Do not share it or commit it to GitHub.',
              style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterActions() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.03),
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('REGENERATE MASTER API KEY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
