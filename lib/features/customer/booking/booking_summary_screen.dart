import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/booking_model.dart';
import '../../../models/court_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../payment/payment_screen.dart';

class BookingSummaryScreen extends StatefulWidget {
  final CourtModel court;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final int durationHours;
  final double totalPrice;

  const BookingSummaryScreen({
    super.key,
    required this.court,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.totalPrice,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  bool _isSubmitting = false;

  Future<void> _handleConfirmation() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final user = authProvider.userModel;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi pengguna tidak valid. Silakan login kembali.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final newBooking = BookingModel(
      id: '',
      userId: user.id,
      courtId: widget.court.id,
      courtName: widget.court.name,
      bookingDate: widget.bookingDate,
      startTime: widget.startTime,
      endTime: widget.endTime,
      durationHours: widget.durationHours,
      status: 'pending',
      totalPrice: widget.totalPrice,
      paymentStatus: 'pending',
      createdAt: DateTime.now(),
    );

    // Call Firestore Transaction
    final bookingId = await bookingProvider.createBooking(newBooking);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (bookingId != null) {
      // Transaction Succeeded
      final confirmedBooking = newBooking.copyWith(id: bookingId);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(booking: confirmedBooking),
          ),
        );
      }
    } else {
      // Transaction Failed (Double Booking or Connection Issue)
      final errorMsg = bookingProvider.errorMessage ?? 'Gagal membuat booking.';

      if (mounted) {
        _showErrorDialog(context, errorMsg);
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: AppColors.error, size: 28),
              SizedBox(width: 10),
              Text(
                'Booking Gagal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to slot selection screen
              },
              child: const Text('Pilih Slot Lain', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCourtImage(String imageUrl) {
    if (imageUrl.trim().isEmpty) {
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.sports_tennis, color: AppColors.primary, size: 36),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 70,
            height: 70,
            color: AppColors.primary.withValues(alpha: 0.15),
            child: const Icon(Icons.sports_tennis, color: AppColors.primary, size: 36),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    final formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(widget.bookingDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ringkasan Booking'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Court Card Header
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          _buildCourtImage(widget.court.imageUrl),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.court.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.court.openTime} - ${widget.court.closeTime} WIB',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section Title: Detail Jadwal
                  const Text('Detail Jadwal Main', style: AppTextStyles.subheading),
                  const SizedBox(height: 12),

                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildRowItem(
                            icon: Icons.calendar_today_rounded,
                            label: 'Tanggal',
                            value: formattedDate,
                          ),
                          const Divider(height: 20),
                          _buildRowItem(
                            icon: Icons.access_time_rounded,
                            label: 'Jam Bermain',
                            value: '${widget.startTime} - ${widget.endTime} WIB',
                          ),
                          const Divider(height: 20),
                          _buildRowItem(
                            icon: Icons.timer_outlined,
                            label: 'Durasi',
                            value: '${widget.durationHours} Jam',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section Title: Detail Pemesan
                  const Text('Informasi Pemesan', style: AppTextStyles.subheading),
                  const SizedBox(height: 12),

                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildRowItem(
                            icon: Icons.person_outline,
                            label: 'Nama',
                            value: user?.name ?? '-',
                          ),
                          const Divider(height: 20),
                          _buildRowItem(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: user?.email ?? '-',
                          ),
                          if (user?.phoneNumber != null && user!.phoneNumber.isNotEmpty) ...[
                            const Divider(height: 20),
                            _buildRowItem(
                              icon: Icons.phone_outlined,
                              label: 'No. Telepon',
                              value: user.phoneNumber,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section Title: Rincian Pembayaran
                  const Text('Rincian Pembayaran', style: AppTextStyles.subheading),
                  const SizedBox(height: 12),

                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildPriceRow(
                            'Harga Sewa (${CurrencyFormatter.formatRupiah(widget.court.pricePerHour)} x ${widget.durationHours} Jam)',
                            CurrencyFormatter.formatRupiah(widget.totalPrice),
                          ),
                          const Divider(height: 24),
                          _buildPriceRow(
                            'Total Pembayaran',
                            CurrencyFormatter.formatRupiah(widget.totalPrice),
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Action Bar with Confirmation Button
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: CustomButton(
                text: 'Konfirmasi Booking',
                icon: Icons.check_circle_outline,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _handleConfirmation,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
