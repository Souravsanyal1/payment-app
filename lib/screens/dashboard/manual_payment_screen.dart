import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/firestore_service.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class ManualPaymentScreen extends StatefulWidget {
  final double amount;
  const ManualPaymentScreen({super.key, required this.amount});

  @override
  State<ManualPaymentScreen> createState() => _ManualPaymentScreenState();
}

class _ManualPaymentScreenState extends State<ManualPaymentScreen> {
  final _trxController = TextEditingController();
  final _firestore = FirestoreService();
  String _gateway = 'bkash';
  bool _isSubmitting = false;

  void _submit() async {
    if (_trxController.text.isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      await _firestore.logTransaction(
        auth.user!.uid,
        widget.amount,
        'manual_deposit',
        'pending_approval',
        _trxController.text,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submission Successful! Pending admin approval.')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Amount to Pay:', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(
              '\$${widget.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.secondary),
            ),
            const SizedBox(height: 48),
            const Text('Select Gateway', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _gatewayChoice('bkash', 'Bkash'),
            const SizedBox(height: 12),
            _gatewayChoice('nagad', 'Nagad'),
            const SizedBox(height: 32),
            TextFormField(
              controller: _trxController,
              decoration: const InputDecoration(
                labelText: 'Transaction ID (TrxID)',
                prefixIcon: Icon(Icons.confirmation_number_outlined, color: AppColors.secondary),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('SUBMIT FOR APPROVAL'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gatewayChoice(String id, String title) {
    final isSelected = _gateway == id;
    return InkWell(
      onTap: () => setState(() => _gateway = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: isSelected ? Border.all(color: AppColors.secondary, width: 2) : null,
        ),
        child: Row(
          children: [
            const Icon(Icons.account_balance, color: AppColors.secondary),
            const SizedBox(width: 15),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.secondary),
          ],
        ),
      ),
    );
  }
}
