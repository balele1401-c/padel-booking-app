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

  /// Helper to get previous 1-hour slot string (e.g. "08:00" -> "07:00")
  String? _getPreviousHour(String timeStr) {
    try {
      final hour = int.parse(timeStr.split(':')[0]);
      if (hour <= 0) return null;
      return '${(hour - 1).toString().padLeft(2, '0')}:00';
    } catch (_) {
      return null;
    }
  }

  /// Helper to get next 1-hour slot string (e.g. "08:00" -> "09:00")
  String? _getNextHour(String timeStr) {
    try {
      final hour = int.parse(timeStr.split(':')[0]);
      return '${(hour + 1).toString().padLeft(2, '0')}:00';
    } catch (_) {
      return null;
    }
  }

  /// Create booking with Firestore Transaction to prevent double-booking.
  /// Uses transaction.get() on slot document references to comply with Firestore Web SDK requirements.
  Future<String> createBookingWithTransaction(BookingModel booking) async {
    final formattedDate =
        "${booking.bookingDate.year}-${booking.bookingDate.month.toString().padLeft(2, '0')}-${booking.bookingDate.day.toString().padLeft(2, '0')}";
    final primaryDocId = "${booking.courtId}_${formattedDate}_${booking.startTime}";
    final primaryDocRef = _bookingsCollection.doc(primaryDocId);

    // List of slot document references to check inside transaction.get()
    final List<DocumentReference> docsToCheck = [primaryDocRef];

    // Check previous hour slot (in case an existing 2-hour booking started 1 hour earlier)
    final prevHour = _getPreviousHour(booking.startTime);
    if (prevHour != null) {
      docsToCheck.add(_bookingsCollection.doc("${booking.courtId}_${formattedDate}_$prevHour"));
    }

    // If requested booking is 2 hours, check the next hour slot as well
    if (booking.durationHours > 1) {
      final nextHour = _getNextHour(booking.startTime);
      if (nextHour != null) {
        docsToCheck.add(_bookingsCollection.doc("${booking.courtId}_${formattedDate}_$nextHour"));
      }
    }

    try {
      return await _firestore.runTransaction((transaction) async {
        // Reads inside transaction MUST use transaction.get(docRef)
        final List<DocumentSnapshot> snapshots = [];
        for (final docRef in docsToCheck) {
          final snap = await transaction.get(docRef);
          snapshots.add(snap);
        }

        // 1. Check primary slot document
        final primarySnap = snapshots[0];
        if (primarySnap.exists) {
          final data = primarySnap.data() as Map<String, dynamic>? ?? {};
          final status = data['status'];
          if (status == 'pending' || status == 'confirmed') {
            throw Exception('Slot sudah terambil orang lain');
          }
        }

        // 2. Check previous hour slot document (if duration was 2 hours)
        if (snapshots.length > 1 && snapshots[1].exists) {
          final data = snapshots[1].data() as Map<String, dynamic>? ?? {};
          final status = data['status'];
          final duration = (data['durasi_jam'] ?? 1) as num;
          if ((status == 'pending' || status == 'confirmed') && duration >= 2) {
            throw Exception('Slot sudah terambil orang lain');
          }
        }

        // 3. Check next hour slot document (if requesting 2 hours)
        if (booking.durationHours > 1 && snapshots.length > 2 && snapshots[2].exists) {
          final data = snapshots[2].data() as Map<String, dynamic>? ?? {};
          final status = data['status'];
          if (status == 'pending' || status == 'confirmed') {
            throw Exception('Slot sudah terambil orang lain');
          }
        }

        // Save booking document with deterministic slot ID
        final bookingData = booking.copyWith(id: primaryDocId).toFirestore();
        transaction.set(primaryDocRef, bookingData);

        return primaryDocId;
      });
    } on FirebaseException catch (e) {
      debugPrint('❌ [BookingService] FirebaseException: code=${e.code}, message=${e.message}');
      throw Exception(e.message ?? 'Gagal memproses transaksi Firestore (${e.code})');
    } catch (e) {
      debugPrint('❌ [BookingService] Exception: $e');
      rethrow;
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
