import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String bookingId;
  final String? userId;
  final String method; // 'qris', 'bank_transfer', 'gopay', 'credit_card'
  final String status; // 'pending', 'success', 'failed', 'expire'
  final double amount;
  final DateTime transactionTime;
  final String? snapToken;
  final String? redirectUrl;

  PaymentModel({
    required this.id,
    required this.bookingId,
    this.userId,
    required this.method,
    required this.status,
    required this.amount,
    required this.transactionTime,
    this.snapToken,
    this.redirectUrl,
  });

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PaymentModel(
      id: doc.id,
      bookingId: data['bookingId'] ?? '',
      userId: data['userId'],
      method: data['metode'] ?? data['method'] ?? 'unknown',
      status: data['status'] ?? 'pending',
      amount: (data['jumlah'] ?? data['amount'] ?? 0).toDouble(),
      transactionTime: data['waktu_transaksi'] != null
          ? (data['waktu_transaksi'] as Timestamp).toDate()
          : DateTime.now(),
      snapToken: data['snap_token'],
      redirectUrl: data['redirect_url'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bookingId': bookingId,
      if (userId != null) 'userId': userId,
      'metode': method,
      'status': status,
      'jumlah': amount,
      'waktu_transaksi': Timestamp.fromDate(transactionTime),
      if (snapToken != null) 'snap_token': snapToken,
      if (redirectUrl != null) 'redirect_url': redirectUrl,
    };
  }

  PaymentModel copyWith({
    String? id,
    String? bookingId,
    String? userId,
    String? method,
    String? status,
    double? amount,
    DateTime? transactionTime,
    String? snapToken,
    String? redirectUrl,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      method: method ?? this.method,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      transactionTime: transactionTime ?? this.transactionTime,
      snapToken: snapToken ?? this.snapToken,
      redirectUrl: redirectUrl ?? this.redirectUrl,
    );
  }
}
