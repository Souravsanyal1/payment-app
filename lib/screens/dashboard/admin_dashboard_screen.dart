import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAdminStats(),
            const SizedBox(height: 32),
            const Text('Pending Approvals', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _pendingTile('Kamal Hasan', 'Bkash', '\$100.00', 'TRX992831'),
            const SizedBox(height: 12),
            _pendingTile('Jasmine Akter', 'Nagad', '\$50.00', 'TRX123456'),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminStats() {
    return Row(
      children: [
        _statBox('Users', '1,250'),
        const SizedBox(width: 15),
        _statBox('Volume', '\$25.5K'),
      ],
    );
  }

  Widget _statBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: AppColors.textBody, fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _pendingTile(String name, String gateway, String amount, String trxId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$gateway - $trxId', style: const TextStyle(fontSize: 12, color: AppColors.textBody)),
              Row(
                children: [
                  TextButton(onPressed: () {}, child: const Text('REJECT', style: TextStyle(color: AppColors.error, fontSize: 10))),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(minimumSize: const Size(80, 30), padding: EdgeInsets.zero),
                    child: const Text('APPROVE', style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
