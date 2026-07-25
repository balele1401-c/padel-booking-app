import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';

class PaymentService {
  final FirebaseFirestore _firestore;

  PaymentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _paymentsCollection => _firestore.collection('payments');

  /// Create payment record
  Future<String> createPayment(PaymentModel payment) async {
    final docRef = await _paymentsCollection.add(payment.toFirestore());
    return docRef.id;
  }

  /// Get payment by Booking ID
  Future<PaymentModel?> getPaymentByBookingId(String bookingId) async {
    final query = await _paymentsCollection
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return PaymentModel.fromFirestore(query.docs.first);
  }

  /// Real-time stream of all payments (Admin)
  Stream<List<PaymentModel>> getAllPaymentsStream() {
    return _paymentsCollection
        .orderBy('waktu_transaksi', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => PaymentModel.fromFirestore(doc)).toList();
    });
  }

  /// Update payment status
  Future<void> updatePaymentStatus(String paymentId, String status) async {
    await _paymentsCollection.doc(paymentId).update({
      'status': status,
    });
  }

  /// Process successful payment:
  /// 1. Save payment record to collection "payments" with status "success"
  /// 2. Update booking in collection "bookings" with status "confirmed" & payment_status "paid"
  Future<String> processPaymentSuccess({
    required String bookingId,
    required String userId,
    required String method,
    required double amount,
    String? snapToken,
  }) async {
    final paymentDocRef = _paymentsCollection.doc();
    final paymentModel = PaymentModel(
      id: paymentDocRef.id,
      bookingId: bookingId,
      userId: userId,
      method: method,
      status: 'success',
      amount: amount,
      transactionTime: DateTime.now(),
      snapToken: snapToken,
    );

    final batch = _firestore.batch();
    
    // Save to payments collection
    batch.set(paymentDocRef, paymentModel.toFirestore());

    // Update bookings collection
    final bookingDocRef = _firestore.collection('bookings').doc(bookingId);
    batch.update(bookingDocRef, {
      'status': 'confirmed',
      'payment_status': 'paid',
      'payment_id': paymentDocRef.id,
    });

    await batch.commit();
    return paymentDocRef.id;
  }

  /// Process failed/cancelled payment
  Future<void> processPaymentFailure({
    required String bookingId,
    required String userId,
    required String method,
    required double amount,
    String status = 'failed',
  }) async {
    final paymentDocRef = _paymentsCollection.doc();
    final paymentModel = PaymentModel(
      id: paymentDocRef.id,
      bookingId: bookingId,
      userId: userId,
      method: method,
      status: status,
      amount: amount,
      transactionTime: DateTime.now(),
    );

    final batch = _firestore.batch();

    batch.set(paymentDocRef, paymentModel.toFirestore());

    final bookingDocRef = _firestore.collection('bookings').doc(bookingId);
    batch.update(bookingDocRef, {
      'payment_status': status,
    });

    await batch.commit();
  }
}
