class InvoiceModel {
  final String id;
  final String userId;
  final double amount;
  final String status;
  final String customerName;
  final String customerEmail;
  final DateTime dueDate;
  final DateTime createdAt;

  InvoiceModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.status,
    required this.customerName,
    required this.customerEmail,
    required this.dueDate,
    required this.createdAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json, String id) {
    return InvoiceModel(
      id: id,
      userId: json['user_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'unpaid',
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      dueDate: DateTime.fromMillisecondsSinceEpoch(json['due_date']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'amount': amount,
      'status': status,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'due_date': dueDate.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
}
