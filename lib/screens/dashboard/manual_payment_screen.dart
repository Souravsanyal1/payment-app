import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/firestore_service.dart';
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

  final Map<String, String> _gatewayNumbers = {
    'bkash': '017xx-xxxxxx',
    'nagad': '018xx-xxxxxx',
    'rocket': '019xx-xxxxxx',
  };

  Future<void> _submit() async {
    if (_trxController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Transaction ID'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      await _firestore.logTransaction(
        auth.user!.uid,
        widget.amount,
        'manual_deposit ($_gateway)',
        'pending', // Matches Admin query
        _trxController.text,
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request Submitted! Pending Admin Approval.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manual Funding', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildAmountHeader(),
            const SizedBox(height: 40),
            _buildInstructionCard(),
            const SizedBox(height: 40),
            _buildGatewaySelector(),
            const SizedBox(height: 30),
            _buildTrxInput(),
            const SizedBox(height: 50),
            _buildSubmitButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          const Text('PAYMENT AMOUNT', style: TextStyle(color: AppColors.textBody, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Text(
            '\$${widget.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.secondary, letterSpacing: -1),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.secondary, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              'Send Money To: ${_gatewayNumbers[_gateway]}\nUsing Cash Out or Send Money.',
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGatewaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CHOOSE GATEWAY', style: TextStyle(color: AppColors.textBody, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 15),
        Row(
          children: [
            _gatewayItem('bkash', 'Bkash'),
            const SizedBox(width: 15),
            _gatewayItem('nagad', 'Nagad'),
          ],
        ),
      ],
    );
  }

  Widget _gatewayItem(String id, String name) {
    final bool isSelected = _gateway == id;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _gateway = id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary.withOpacity(0.1) : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? AppColors.secondary : Colors.white.withOpacity(0.05)),
          ),
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.secondary : Colors.white38,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrxInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TRANSACTION ID (TRXID)', style: TextStyle(color: AppColors.textBody, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            controller: _trxController,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: 'Enter TrxID after success',
              hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
              prefixIcon: Icon(Icons.qr_code_scanner_rounded, color: AppColors.secondary, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
        ),
        child: _isSubmitting 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
          : const Text('SUBMIT TRANSACTION', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
