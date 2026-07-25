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

  /// Stream of active bookings for a specific court and date
  Stream<List<BookingModel>> getBookingsForCourtAndDateStream(String courtId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _bookingsCollection
        .where('courtId', isEqualTo: courtId)
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .where((booking) => booking.status == 'pending' || booking.status == 'confirmed')
          .toList();
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
        .where('status', whereIn: ['pending', 'confirmed'])
        .get();

    for (final doc in query.docs) {
      final existing = BookingModel.fromFirestore(doc);
      // Overlap check: existing [startTime, endTime) vs requested [startTime, startTime+1h)
      if (existing.startTime == startTime) {
        return false;
      }
    }

    return true;
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
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      final reqStart = booking.startTime;
      final reqEnd = booking.endTime;

      for (final doc in existingBookingsQuery.docs) {
        final existing = BookingModel.fromFirestore(doc);
        final existStart = existing.startTime;
        final existEnd = existing.endTime;

        // Overlap check between [reqStart, reqEnd) and [existStart, existEnd)
        // Two intervals overlap if reqStart < existEnd AND reqEnd > existStart
        if (reqStart.compareTo(existEnd) < 0 && reqEnd.compareTo(existStart) > 0) {
          throw Exception('Slot sudah terambil orang lain');
        }
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
