import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'binance_payment_screen.dart';
import 'manual_payment_screen.dart';

class PaymentPortalScreen extends StatefulWidget {
  final double amount;
  final String invoiceId;
  const PaymentPortalScreen({super.key, required this.amount, this.invoiceId = 'GP_INV_992182'});

  @override
  State<PaymentPortalScreen> createState() => _PaymentPortalScreenState();
}

class _PaymentPortalScreenState extends State<PaymentPortalScreen> {
  String? _selectedGateway;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF), // Very light cool background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.black54),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _buildBrandHeader(),
              const SizedBox(height: 30),
              _buildSupportIcons(),
              const SizedBox(height: 40),
              _buildSectionHeader('Mobile Banking'),
              const SizedBox(height: 20),
              _buildPaymentGrid(),
              const SizedBox(height: 40),
              _buildPayButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue.shade100, width: 2),
          ),
          child: const CircleAvatar(
            radius: 45,
            backgroundColor: Color(0xFF002244),
            child: Icon(Icons.shield_rounded, color: Colors.white, size: 40),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'GURU-PAY Gateway',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF002244)),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Invoice ID: ${widget.invoiceId}',
              style: const TextStyle(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.invoiceId));
                Get.snackbar('Copied', 'Invoice ID Copied!', snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 1));
              },
              child: const Icon(Icons.copy_rounded, size: 14, color: Colors.blue),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSupportIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _supportCircle(Icons.headset_mic_rounded, Colors.blue),
        const SizedBox(width: 20),
        _supportCircle(Icons.chat_bubble_outline_rounded, Colors.green),
        const SizedBox(width: 20),
        _supportCircle(Icons.phone_in_talk_rounded, Colors.blue),
      ],
    );
  }

  Widget _supportCircle(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: color.withOpacity(0.05)),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E6FF1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildPaymentGrid() {
    return Column(
      children: [
        Row(
          children: [
            _gatewayCard('bkash', 'bKash'),
            const SizedBox(width: 12),
            _gatewayCard('nagad', 'Nagad'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _gatewayCard('rocket', 'Rocket'),
            const SizedBox(width: 12),
            _gatewayCard('upay', 'Upay'),
          ],
        ),
        const SizedBox(height: 12),
        _gatewayCard('binance', 'Binance USDT (Automated)', isFullWidth: true),
      ],
    );
  }

  Widget _gatewayCard(String id, String name, {bool isFullWidth = false}) {
    final bool isSelected = _selectedGateway == id;
    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? const Color(0xFF2E6FF1) : Colors.black.withOpacity(0.05), width: 1.5),
        boxShadow: [
          if (isSelected) BoxShadow(color: const Color(0xFF2E6FF1).withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (id == 'binance') const Icon(Icons.currency_bitcoin_rounded, color: Colors.orange, size: 20),
          if (id == 'binance') const SizedBox(width: 8),
          Text(
            name, 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 14, 
              color: isSelected ? const Color(0xFF2E6FF1) : Colors.black87
            )
          ),
        ],
      ),
    );

    return isFullWidth 
      ? SizedBox(width: double.infinity, child: InkWell(onTap: () => setState(() => _selectedGateway = id), child: content))
      : Expanded(child: InkWell(onTap: () => setState(() => _selectedGateway = id), child: content));
  }

  Widget _buildPayButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF), // Light blue background exactly like the image
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _selectedGateway == null ? null : _handlePayment,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            'Pay ৳${(widget.amount * 115).toStringAsFixed(0)} BDT',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E6FF1)),
          ),
        ),
      ),
    );
  }

  void _handlePayment() {
    if (_selectedGateway == 'binance') {
      Get.to(() => BinancePaymentScreen(amount: widget.amount));
    } else {
      Get.to(() => ManualPaymentScreen(amount: widget.amount));
    }
  }
}
