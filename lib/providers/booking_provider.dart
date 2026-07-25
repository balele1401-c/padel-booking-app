import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService;

  bool _isLoading = false;
  String? _errorMessage;

  BookingProvider({BookingService? bookingService})
      : _bookingService = bookingService ?? BookingService();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get real-time stream of active bookings for court and date
  Stream<List<BookingModel>> getBookingsForCourtAndDateStream(String courtId, DateTime date) {
    return _bookingService.getBookingsForCourtAndDateStream(courtId, date);
  }

  /// Create booking using Firestore Transaction to prevent double-booking
  Future<String?> createBooking(BookingModel booking) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final bookingId = await _bookingService.createBookingWithTransaction(booking);
      _isLoading = false;
      notifyListeners();
      return bookingId;
    } catch (e, stackTrace) {
      debugPrint('❌ [BookingProvider] Exception in createBooking: $e');
      debugPrint('❌ [BookingProvider] StackTrace: $stackTrace');

      _isLoading = false;
      _errorMessage = _parseErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  String _parseErrorMessage(dynamic e) {
    final str = e.toString();
    if (str.contains('Slot sudah terambil')) {
      return 'Slot sudah terambil orang lain';
    }
    if (str.contains('permission-denied') || str.contains('PERMISSION_DENIED')) {
      return 'Izin ditolak oleh Firestore Security Rules.';
    }
    if (str.contains('Exception: ')) {
      return str.replaceAll('Exception: ', '');
    }
    return str;
  }
}
