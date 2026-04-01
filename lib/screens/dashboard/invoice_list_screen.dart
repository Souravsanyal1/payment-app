import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/invoice_model.dart';

class InvoiceListScreen extends StatelessWidget {
  const InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Invoices')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _invoiceTile(InvoiceModel(
              id: 'INV001',
              userId: 'user1',
              amount: 49.99,
              status: 'unpaid',
              customerName: 'Kamal Hasan',
              customerEmail: 'kamal@gmail.com',
              dueDate: DateTime.now().add(const Duration(days: 3)),
              createdAt: DateTime.now(),
            )),
            const SizedBox(height: 12),
            _invoiceTile(InvoiceModel(
              id: 'INV002',
              userId: 'user1',
              amount: 199.00,
              status: 'paid',
              customerName: 'Jasmine Akter',
              customerEmail: 'jasmine@gmail.com',
              dueDate: DateTime.now().subtract(const Duration(days: 1)),
              createdAt: DateTime.now().subtract(const Duration(days: 2)),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _invoiceTile(InvoiceModel invoice) {
    final isPaid = invoice.status == 'paid';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isPaid ? AppColors.success : Colors.orange).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPaid ? Icons.check_circle_outline : Icons.pending_outlined,
              color: isPaid ? AppColors.success : Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(invoice.id, style: const TextStyle(fontSize: 12, color: AppColors.textBody)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${invoice.amount}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                isPaid ? 'PAID' : 'DUE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isPaid ? AppColors.success : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
