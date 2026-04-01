import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'dart:math';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Users
  Future<void> createUser(String uid, String name, String email) async {
    final apiKey = _generateApiKey();
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'balance': 0.0,
      'api_key': apiKey,
      'role': 'user', // Default role
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<UserModel> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception('User not found');
    return UserModel.fromJson(doc.data()!, doc.id);
  }

  Stream<UserModel> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) throw Exception('User not found');
      return UserModel.fromJson(doc.data()!, doc.id);
    });
  }

  Future<void> updateBalance(String uid, double amount) async {
    await _db.collection('users').doc(uid).update({
      'balance': FieldValue.increment(amount),
    });
  }

  String _generateApiKey() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rnd = Random();
    return 'sk_live_${List.generate(32, (index) => chars[rnd.nextInt(chars.length)]).join()}';
  }

  // Transactions
  Future<void> logTransaction(String uid, double amount, String type, String status, String trxId) async {
    await _db.collection('transactions').add({
      'user_id': uid,
      'amount': amount,
      'type': type,
      'status': status,
      'trx_id': trxId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Stream<List<Map<String, dynamic>>> userTransactionsStream(String uid) {
    return _db.collection('transactions')
        .where('user_id', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  Stream<List<Map<String, dynamic>>> pendingTransactionsStream() {
    return _db.collection('transactions')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  Future<void> approveTransaction(String transactionId, String userId, double amount) async {
    final batch = _db.batch();
    
    // Update transaction status
    batch.update(_db.collection('transactions').doc(transactionId), {
      'status': 'success',
      'approved_at': DateTime.now().millisecondsSinceEpoch,
    });

    // Update user balance
    batch.update(_db.collection('users').doc(userId), {
      'balance': FieldValue.increment(amount),
    });

    await batch.commit();
  }
}

