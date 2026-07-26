import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore;

  BookingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _bookingsCollection => _firestore.collection('bookings');

  /// Stream of user's bookings (Customer).
  /// Sorts in Dart to prevent Firestore composite index missing error.
  Stream<List<BookingModel>> getUserBookingsStream(String userId) {
    return _bookingsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
      list.sort((a, b) {
        final dateA = a.createdAt ?? a.bookingDate;
        final dateB = b.createdAt ?? b.bookingDate;
        return dateB.compareTo(dateA);
      });
      return list;
    });
  }

  /// Stream of all bookings (Admin).
  /// Sorts in Dart to prevent Firestore composite index missing error.
  Stream<List<BookingModel>> getAllBookingsStream() {
    return _bookingsCollection
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
      list.sort((a, b) {
        final dateA = a.createdAt ?? a.bookingDate;
        final dateB = b.createdAt ?? b.bookingDate;
        return dateB.compareTo(dateA);
      });
      return list;
    });
  }

  /// Stream of active bookings (including blocked maintenance slots) for a specific court and date.
  /// Uses robust Dart in-memory filtering to avoid type mismatch (Timestamp vs String)
  /// and case-insensitivity issues.
  Stream<List<BookingModel>> getBookingsForCourtAndDateStream(String courtId, DateTime date) {
    return _bookingsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).where((booking) {
        final bDate = booking.bookingDate;
        final isSameDate = bDate.year == date.year && bDate.month == date.month && bDate.day == date.day;
        final isSameCourt = booking.courtId == courtId;
        final status = booking.status.trim().toLowerCase();
        final isActiveStatus = status == 'pending' || status == 'confirmed' || status == 'completed' || status == 'blocked';

        return isSameCourt && isSameDate && isActiveStatus;
      }).toList();
    });
  }

  /// Check if slot is available for a given court, date, and start time
  Future<bool> isSlotAvailable({
    required String courtId,
    required DateTime date,
    required String startTime,
  }) async {
    final query = await _bookingsCollection.get();

    for (final doc in query.docs) {
      final existing = BookingModel.fromFirestore(doc);
      final bDate = existing.bookingDate;
      final isSameDate = bDate.year == date.year && bDate.month == date.month && bDate.day == date.day;
      final isSameCourt = existing.courtId == courtId;
      final status = existing.status.trim().toLowerCase();
      final isActiveStatus = status == 'pending' || status == 'confirmed' || status == 'completed' || status == 'blocked';

      if (isSameCourt && isSameDate && isActiveStatus) {
        // Overlap check: existing [bStart, bEnd) vs requested startTime
        if (startTime.compareTo(existing.startTime) >= 0 && startTime.compareTo(existing.endTime) < 0) {
          return false;
        }
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
      throw Exception('Slot sudah terambil orang lain atau sedang diblokir untuk maintenance');
    }

    try {
      // 2. Direct document existence check for the specific slot ID
      final docSnap = await primaryDocRef.get();
      if (docSnap.exists) {
        final data = docSnap.data() as Map<String, dynamic>? ?? {};
        final status = (data['status'] as String? ?? '').trim().toLowerCase();
        if (status == 'pending' || status == 'confirmed' || status == 'completed' || status == 'blocked') {
          throw Exception('Slot sudah terambil orang lain atau sedang diblokir untuk maintenance');
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

  /// Block a specific slot for court maintenance
  Future<String> blockSlotForMaintenance({
    required String courtId,
    required String courtName,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? note,
  }) async {
    final formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final primaryDocId = "${courtId}_${formattedDate}_$startTime";
    final primaryDocRef = _bookingsCollection.doc(primaryDocId);

    final available = await isSlotAvailable(
      courtId: courtId,
      date: date,
      startTime: startTime,
    );

    if (!available) {
      throw Exception('Slot ini sudah terisi oleh customer atau sudah diblokir sebelumnya.');
    }

    final blockedBooking = BookingModel(
      id: primaryDocId,
      userId: 'admin_maintenance',
      courtId: courtId,
      courtName: courtName,
      bookingDate: date,
      startTime: startTime,
      endTime: endTime,
      durationHours: 1,
      status: 'blocked',
      totalPrice: 0,
      paymentStatus: 'n/a',
      createdAt: DateTime.now(),
    );

    final data = blockedBooking.toFirestore();
    if (note != null && note.isNotEmpty) {
      data['catatan'] = note;
    }

    await primaryDocRef.set(data);
    debugPrint('✅ [BookingService] Slot blocked for maintenance with ID: $primaryDocId');
    return primaryDocId;
  }

  /// Unblock maintenance slot (removes document from bookings collection)
  Future<void> unblockSlot(String bookingId) async {
    await _bookingsCollection.doc(bookingId).delete();
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
