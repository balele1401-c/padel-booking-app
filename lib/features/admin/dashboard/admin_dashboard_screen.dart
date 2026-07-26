import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/booking_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/booking_service.dart';
import '../../customer/customer_main_screen.dart';
import '../bookings/admin_booking_list_screen.dart';
import '../courts/admin_court_list_screen.dart';
import '../payments/admin_payment_list_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    // Role protection (Admin only)
    if (!authProvider.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const CustomerMainScreen()),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final bookingService = BookingService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout Admin',
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: bookingService.getAllBookingsStream(),
        builder: (context, snapshot) {
          final allBookings = snapshot.data ?? [];

          // Date helper calculations
          final now = DateTime.now();
          final todayStart = DateTime(now.year, now.month, now.day);
          final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

          // Find start of current week (Monday)
          final monday = todayStart.subtract(Duration(days: now.weekday - 1));
          final sunday = monday.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

          // Calculate summary metrics
          final todayCount = allBookings.where((b) {
            final bd = b.bookingDate;
            return bd.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
                bd.isBefore(todayEnd.add(const Duration(seconds: 1)));
          }).length;

          final weekCount = allBookings.where((b) {
            final bd = b.bookingDate;
            return bd.isAfter(monday.subtract(const Duration(seconds: 1))) &&
                bd.isBefore(sunday.add(const Duration(seconds: 1)));
          }).length;

          final monthCount = allBookings.where((b) {
            final bd = b.bookingDate;
            return bd.year == now.year && bd.month == now.month;
          }).length;

          final totalRevenue = allBookings
              .where((b) {
                final st = b.status.trim().toLowerCase();
                return st == 'confirmed' || st == 'completed';
              })
              .fold<double>(0, (sum, b) => sum + b.totalPrice);

          // Calculate occupancy count for each day of current week (Mon-Sun)
          final dailyOccupancy = List<int>.generate(7, (index) {
            final dayDate = monday.add(Duration(days: index));
            return allBookings.where((b) {
              final bd = b.bookingDate;
              return bd.year == dayDate.year && bd.month == dayDate.month && bd.day == dayDate.day;
            }).length;
          });

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Admin Welcome Header Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.admin_panel_settings_rounded, size: 34, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    user?.name ?? 'Super Admin',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.pendingBg,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'ADMIN',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.pendingText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? 'superadmin@gmail.com',
                                style: const TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section 1: Summary Metrics (2-Column Grid)
                  const Text(
                    'Ringkasan Performa System',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.5,
                    children: [
                      _buildMetricCard(
                        title: 'Booking Hari Ini',
                        value: '$todayCount',
                        subtitle: 'Transaksi hari ini',
                        icon: Icons.today_rounded,
                        color: AppColors.primary,
                      ),
                      _buildMetricCard(
                        title: 'Booking Minggu Ini',
                        value: '$weekCount',
                        subtitle: 'Minggu berjalan',
                        icon: Icons.calendar_view_week_rounded,
                        color: Colors.indigo,
                      ),
                      _buildMetricCard(
                        title: 'Booking Bulan Ini',
                        value: '$monthCount',
                        subtitle: 'Bulan berjalan',
                        icon: Icons.calendar_month_rounded,
                        color: Colors.teal,
                      ),
                      _buildMetricCard(
                        title: 'Total Pendapatan',
                        value: CurrencyFormatter.formatRupiah(totalRevenue),
                        subtitle: 'Status Lunas/Paid',
                        icon: Icons.account_balance_wallet_rounded,
                        color: Colors.amber.shade800,
                        isCompactText: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Section 2: Occupancy Bar Chart (fl_chart)
                  const Text(
                    'Grafik Okupansi Lapangan Minggu Ini',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Jumlah Pemesanan per Hari',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                            ),
                            Row(
                              children: [
                                CircleAvatar(radius: 4, backgroundColor: AppColors.primary),
                                SizedBox(width: 6),
                                Text('Booking Active', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 180,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: (dailyOccupancy.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                                    return BarTooltipItem(
                                      '${days[group.x]}: ${rod.toY.round()} booking',
                                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (double value, TitleMeta meta) {
                                      const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                                      final index = value.toInt();
                                      if (index >= 0 && index < days.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            days[index],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: dailyOccupancy.asMap().entries.map((entry) {
                                final index = entry.key;
                                final count = entry.value;
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: count.toDouble(),
                                      gradient: const LinearGradient(
                                        colors: [AppColors.primaryDark, AppColors.primary],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                      width: 18,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Section 3: Admin Management Modules Navigation
                  const Text(
                    'Menu Kelola Sistem',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Module 1: Kelola Lapangan
                  _buildAdminModuleCard(
                    context,
                    title: 'Kelola Lapangan Padel',
                    subtitle: 'Tambah, edit data, atur jam operasional, dan hapus lapangan.',
                    icon: Icons.sports_tennis_rounded,
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminCourtListScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  // Module 2: Kelola Booking
                  _buildAdminModuleCard(
                    context,
                    title: 'Kelola Seluruh Booking',
                    subtitle: 'Pantau status booking, konfirmasi manual & blokir slot maintenance.',
                    icon: Icons.calendar_month_rounded,
                    color: Colors.blue.shade700,
                    badge: 'Fitur Utama',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminBookingListScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  // Module 3: Laporan Keuangan & Midtrans
                  _buildAdminModuleCard(
                    context,
                    title: 'Laporan Transaksi & Midtrans',
                    subtitle: 'Rekap riwayat transaksi pembayaran dan status Midtrans Snap.',
                    icon: Icons.payments_outlined,
                    color: Colors.orange.shade700,
                    badge: 'Keuangan',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminPaymentListScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isCompactText = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isCompactText ? 16 : 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminModuleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
