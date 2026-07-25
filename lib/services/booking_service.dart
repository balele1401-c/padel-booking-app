import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore;

  BookingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _bookingsCollection => _firestore.collection('bookings');

  /// Stream of user's bookings (Customer)
  Stream<List<BookingModel>> getUserBookingsStream(String userId) {
    return _bookingsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
    });
  }

  /// Stream of all bookings (Admin)
  Stream<List<BookingModel>> getAllBookingsStream() {
    return _bookingsCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
    });
  }

  /// Check if slot is available for a given court, date, and start time
  Future<bool> isSlotAvailable({
    required String courtId,
    required DateTime date,
    required String startTime,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final query = await _bookingsCollection
        .where('courtId', isEqualTo: courtId)
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .where('jam_mulai', isEqualTo: startTime)
        .where('status', whereIn: ['pending', 'confirmed'])
        .get();

    return query.docs.isEmpty;
  }

  /// Create booking with Firestore Transaction to prevent double-booking
  Future<String> createBookingWithTransaction(BookingModel booking) async {
    return await _firestore.runTransaction((transaction) async {
      final startOfDay = DateTime(
        booking.bookingDate.year,
        booking.bookingDate.month,
        booking.bookingDate.day,
      );
      final endOfDay = DateTime(
        booking.bookingDate.year,
        booking.bookingDate.month,
        booking.bookingDate.day,
        23,
        59,
        59,
      );

      final existingBookingsQuery = await _bookingsCollection
          .where('courtId', isEqualTo: booking.courtId)
          .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('jam_mulai', isEqualTo: booking.startTime)
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      if (existingBookingsQuery.docs.isNotEmpty) {
        throw Exception('Slot jam ${booking.startTime} sudah dibooking orang lain!');
      }

      final newDocRef = _bookingsCollection.doc();
      transaction.set(newDocRef, booking.copyWith(id: newDocRef.id).toFirestore());

      return newDocRef.id;
    });
  }

  /// Update booking status ('confirmed', 'cancelled', 'completed')
  Future<void> updateBookingStatus(String bookingId, String status, {String? paymentStatus}) async {
    final Map<String, dynamic> data = {'status': status};
    if (paymentStatus != null) {
      data['payment_status'] = paymentStatus;
    }
    await _bookingsCollection.doc(bookingId).update(data);
  }

  /// Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, 'cancelled');
  }
}
