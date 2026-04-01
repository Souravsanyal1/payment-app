import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import 'add_fund_screen.dart';
import 'merchant_settings_screen.dart';
import 'invoice_list_screen.dart';
import 'affiliate_screen.dart';
import 'support_screen.dart';
import 'admin_dashboard_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firestore = FirestoreService();

    return Scaffold(
      body: StreamBuilder<UserModel>(
        stream: firestore.userStream(authService.user!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final user = snapshot.data!;

          return CustomScrollView(
            slivers: [
              _buildHeader(context, user, authService),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBalanceCard(user),
                      const SizedBox(height: 30),
                      _buildActionGrid(context),
                      const SizedBox(height: 40),
                      const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      _buildRecentTransactions(user.id),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user, AuthService auth) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        title: Row(
          children: [
            GestureDetector(
              onLongPress: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen())),
              child: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hello,', style: TextStyle(fontSize: 12, color: AppColors.textBody)),
                Text(user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen())),
          icon: const Icon(Icons.support_agent, color: Colors.white60),
        ),
        IconButton(
          onPressed: () => auth.signOut(),
          icon: const Icon(Icons.logout, color: AppColors.error),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Balance', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            '\$${user.balance.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('API Key: ${user.apiKey.substring(0, 8)}...', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              const Icon(Icons.copy, color: Colors.white60, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 20,
      crossAxisSpacing: 10,
      children: [
        _actionItem(Icons.add_circle_outline, 'Add Fund', context, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFundScreen()));
        }),
        _actionItem(Icons.api, 'Merchant', context, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MerchantSettingsScreen()));
        }),
        _actionItem(Icons.receipt_long_outlined, 'Invoices', context, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceListScreen()));
        }),
        _actionItem(Icons.people_outline, 'Affiliate', context, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AffiliateScreen()));
        }),
      ],
    );
  }

  Widget _actionItem(IconData icon, String label, BuildContext context, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textBody)),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(String userId) {
    // Placeholder for now, real data later
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_downward, color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Deposit USDT', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Binance TRC20', style: TextStyle(fontSize: 12, color: AppColors.textBody)),
                  ],
                ),
              ),
              const Text('+\$100.37', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
            ],
          ),
        );
      },
    );
  }
}
