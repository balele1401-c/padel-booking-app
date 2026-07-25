import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/booking_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/booking_service.dart';
import 'widgets/booking_detail_sheet.dart';

class CustomerHistoryScreen extends StatelessWidget {
  const CustomerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Silakan login kembali.')),
      );
    }

    final bookingService = BookingService();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Riwayat Booking'),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: StreamBuilder<List<BookingModel>>(
          stream: bookingService.getUserBookingsStream(user.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Gagal memuat riwayat booking:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final allBookings = snapshot.data ?? [];
            final now = DateTime.now();
            final startOfToday = DateTime(now.year, now.month, now.day);

            // Filter Upcoming: pending/confirmed & date >= startOfToday
            final upcomingBookings = allBookings.where((b) {
              final bDate = DateTime(b.bookingDate.year, b.bookingDate.month, b.bookingDate.day);
              return (b.status == 'pending' || b.status == 'confirmed') &&
                  (bDate.isAfter(startOfToday) || bDate.isAtSameMomentAs(startOfToday));
            }).toList();

            // Filter History: completed/cancelled OR date < startOfToday
            final pastBookings = allBookings.where((b) {
              final bDate = DateTime(b.bookingDate.year, b.bookingDate.month, b.bookingDate.day);
              return b.status == 'completed' ||
                  b.status == 'cancelled' ||
                  bDate.isBefore(startOfToday);
            }).toList();

            return TabBarView(
              children: [
                _buildBookingList(context, upcomingBookings, isUpcoming: true),
                _buildBookingList(context, pastBookings, isUpcoming: false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, List<BookingModel> bookings, {required bool isUpcoming}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.event_available : Icons.history,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              isUpcoming ? 'Belum Ada Pemesanan Mendatang' : 'Belum Ada Riwayat Pemesanan',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isUpcoming
                  ? 'Pemesanan aktif Anda akan muncul di sini.'
                  : 'Riwayat permainan sebelumnya akan dicatat di sini.',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final formattedDate = DateFormat('EEE, dd MMM yyyy', 'id_ID').format(booking.bookingDate);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.border),
          ),
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => BookingDetailSheet(booking: booking),
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Court Name & Pill Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          booking.courtName ?? 'Lapangan Padel',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _buildStatusPill(booking.status),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // Middle Row: Date, Time & Total Price
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        '${booking.startTime} WIB',
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${booking.durationHours} Jam Permainan',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      Text(
                        CurrencyFormatter.formatRupiah(booking.totalPrice),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
