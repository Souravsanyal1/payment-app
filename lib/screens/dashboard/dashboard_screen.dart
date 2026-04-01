import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import 'add_fund_screen.dart';
import 'merchant_settings_screen.dart';
import 'invoice_list_screen.dart';
import 'affiliate_screen.dart';
import 'support_screen.dart';
import 'admin_dashboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final AuthController _authController = Get.find();
  final FirestoreService _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = _authController.firebaseUser;

      if (user == null) {
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return StreamBuilder<UserModel>(
        stream: _firestore.userStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(context, snapshot.error.toString());
          }
          
          if (!snapshot.hasData) return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator()));
          final userModel = snapshot.data!;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _currentIndex == 1 ? AppBar(
              title: const Text('Help Center', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
            ) : null,
            body: IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeContent(context, userModel),
                const SupportScreen(),
              ],
            ),
            bottomNavigationBar: _buildBottomNavBar(),
            floatingActionButton: _currentIndex == 1 ? _buildSupportFAB() : null,
          );
        },
      );
    });
  }

  Widget _buildSupportFAB() {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add_comment_rounded, color: Colors.white),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.8),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05), width: 0.5)),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.white38,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                activeIcon: Icon(Icons.home_filled, color: AppColors.primary),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.support_agent_rounded),
                activeIcon: Icon(Icons.support_agent_rounded, color: AppColors.primary),
                label: 'Support',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, UserModel user) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestore.userTransactionsStream(user.id),
      builder: (context, snapshot) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(context, user),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
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
                  ],
                ),
              ),
            ),
            _buildRealTransactionsList(snapshot),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              const Text('Configuration Required', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text(
                error.contains('permission-denied')
                    ? 'Please update your Firestore Security Rules in the Firebase Console.'
                    : 'Firebase Error: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textBody),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _authController.logout(),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Sign Out & Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user) {
    return SliverAppBar(
      expandedHeight: 100,
      backgroundColor: AppColors.background,
      elevation: 0,
      pinned: true,
      centerTitle: false,
      title: Row(
        children: [
          GestureDetector(
            onLongPress: () => Get.to(() => const AdminDashboardScreen()),
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
        if (user.role == 'admin')
          IconButton(
            onPressed: () => Get.to(() => const AdminDashboardScreen()),
            icon: const Icon(Icons.shield_rounded, color: AppColors.secondary),
            tooltip: 'Admin Panel',
          ),
        IconButton(
          onPressed: () => _authController.logout(),
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
                      const Icon(Icons.account_balance_wallet_rounded, color: Colors.white54, size: 24),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${user.balance.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1),
                      ),
                      Text(
                        '~ ৳${user.balanceBDT.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500),
                      ),
                    ],
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
      onTap: () => Get.to(() => screen),
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

  Widget _buildRealTransactionsList(AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
    if (!snapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
    final docs = snapshot.data!;
    if (docs.isEmpty) return const SliverToBoxAdapter(child: Center(child: Text('No transactions yet', style: TextStyle(color: AppColors.textBody))));

    final displayDocs = docs.length > 5 ? docs.sublist(0, 5) : docs;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final tx = displayDocs[index];
            final bool isDeposit = tx['type'].toString().contains('deposit');
            final date = DateTime.fromMillisecondsSinceEpoch(tx['timestamp']);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
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
                        Text(
                          '৳${(tx['amount'] * 115.0).toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 10, color: (isDeposit ? AppColors.success : AppColors.error).withOpacity(0.7)),
                        ),
                        Text(tx['status'].toString().toUpperCase(), style: TextStyle(fontSize: 10, color: _getStatusColor(tx['status']), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: displayDocs.length,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success': return AppColors.success;
      case 'pending': return Colors.orange;
      case 'rejected':
      case 'failed': return AppColors.error;
      default: return AppColors.textBody;
    }
  }
}
