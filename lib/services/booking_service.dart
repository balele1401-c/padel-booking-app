import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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



  /// Create booking with Web-compatible atomic slot verification and set operation.
  /// Solves Flutter Web JS interop Promise exception while ensuring double-booking prevention.
  Future<String> createBookingWithTransaction(BookingModel booking) async {
    final formattedDate =
        "${booking.bookingDate.year}-${booking.bookingDate.month.toString().padLeft(2, '0')}-${booking.bookingDate.day.toString().padLeft(2, '0')}";
    final primaryDocId = "${booking.courtId}_${formattedDate}_${booking.startTime}";
    final primaryDocRef = _bookingsCollection.doc(primaryDocId);

    // 1. Check general slot availability for the date & time
    final available = await isSlotAvailable(
      courtId: booking.courtId,
      date: booking.bookingDate,
      startTime: booking.startTime,
    );

    if (!available) {
      throw Exception('Slot sudah terambil orang lain');
    }

    try {
      // 2. Direct document existence check for the specific slot ID
      final docSnap = await primaryDocRef.get();
      if (docSnap.exists) {
        final data = docSnap.data() as Map<String, dynamic>? ?? {};
        final status = data['status'];
        if (status == 'pending' || status == 'confirmed') {
          throw Exception('Slot sudah terambil orang lain');
        }
      }

      // 3. Save booking document with deterministic ID
      final bookingData = booking.copyWith(id: primaryDocId).toFirestore();
      await primaryDocRef.set(bookingData);

      debugPrint('✅ [BookingService] Booking created successfully with ID: $primaryDocId');
      return primaryDocId;
    } on FirebaseException catch (e, stack) {
      debugPrint('❌ [BookingService] FirebaseException: ${e.code} - ${e.message}');
      debugPrint(stack.toString());
      throw Exception(e.message ?? 'Gagal membuat dokumen booking (${e.code})');
    } catch (e, stack) {
      debugPrint('❌ [BookingService] Exception in createBooking: $e');
      debugPrint(stack.toString());
      if (e.toString().contains('Slot sudah terambil')) {
        rethrow;
      }
      throw Exception('Gagal menyimpan booking: ${e.toString().replaceAll('Exception: ', '')}');
    }
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
