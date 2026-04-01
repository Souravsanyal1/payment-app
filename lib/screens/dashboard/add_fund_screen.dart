import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import 'payment_portal_screen.dart';

class AddFundScreen extends StatefulWidget {
  const AddFundScreen({super.key});

  @override
  State<AddFundScreen> createState() => _AddFundScreenState();
}

class _AddFundScreenState extends State<AddFundScreen> {
  final _amountController = TextEditingController();
  String _selectedMethod = 'binance';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Funds', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Amount (USD)',
              style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.attach_money, color: AppColors.secondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                hintText: '0.00',
                hintStyle: const TextStyle(color: Colors.white24),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Select Initial Method',
              style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            _methodTile('binance', 'Binance USDT (Auto)', Icons.currency_bitcoin_rounded, Colors.orange),
            const SizedBox(height: 12),
            _methodTile('manual', 'Bkash / Nagad (Manual)', Icons.phone_android, AppColors.secondary),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(_amountController.text) ?? 0;
                  if (amount <= 0) {
                    Get.snackbar('Error', 'Please enter a valid amount', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
                    return;
                  }

                  Get.to(() => PaymentPortalScreen(amount: amount));
                },
                child: const Text('CONTINUE TO CHECKOUT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _methodTile(String id, String name, IconData icon, Color color) {
    bool isSelected = _selectedMethod == id;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = id),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}
