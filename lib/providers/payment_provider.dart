import 'package:flutter/foundation.dart';
import '../services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService;

  bool _isProcessing = false;
  String? _errorMessage;

  PaymentProvider({PaymentService? paymentService})
      : _paymentService = paymentService ?? PaymentService();

  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Process successful payment: saves payment record and updates booking status to "confirmed"
  Future<bool> processPaymentSuccess({
    required String bookingId,
    required String userId,
    required String method,
    required double amount,
    String? snapToken,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _paymentService.processPaymentSuccess(
        bookingId: bookingId,
        userId: userId,
        method: method,
        amount: amount,
        snapToken: snapToken,
      );
      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e, stack) {
      debugPrint('❌ [PaymentProvider] Error in processPaymentSuccess: $e');
      debugPrint(stack.toString());
      _isProcessing = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Process failed/cancelled payment
  Future<bool> processPaymentFailure({
    required String bookingId,
    required String userId,
    required String method,
    required double amount,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _paymentService.processPaymentFailure(
        bookingId: bookingId,
        userId: userId,
        method: method,
        amount: amount,
        status: 'failed',
      );
      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isProcessing = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
