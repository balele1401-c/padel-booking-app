import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/booking_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../home/customer_home_screen.dart';

class PaymentScreen extends StatelessWidget {
  final BookingModel booking;

  const PaymentScreen({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pembayaran Booking'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Prevent going back after booking confirmed
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Success Badge Animated Container
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.confirmedBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          size: 72,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Booking Berhasil Dibuat!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ID Pemesanan: ${booking.id}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Status Card
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Status Pemesanan',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.pendingBg,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'PENDING PAYMENT',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.pendingText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),

                              _buildDetailRow('Lapangan', booking.courtName ?? 'Lapangan Padel'),
                              const SizedBox(height: 10),
                              _buildDetailRow('Waktu Main', '${booking.startTime} - ${booking.endTime} WIB'),
                              const SizedBox(height: 10),
                              _buildDetailRow('Durasi', '${booking.durationHours} Jam'),
                              const SizedBox(height: 10),
                              _buildDetailRow(
                                'Total Biaya',
                                CurrencyFormatter.formatRupiah(booking.totalPrice),
                                isBold: true,
                                valueColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Information Note
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Slot jadwal Anda telah diamankan. Silakan selesaikan proses pembayaran di kasir / via transfer saat bermain.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryDark,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Button to return home
              CustomButton(
                text: 'Kembali ke Beranda',
                icon: Icons.home,
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const CustomerHomeScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
