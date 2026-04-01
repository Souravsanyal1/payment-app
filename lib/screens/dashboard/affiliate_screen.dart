import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'package:flutter/services.dart';

class AffiliateScreen extends StatelessWidget {
  const AffiliateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const referralLink = 'https://royelpay.com/ref/user123';

    return Scaffold(
      appBar: AppBar(title: const Text('Affiliate Program')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildCommissionCard(),
            const SizedBox(height: 32),
            _buildReferralSection(context, referralLink),
            const SizedBox(height: 48),
            const Text('Referral History', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _historyTile('Kamal Hasan', '+\$5.00'),
            const SizedBox(height: 12),
            _historyTile('Jasmine Akter', '+\$2.50'),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text('Total Commission Earned', style: TextStyle(color: AppColors.textBody)),
          const SizedBox(height: 12),
          const Text(
            '\$125.50',
            style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(minimumSize: const Size(150, 45)),
            child: const Text('WITHDRAW'),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralSection(BuildContext context, String link) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Referral Link', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(child: Text(link, style: const TextStyle(fontSize: 12, color: AppColors.textBody))),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: link));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link Copied!')));
                },
                icon: const Icon(Icons.copy, size: 20, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _historyTile(String name, String amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(amount, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
