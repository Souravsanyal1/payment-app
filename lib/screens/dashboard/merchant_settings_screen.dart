import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import 'package:flutter/services.dart';

class MerchantSettingsScreen extends StatelessWidget {
  const MerchantSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Merchant API Settings')),
      body: StreamBuilder<UserModel>(
        stream: firestore.userStream(authService.user!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Secret API Key', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.apiKey,
                          style: const TextStyle(fontFamily: 'monospace', color: AppColors.primary),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: user.apiKey));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API Key copied!')));
                        },
                        icon: const Icon(Icons.copy, size: 20, color: Colors.white60),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                const Text('Merchant Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _summaryTile('Total Earning', '\$0.00', Icons.monetization_on_outlined),
                const SizedBox(height: 12),
                _summaryTile('Active Invoices', '0', Icons.receipt_outlined),
                const SizedBox(height: 12),
                _summaryTile('Settlement Status', 'Active', Icons.verified_user_outlined),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('GENERATE NEW KEY'),
                ),
                const SizedBox(height: 16),
                const Text(
                  '⚠️ Keep your secret key safe! Do not share it with anyone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _summaryTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 15),
          Text(label, style: const TextStyle(color: AppColors.textBody)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
