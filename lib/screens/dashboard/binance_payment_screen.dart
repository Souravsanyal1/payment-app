import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../services/firestore_service.dart';
import '../../services/api_service.dart';

class BinancePaymentScreen extends StatefulWidget {
  final double amount;
  const BinancePaymentScreen({super.key, required this.amount});

  @override
  State<BinancePaymentScreen> createState() => _BinancePaymentScreenState();
}

class _BinancePaymentScreenState extends State<BinancePaymentScreen> {
  late RxDouble _uniqueAmount;
  final _walletAddress = 'T9yD... (Your Binance Wallet)'; // TODO: Load from config
  final _firestore = FirestoreService();
  final _apiService = ApiService();
  final AuthController _authController = Get.find();
  var _isChecking = false.obs;
  String? _transactionId;

  @override
  void initState() {
    super.initState();
    _uniqueAmount = widget.amount.obs; 
    _initiatePayment();
  }

  void _initiatePayment() async {
    try {
      final userModel = await _firestore.getUser(_authController.firebaseUser!.uid);
      
      // Initialize with GURU-PAY Gateway
      final response = await _apiService.createPayment(widget.amount, userModel.apiKey);
      
      _transactionId = response['trx_id'];
      if (response.containsKey('amount')) {
        _uniqueAmount.value = (response['amount'] as num).toDouble();
      }

      await _firestore.logTransaction(
        uid: _authController.firebaseUser!.uid,
        name: userModel.name,
        email: userModel.email,
        amount: _uniqueAmount.value,
        type: 'deposit_binance',
        status: 'pending',
        trxId: _transactionId ?? 'BIN_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      Get.snackbar('Error', 'Error initiating payment: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Binance USDT (TRC20)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
          children: [
            const Icon(Icons.qr_code_2, size: 200, color: Colors.white),
            const SizedBox(height: 30),
            const Text('Please send EXACTLY the amount below:', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Obx(() => Text(
              '\$${_uniqueAmount.value.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.secondary),
            )),
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
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Obx(() => ElevatedButton(
                onPressed: _isChecking.value ? null : () async {
                  if (_transactionId == null) return;
                  _isChecking.value = true;
                  try {
                    final statusRes = await _apiService.checkStatus(_transactionId!);
                    if (statusRes['status'] == 'success') {
                      Get.snackbar('Success', 'Payment Verified! Account Updated.', snackPosition: SnackPosition.TOP, backgroundColor: AppColors.success, colorText: Colors.white);
                      Get.back();
                    } else {
                      Get.snackbar('Processing', 'Payment not detected yet. Please wait...', snackPosition: SnackPosition.BOTTOM);
                    }
                  } catch (e) {
                    Get.snackbar('Error', 'Verification Failed: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error, colorText: Colors.white);
                  } finally {
                    _isChecking.value = false;
                  }
                },
                child: _isChecking.value 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text('CHECK STATUS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value, {bool copyable = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textBody)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          if (copyable) const Icon(Icons.copy, size: 18, color: AppColors.secondary),
        ],
      ),
    );
  }
}
