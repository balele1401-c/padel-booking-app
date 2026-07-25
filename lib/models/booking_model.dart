import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String courtId;
  final String? courtName;
  final DateTime bookingDate;
  final String startTime; // format: "08:00"
  final String endTime; // format: "10:00"
  final int durationHours;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final double totalPrice;
  final String paymentStatus; // 'pending', 'paid', 'failed', 'refunded'
  final String? paymentId;
  final DateTime? createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.courtId,
    this.courtName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.status,
    required this.totalPrice,
    required this.paymentStatus,
    this.paymentId,
    this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime dateVal = DateTime.now();
    if (data['tanggal'] is Timestamp) {
      dateVal = (data['tanggal'] as Timestamp).toDate();
    } else if (data['tanggal'] is String) {
      dateVal = DateTime.parse(data['tanggal']);
    }

    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      courtId: data['courtId'] ?? '',
      courtName: data['courtName'] ?? data['nama_lapangan'],
      bookingDate: dateVal,
      startTime: data['jam_mulai'] ?? '00:00',
      endTime: data['jam_selesai'] ?? '00:00',
      durationHours: data['durasi_jam'] ?? 1,
      status: data['status'] ?? 'pending',
      totalPrice: (data['total_harga'] ?? 0).toDouble(),
      paymentStatus: data['payment_status'] ?? 'pending',
      paymentId: data['payment_id'],
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'courtId': courtId,
      if (courtName != null) 'courtName': courtName,
      'tanggal': Timestamp.fromDate(bookingDate),
      'jam_mulai': startTime,
      'jam_selesai': endTime,
      'durasi_jam': durationHours,
      'status': status,
      'total_harga': totalPrice,
      'payment_status': paymentStatus,
      if (paymentId != null) 'payment_id': paymentId,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? courtId,
    String? courtName,
    DateTime? bookingDate,
    String? startTime,
    String? endTime,
    int? durationHours,
    String? status,
    double? totalPrice,
    String? paymentStatus,
    String? paymentId,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courtId: courtId ?? this.courtId,
      courtName: courtName ?? this.courtName,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationHours: durationHours ?? this.durationHours,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentId: paymentId ?? this.paymentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
