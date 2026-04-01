import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'binance_payment_screen.dart';
import 'manual_payment_screen.dart';

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
      appBar: AppBar(title: const Text('Add Funds')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.attach_money, color: AppColors.primary),
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 32),
            const Text('Select Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _methodTile('binance', 'Binance USDT (Auto)', Icons.account_balance_wallet, AppColors.primary),
            const SizedBox(height: 12),
            _methodTile('manual', 'Bkash / Nagad (Manual)', Icons.phone_android, AppColors.secondary),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text) ?? 0;
                if (amount <= 0) return;

                if (_selectedMethod == 'binance') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => BinancePaymentScreen(amount: amount)));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ManualPaymentScreen(amount: amount)));
                }
              },
              child: const Text('CONTINUE'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _methodTile(String id, String title, IconData icon, Color color) {
    final isSelected = _selectedMethod == id;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 15),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }
}
