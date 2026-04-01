import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
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
      backgroundColor: AppColors.background,
      body: StreamBuilder<UserModel>(
        stream: firestore.userStream(authService.user!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final user = snapshot.data!;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(context, user, authService),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGlassBalanceCard(user),
                      const SizedBox(height: 30),
                      _buildActionGrid(context),
                      const SizedBox(height: 30),
                      const Text('Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      _buildEarningsChart(),
                      const SizedBox(height: 40),
                      const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      _buildRealTransactionsList(firestore, user.id),
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
      expandedHeight: 100,
      backgroundColor: AppColors.background,
      elevation: 0,
      pinned: true,
      title: Row(
        children: [
          GestureDetector(
            onLongPress: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen())),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Welcome back,', style: TextStyle(fontSize: 11, color: AppColors.textBody)),
              Text(user.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen())),
          icon: const Icon(Icons.notifications_none, color: Colors.white70),
        ),
        IconButton(
          onPressed: () => auth.signOut(),
          icon: const Icon(Icons.logout_rounded, color: AppColors.error),
        ),
      ],
    );
  }

  Widget _buildGlassBalanceCard(UserModel user) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            right: -20,
            top: -20,
            child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.05)),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              height: 180,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('MAIN BALANCE', style: TextStyle(color: Colors.white60, letterSpacing: 1.2, fontSize: 10, fontWeight: FontWeight.bold)),
                      Image.network('https://royelpay.com/favicon.png', height: 24, errorBuilder: (_, __, ___) => const Icon(Icons.account_balance_wallet, color: Colors.white54)),
                    ],
                  ),
                  Text(
                    '\$${user.balance.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.api, color: Colors.white54, size: 14),
                      const SizedBox(width: 8),
                      Text('Merchant ID: ${user.apiKey.substring(8, 16)}...', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 3),
                const FlSpot(2, 5),
                const FlSpot(4, 4),
                const FlSpot(6, 8),
                const FlSpot(8, 7),
                const FlSpot(10, 10),
              ],
              isCurved: true,
              color: AppColors.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionSquare(Icons.add_card, 'Add Fund', context, const AddFundScreen(), AppColors.success),
        _actionSquare(Icons.vpn_key_outlined, 'API Keys', context, const MerchantSettingsScreen(), AppColors.primary),
        _actionSquare(Icons.receipt_long, 'Invoices', context, const InvoiceListScreen(), Colors.orange),
        _actionSquare(Icons.share_outlined, 'Affiliate', context, const AffiliateScreen(), Colors.purple),
      ],
    );
  }

  Widget _actionSquare(IconData icon, String label, BuildContext context, Widget screen, Color color) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textBody, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildRealTransactionsList(FirestoreService firestore, String userId) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestore.userTransactionsStream(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!;
        if (docs.isEmpty) return const Center(child: Text('No transactions yet', style: TextStyle(color: AppColors.textBody)));

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length > 5 ? 5 : docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final tx = docs[index];
            final bool isDeposit = tx['type'].toString().contains('deposit');
            final date = DateTime.fromMillisecondsSinceEpoch(tx['timestamp']);

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isDeposit ? AppColors.success : AppColors.error).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(isDeposit ? Icons.arrow_downward : Icons.arrow_upward, color: isDeposit ? AppColors.success : AppColors.error, size: 20),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tx['type'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(DateFormat('MMM dd, hh:mm a').format(date), style: const TextStyle(fontSize: 11, color: AppColors.textBody)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isDeposit ? '+' : '-'}\$${tx['amount'].toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: isDeposit ? AppColors.success : AppColors.error),
                      ),
                      Text(tx['status'], style: TextStyle(fontSize: 10, color: _getStatusColor(tx['status']), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success': return AppColors.success;
      case 'pending': return Colors.orange;
      case 'failed': return AppColors.error;
      default: return AppColors.textBody;
    }
  }
}

