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
}
