import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/booking_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../customer_main_screen.dart';

class PaymentFailedScreen extends StatelessWidget {
  final BookingModel booking;
  final String reason;

  const PaymentFailedScreen({
    super.key,
    required this.booking,
    this.reason = 'Pembayaran dibatalkan atau waktu transaksi telah habis.',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pembayaran Gagal'),
        centerTitle: true,
        automaticallyImplyLeading: false,
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
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: AppColors.cancelledBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cancel_rounded,
                          size: 72,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Pembayaran Tidak Berhasil',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          reason,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Card Details
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRow('ID Booking', booking.id),
                              const SizedBox(height: 10),
                              _buildRow('Lapangan', booking.courtName ?? 'Lapangan Padel'),
                              const SizedBox(height: 10),
                              _buildRow('Waktu Main', '${booking.startTime} - ${booking.endTime} WIB'),
                              const SizedBox(height: 10),
                              _buildRow('Status', 'Gagal / Dibatalkan', isBold: true, valueColor: AppColors.error),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              CustomButton(
                text: 'Kembali ke Beranda',
                type: ButtonType.secondary,
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const CustomerMainScreen()),
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

  Widget _buildRow(String label, String value, {bool isBold = false, Color? valueColor}) {
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
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
