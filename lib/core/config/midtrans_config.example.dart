/// Template Konfigurasi Midtrans Payment Gateway
/// Salin file ini menjadi `midtrans_config.dart` dan masukkan Client Key & Server Key Midtrans Sandbox milik Anda.
class MidtransConfig {
  MidtransConfig._();

  /// Client Key Sandbox dari Midtrans Dashboard -> Access Keys
  static const String clientKey = 'YOUR_MIDTRANS_CLIENT_KEY';

  /// Server Key Sandbox dari Midtrans Dashboard -> Access Keys
  static const String serverKey = 'YOUR_MIDTRANS_SERVER_KEY';

  /// Merchant ID dari Midtrans Dashboard
  static const String merchantId = 'YOUR_MIDTRANS_MERCHANT_ID';

  /// Status Sandbox Mode (true untuk Sandbox, false untuk Production)
  static const bool isSandbox = true;

  /// Snap API Endpoint URL
  static String get snapApiUrl => isSandbox
      ? 'https://app.sandbox.midtrans.com/snap/v1/transactions'
      : 'https://app.midtrans.com/snap/v1/transactions';

  /// Snap JS SDK Script URL (Flutter Web / Snap Pop-up)
  static String get snapJsUrl => isSandbox
      ? 'https://app.sandbox.midtrans.com/snap/snap.js'
      : 'https://app.midtrans.com/snap/snap.js';

  /// Midtrans Payment Simulator URL (Sandbox)
  static const String simulatorUrl = 'https://simulator.sandbox.midtrans.com';
}
