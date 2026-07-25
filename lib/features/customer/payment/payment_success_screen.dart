import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/booking_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../customer_main_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final BookingModel booking;
  final String paymentMethod;
  final String paymentId;

  const PaymentSuccessScreen({
    super.key,
    required this.booking,
    required this.paymentMethod,
    required this.paymentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pembayaran Berhasil'),
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
                        'Pembayaran Berhasil!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Slot lapangan telah dikonfirmasi untuk Anda.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Payment Receipt Card
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Status Pemesanan',
                                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.confirmedBg,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'CONFIRMED',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.confirmedText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              _buildReceiptRow('ID Booking', booking.id),
                              const SizedBox(height: 10),
                              _buildReceiptRow('ID Transaksi', paymentId),
                              const SizedBox(height: 10),
                              _buildReceiptRow('Lapangan', booking.courtName ?? 'Lapangan Padel'),
                              const SizedBox(height: 10),
                              _buildReceiptRow('Waktu Main', '${booking.startTime} - ${booking.endTime} WIB'),
                              const SizedBox(height: 10),
                              _buildReceiptRow('Metode Pembayaran', paymentMethod),
                              const Divider(height: 24),
                              _buildReceiptRow(
                                'Total Dibayar',
                                CurrencyFormatter.formatRupiah(booking.totalPrice),
                                isBold: true,
                                valueColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.confirmedBg.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.confirmedText.withValues(alpha: 0.2)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_outlined, color: AppColors.confirmedText, size: 22),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tunjukkan bukti transaksi ini ke petugas saat tiba di lapangan padel.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.confirmedText,
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

              CustomButton(
                text: 'Kembali ke Beranda',
                icon: Icons.home,
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

  Widget _buildReceiptRow(String label, String value, {bool isBold = false, Color? valueColor}) {
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
