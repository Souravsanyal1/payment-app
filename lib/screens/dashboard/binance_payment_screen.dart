import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/payment_utils.dart';
import '../../services/firestore_service.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class BinancePaymentScreen extends StatefulWidget {
  final double amount;
  const BinancePaymentScreen({super.key, required this.amount});

  @override
  State<BinancePaymentScreen> createState() => _BinancePaymentScreenState();
}

class _BinancePaymentScreenState extends State<BinancePaymentScreen> {
  late double _uniqueAmount;
  final _walletAddress = 'T9yD... (Your Binance Wallet)'; // TODO: Load from config
  final _firestore = FirestoreService();
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _uniqueAmount = PaymentUtils.generateUniqueAmount(widget.amount);
    _initiatePayment();
  }

  void _initiatePayment() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    await _firestore.logTransaction(
      auth.user!.uid,
      _uniqueAmount,
      'deposit',
      'pending',
      'BINANCE_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Binance USDT (TRC20)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.qr_code_2, size: 200, color: Colors.white),
            const SizedBox(height: 30),
            const Text('Please send EXACTLY the amount below:', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(
              '\$${_uniqueAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 30),
            _infoTile('Network', 'TRON (TRC20)'),
            const SizedBox(height: 12),
            _infoTile('Wallet Address', _walletAddress, copyable: true),
            const SizedBox(height: 48),
            const Text(
              '⚠️ Warning: Sending a different amount will cause delays in verification.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.error, fontSize: 12),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isChecking ? null : () {
                setState(() => _isChecking = true);
                // In production, this would trigger a backend check
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    setState(() => _isChecking = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment not detected yet. Please wait...')),
                    );
                  }
                });
              },
              child: _isChecking ? const CircularProgressIndicator(color: Colors.white) : const Text('CHECK STATUS'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value, {bool copyable = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textBody)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          if (copyable) const Icon(Icons.copy, size: 18, color: AppColors.primary),
        ],
      ),
    );
  }
}
