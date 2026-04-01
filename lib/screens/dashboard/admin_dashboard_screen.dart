import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../services/firestore_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Authority', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAdminStats(),
            const SizedBox(height: 40),
            const Row(
              children: [
                Icon(Icons.pending_actions_rounded, color: Colors.orange, size: 20),
                SizedBox(width: 10),
                Text('Pending Approvals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 20),
            _buildPendingList(firestore),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminStats() {
    return Row(
      children: [
        _statBox('Registered Users', '1.2K', Icons.people_alt_outlined, AppColors.primary),
        const SizedBox(width: 15),
        _statBox('Total Volume', '\$85.2K', Icons.account_balance_wallet_outlined, AppColors.secondary),
      ],
    );
  }

  Widget _statBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 16),
            Text(label, style: const TextStyle(color: AppColors.textBody, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingList(FirestoreService firestore) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestore.pendingTransactionsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!;
        if (docs.isEmpty) return const Center(child: Text('No pending requests', style: TextStyle(color: AppColors.textBody)));

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 15),
          itemBuilder: (context, index) {
            final tx = docs[index];
            return _pendingTile(context, firestore, tx);
          },
        );
      },
    );
  }

  Widget _pendingTile(BuildContext context, FirestoreService firestore, Map<String, dynamic> tx) {
    final date = DateTime.fromMillisecondsSinceEpoch(tx['timestamp']);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User ID: ${tx['user_id'].substring(0, 8)}...', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                  Text(DateFormat('MMM dd, hh:mm a').format(date), style: const TextStyle(fontSize: 11, color: AppColors.textBody)),
                ],
              ),
              Text('\$${tx['amount'].toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.success)),
            ],
          ),
          const Divider(height: 30, color: Colors.white12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TRX: ${tx['trx_id']}', style: const TextStyle(fontSize: 12, color: AppColors.textBody, fontStyle: FontStyle.italic)),
              Row(
                children: [
                  TextButton(
                    onPressed: () {}, 
                    child: const Text('REJECT', style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold))
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _approve(context, firestore, tx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      minimumSize: const Size(100, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('APPROVE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _approve(BuildContext context, FirestoreService firestore, Map<String, dynamic> tx) async {
    try {
      await firestore.approveTransaction(tx['id'], tx['user_id'], tx['amount'].toDouble());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction Approved!'), backgroundColor: AppColors.success));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
  }
}
