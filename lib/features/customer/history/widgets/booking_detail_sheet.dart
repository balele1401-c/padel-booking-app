import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../models/booking_model.dart';
import '../../../../services/booking_service.dart';
import '../../../../shared/widgets/custom_button.dart';

class BookingDetailSheet extends StatefulWidget {
  final BookingModel booking;
  final VoidCallback? onBookingUpdated;

  const BookingDetailSheet({
    super.key,
    required this.booking,
    this.onBookingUpdated,
  });

  @override
  State<BookingDetailSheet> createState() => _BookingDetailSheetState();
}

class _BookingDetailSheetState extends State<BookingDetailSheet> {
  bool _isCancelling = false;

  /// Parse start time string "HH:mm" into DateTime with bookingDate
  DateTime _getBookingStartDateTime() {
    final date = widget.booking.bookingDate;
    try {
      final parts = widget.booking.startTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (_) {
      return DateTime(date.year, date.month, date.day, 8, 0);
    }
  }

  /// Handle cancellation check (H-1 minimum requirement)
  void _handleCancelBooking(BuildContext context) {
    final bookingStart = _getBookingStartDateTime();
    final now = DateTime.now();
    final hoursDifference = bookingStart.difference(now).inHours;

    // Check if cancellation is less than 24 hours before match schedule
    if (hoursDifference < 24 || bookingStart.isBefore(now)) {
      _showRejectionDialog(context);
    } else {
      _showConfirmCancelDialog(context);
    }
  }

  void _showRejectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 26),
              SizedBox(width: 10),
              Text(
                'Pembatalan Ditolak',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Pembatalan hanya dapat dilakukan maksimal H-1 sebelum jadwal bermain.',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Mengerti', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Konfirmasi Pembatalan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Apakah Anda yakin ingin membatalkan pemesanan ini? Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _executeCancellation();
              },
              child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _executeCancellation() async {
    setState(() {
      _isCancelling = true;
    });

    try {
      final bookingService = BookingService();
      await bookingService.cancelBooking(widget.booking.id);

      if (!mounted) return;

      setState(() {
        _isCancelling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pemesanan berhasil dibatalkan.'),
          backgroundColor: AppColors.primary,
        ),
      );

      widget.onBookingUpdated?.call();
      Navigator.of(context).pop(); // Close detail sheet
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCancelling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membatalkan pemesanan: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(widget.booking.bookingDate);
    final canCancel = widget.booking.status == 'pending' || widget.booking.status == 'confirmed';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet Handle Drag Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title & Status Badge Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.booking.courtName ?? 'Lapangan Padel',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _buildStatusPill(widget.booking.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'ID Booking: ${widget.booking.id}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const Divider(height: 24),

            // Booking Information List
            _buildDetailRow(Icons.calendar_today_rounded, 'Tanggal Bermain', formattedDate),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.access_time_rounded, 'Waktu Main', '${widget.booking.startTime} - ${widget.booking.endTime} WIB'),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.timer_outlined, 'Durasi', '${widget.booking.durationHours} Jam'),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.payments_outlined,
              'Total Biaya',
              CurrencyFormatter.formatRupiah(widget.booking.totalPrice),
              isBold: true,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.credit_card_outlined,
              'Status Pembayaran',
              widget.booking.paymentStatus.toUpperCase(),
            ),
            const SizedBox(height: 24),

            // Cancellation Notice
            if (canCancel)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.pendingBg.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.pendingText.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.pendingText, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Catatan: Pembatalan hanya dapat dilakukan maksimal H-1 sebelum jadwal bermain.',
                        style: TextStyle(fontSize: 11, color: AppColors.pendingText, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),

            // Action Buttons
            Row(
              children: [
                if (canCancel) ...[
                  Expanded(
                    child: CustomButton(
                      text: 'Batalkan Booking',
                      type: ButtonType.secondary,
                      isLoading: _isCancelling,
                      onPressed: _isCancelling ? null : () => _handleCancelBooking(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: CustomButton(
                    text: 'Tutup',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isBold = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'pending':
        bgColor = AppColors.pendingBg;
        textColor = AppColors.pendingText;
        label = 'PENDING';
        break;
      case 'confirmed':
        bgColor = AppColors.confirmedBg;
        textColor = AppColors.confirmedText;
        label = 'CONFIRMED';
        break;
      case 'cancelled':
        bgColor = AppColors.cancelledBg;
        textColor = AppColors.cancelledText;
        label = 'CANCELLED';
        break;
      case 'completed':
        bgColor = AppColors.primary.withValues(alpha: 0.15);
        textColor = AppColors.primary;
        label = 'COMPLETED';
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
