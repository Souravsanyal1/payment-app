import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../services/firestore_service.dart';

class ManualPaymentScreen extends StatefulWidget {
  final double amount;
  const ManualPaymentScreen({super.key, required this.amount});

  @override
  State<ManualPaymentScreen> createState() => _ManualPaymentScreenState();
}

class _ManualPaymentScreenState extends State<ManualPaymentScreen> {
  final _trxController = TextEditingController();
  final _firestore = FirestoreService();
  final AuthController _authController = Get.find();
  
  var _gateway = 'bkash'.obs;
  var _isSubmitting = false.obs;

  final Map<String, String> _gatewayNumbers = {
    'bkash': '017xx-xxxxxx',
    'nagad': '018xx-xxxxxx',
    'rocket': '019xx-xxxxxx',
  };

  void _submit() async {
    if (_trxController.text.length < 6) {
      Get.snackbar('Error', 'Please enter a valid Transaction ID', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
      return;
    }

    _isSubmitting.value = true;
    try {
      final userModel = await _firestore.getUser(_authController.firebaseUser!.uid);
      
      await _firestore.logTransaction(
        uid: _authController.firebaseUser!.uid,
        name: userModel.name,
        email: userModel.email,
        amount: widget.amount,
        type: 'manual_deposit (${_gateway.value})',
        status: 'pending',
        trxId: _trxController.text,
      );
      
      Get.back();
      Get.snackbar('Success', 'Request Submitted! Pending Admin Approval.', snackPosition: SnackPosition.TOP, backgroundColor: AppColors.success, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Error: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      _isSubmitting.value = false;
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
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildAmountHeader(),
            const SizedBox(height: 40),
            Obx(() => _buildInstructionCard()),
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
              'Send Money To: ${_gatewayNumbers[_gateway.value]}\nUsing Cash Out or Send Money.',
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
    return Expanded(
      child: Obx(() {
        final bool isSelected = _gateway.value == id;
        return InkWell(
          onTap: () => _gateway.value = id,
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
        );
      }),
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
      child: Obx(() => ElevatedButton(
        onPressed: _isSubmitting.value ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
        ),
        child: _isSubmitting.value 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
          : const Text('SUBMIT TRANSACTION', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
      )),
    );
  }
}
