import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'dart:math';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Users
  Future<void> createUser(String uid, String name, String email, {String? referrerId}) async {
    final apiKey = _generateApiKey();
    final bool isAdmin = email.trim().toLowerCase() == 'sourav.sanyal.dev@gmail.com';
    
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'balance': 0.0,
      'daily_earnings': 0.0,
      'referral_earnings': 0.0,
      'api_key': apiKey,
      'role': isAdmin ? 'admin' : 'user',
      'referred_by': referrerId,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> checkOrCreateUser(String uid, String name, String email) async {
    final doc = await _db.collection('users').doc(uid).get();
    final bool isMasterAdmin = email.trim().toLowerCase() == 'sourav.sanyal.dev@gmail.com';

    if (!doc.exists) {
      await createUser(uid, name, email);
    } else if (isMasterAdmin && doc.data()?['role'] != 'admin') {
      await _db.collection('users').doc(uid).update({'role': 'admin'});
    }
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

  // Admin Settings
  Future<double> getReferralBonusPercent() async {
    final doc = await _db.collection('settings').doc('referral').get();
    if (!doc.exists) return 5.0; // Default 5%
    return (doc.data()?['percent'] ?? 5.0).toDouble();
  }

  Future<void> updateReferralBonusPercent(double percent) async {
    await _db.collection('settings').doc('referral').set({
      'percent': percent,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Admin Stats Futures (Optimization: Avoid listeners on huge collections)
  Future<int> getTotalUsersCount() async {
    final s = await _db.collection('users').get();
    return s.docs.length;
  }

  Future<double> getTotalTransactionVolume() async {
    final s = await _db.collection('transactions')
      .where('status', isEqualTo: 'success')
      .get();
    double total = 0.0;
    for (var doc in s.docs) {
      total += (doc.data()['amount'] ?? 0.0).toDouble();
    }
    return total;
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
  Future<void> logTransaction({
    required String uid, 
    required String name, 
    required String email, 
    required double amount, 
    required String type, 
    required String status, 
    required String trxId
  }) async {
    await _db.collection('transactions').add({
      'user_id': uid,
      'user_name': name,
      'user_email': email,
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
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  Future<void> approveTransaction(String transactionId, String userId, double amount) async {
    final batch = _db.batch();
    
    // 1. Mark transaction as success
    batch.update(_db.collection('transactions').doc(transactionId), {
      'status': 'success',
      'approved_at': DateTime.now().millisecondsSinceEpoch,
    });

    // 2. Update user balance
    batch.update(_db.collection('users').doc(userId), {
      'balance': FieldValue.increment(amount),
      'daily_earnings': FieldValue.increment(amount),
    });

    // 3. Handle Referral Commission
    final userDoc = await _db.collection('users').doc(userId).get();
    final String? referrerId = userDoc.data()?['referred_by'];
    
    if (referrerId != null && referrerId.isNotEmpty) {
      final bonusPercent = await getReferralBonusPercent();
      final double commission = amount * (bonusPercent / 100);
      
      if (commission > 0) {
        batch.update(_db.collection('users').doc(referrerId), {
          'balance': FieldValue.increment(commission),
          'referral_earnings': FieldValue.increment(commission),
        });

        // Log the commission transaction
        final commRef = _db.collection('transactions').doc();
        batch.set(commRef, {
          'user_id': referrerId,
          'user_name': 'Referral Bonus',
          'user_email': 'From: ${userDoc.data()?['name']}',
          'amount': commission,
          'type': 'referral_bonus',
          'status': 'success',
          'trx_id': 'REF-${transactionId.substring(0, 8).toUpperCase()}',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    }

    await batch.commit();
  }

  Future<void> rejectTransaction(String transactionId) async {
    await _db.collection('transactions').doc(transactionId).update({
      'status': 'rejected',
      'rejected_at': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
