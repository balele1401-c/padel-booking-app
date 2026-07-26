import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/booking_model.dart';
import '../../../models/court_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/court_provider.dart';
import '../../../services/booking_service.dart';
import '../../customer/customer_main_screen.dart';

class AdminBookingListScreen extends StatefulWidget {
  const AdminBookingListScreen({super.key});

  @override
  State<AdminBookingListScreen> createState() => _AdminBookingListScreenState();
}

class _AdminBookingListScreenState extends State<AdminBookingListScreen> {
  String _selectedStatusFilter = 'all'; // 'all', 'pending', 'confirmed', 'cancelled', 'blocked'
  DateTime? _selectedDateFilter;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    // Role Protection (Admin only)
    if (user == null || !user.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akses ditolak: Menu ini hanya dapat diakses oleh admin.'),
            backgroundColor: AppColors.error,
          ),
        );
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
          'Kelola Pemesanan Customer',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.block_rounded, color: Colors.white),
            tooltip: 'Blokir Slot Maintenance',
            onPressed: () => _showBlockMaintenanceDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: bookingService.getAllBookingsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Gagal memuat data booking:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final allBookings = snapshot.data ?? [];

          // Real-time counts
          final pendingCount = allBookings.where((b) => b.status.trim().toLowerCase() == 'pending').length;
          final confirmedCount = allBookings.where((b) => b.status.trim().toLowerCase() == 'confirmed').length;
          final cancelledCount = allBookings.where((b) => b.status.trim().toLowerCase() == 'cancelled').length;
          final blockedCount = allBookings.where((b) => b.status.trim().toLowerCase() == 'blocked').length;

          // Apply date & status filters
          final filteredBookings = allBookings.where((b) {
            // Status match
            final statusMatch = _selectedStatusFilter == 'all'
                ? true
                : b.status.trim().toLowerCase() == _selectedStatusFilter;

            // Date match
            bool dateMatch = true;
            if (_selectedDateFilter != null) {
              final bDate = b.bookingDate;
              dateMatch = bDate.year == _selectedDateFilter!.year &&
                  bDate.month == _selectedDateFilter!.month &&
                  bDate.day == _selectedDateFilter!.day;
            }

            return statusMatch && dateMatch;
          }).toList();

          return Column(
            children: [
              // Top Control Bar: Date Filter & Maintenance Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.surface,
                child: Row(
                  children: [
                    // Date Filter Button
                    OutlinedButton.icon(
                      icon: Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: _selectedDateFilter != null ? AppColors.primary : AppColors.textSecondary,
                      ),
                      label: Text(
                        _selectedDateFilter == null
                            ? 'Filter Tanggal'
                            : DateFormat('dd MMM yyyy', 'id_ID').format(_selectedDateFilter!),
                        style: TextStyle(
                          fontSize: 12,
                          color: _selectedDateFilter != null ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: _selectedDateFilter != null ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _selectedDateFilter != null ? AppColors.primary : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDateFilter ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 90)),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDateFilter = picked;
                          });
                        }
                      },
                    ),
                    if (_selectedDateFilter != null) ...[
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.error),
                        tooltip: 'Reset Filter Tanggal',
                        onPressed: () {
                          setState(() {
                            _selectedDateFilter = null;
                          });
                        },
                      ),
                    ],
                    const Spacer(),

                    // Maintenance Button CTA
                    ElevatedButton.icon(
                      icon: const Icon(Icons.build_rounded, size: 14, color: Colors.white),
                      label: const Text('Blokir Slot', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showBlockMaintenanceDialog(context),
                    ),
                  ],
                ),
              ),

              // Filter Chips Bar (Clean transparent layout)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'Semua (${allBookings.length})'),
                      const SizedBox(width: 8),
                      _buildFilterChip('pending', 'Pending ($pendingCount)'),
                      const SizedBox(width: 8),
                      _buildFilterChip('confirmed', 'Confirmed ($confirmedCount)'),
                      const SizedBox(width: 8),
                      _buildFilterChip('cancelled', 'Cancelled ($cancelledCount)'),
                      const SizedBox(width: 8),
                      _buildFilterChip('blocked', 'Diblokir ($blockedCount)'),
                    ],
                  ),
                ),
              ),

              // Booking Items List
              Expanded(
                child: filteredBookings.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredBookings.length,
                        itemBuilder: (context, index) {
                          final booking = filteredBookings[index];
                          final formattedDate = DateFormat('EEE, dd MMM yyyy', 'id_ID').format(booking.bookingDate);
                          final isBlocked = booking.status.trim().toLowerCase() == 'blocked';
                          final isPaid = booking.paymentStatus.trim().toLowerCase() == 'paid' ||
                              booking.status.trim().toLowerCase() == 'confirmed' ||
                              booking.status.trim().toLowerCase() == 'completed';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: isBlocked ? Colors.blueGrey.shade50 : AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isBlocked ? Colors.blueGrey.shade300 : AppColors.border,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Row: Court Name, Booking Status Pill & Payment Status Pill
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                      const SizedBox(width: 6),
                                      _buildStatusPill(booking.status),
                                      if (!isBlocked) ...[
                                        const SizedBox(width: 6),
                                        _buildPaymentStatusPill(isPaid ? 'paid' : booking.paymentStatus),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isBlocked ? 'Diblokir oleh Admin Maintenance' : 'ID Booking: ${booking.id}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isBlocked ? AppColors.textPrimary : AppColors.textSecondary,
                                      fontWeight: isBlocked ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  const Divider(height: 20, color: AppColors.border),

                                  // Date & Time Row
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                                      const SizedBox(width: 6),
                                      Text(formattedDate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                      const SizedBox(width: 14),
                                      const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                                      const SizedBox(width: 6),
                                      Text('${booking.startTime} - ${booking.endTime} WIB', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Highlighted Box: Payment Status or Maintenance Note
                                  if (isBlocked) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.blueGrey.shade300),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.build_circle_rounded, size: 18, color: AppColors.textPrimary),
                                          const SizedBox(width: 8),
                                          const Expanded(
                                            child: Text(
                                              'Status: SLOT DIBLOKIR UNTUK MAINTENANCE',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ] else ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isPaid
                                            ? AppColors.confirmedBg.withValues(alpha: 0.4)
                                            : AppColors.pendingBg.withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isPaid
                                              ? AppColors.confirmedText.withValues(alpha: 0.3)
                                              : AppColors.pendingText.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                isPaid ? Icons.verified_rounded : Icons.pending_actions_rounded,
                                                size: 18,
                                                color: isPaid ? AppColors.confirmedText : AppColors.pendingText,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Status Pembayaran: ${isPaid ? "LUNAS (PAID)" : "BELUM DIBAYAR (PENDING)"}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: isPaid ? AppColors.confirmedText : AppColors.pendingText,
                                                ),
                                              ),
                                            ],
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
                                    ),
                                  ],
                                  const SizedBox(height: 14),

                                  // Admin Action Buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (isBlocked) ...[
                                        OutlinedButton.icon(
                                          icon: const Icon(Icons.lock_open_rounded, size: 16, color: AppColors.primary),
                                          label: const Text('Buka Blokir Slot', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: AppColors.primary),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onPressed: () async {
                                            await bookingService.unblockSlot(booking.id);
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Slot maintenance berhasil dibuka kembali!'),
                                                backgroundColor: AppColors.primary,
                                              ),
                                            );
                                          },
                                        ),
                                      ] else if (booking.status.trim().toLowerCase() == 'pending') ...[
                                        OutlinedButton.icon(
                                          icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.confirmedText),
                                          label: const Text('Konfirmasi & Tandai Lunas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.confirmedText)),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: AppColors.confirmedText),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onPressed: () async {
                                            await bookingService.updateBookingStatus(
                                              booking.id,
                                              'confirmed',
                                              paymentStatus: 'paid',
                                            );
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Pemesanan dikonfirmasi & ditandai Lunas!'),
                                                backgroundColor: AppColors.primary,
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton.icon(
                                          icon: const Icon(Icons.cancel_outlined, size: 16, color: AppColors.error),
                                          label: const Text('Tolak / Batalkan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.error)),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: AppColors.error),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onPressed: () async {
                                            await bookingService.cancelBooking(booking.id);
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Pemesanan dibatalkan.'),
                                                backgroundColor: AppColors.error,
                                              ),
                                            );
                                          },
                                        ),
                                      ] else if (booking.status.trim().toLowerCase() == 'confirmed') ...[
                                        OutlinedButton.icon(
                                          icon: const Icon(Icons.task_alt_rounded, size: 16, color: AppColors.primary),
                                          label: const Text('Tandai Selesai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: AppColors.primary),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onPressed: () async {
                                            await bookingService.updateBookingStatus(booking.id, 'completed');
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Pemesanan ditandai Selesai!'),
                                                backgroundColor: AppColors.primary,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    IconData emptyIcon;
    String emptyTitle;
    String emptySubtitle;

    switch (_selectedStatusFilter) {
      case 'pending':
        emptyIcon = Icons.pending_actions_rounded;
        emptyTitle = 'Tidak Ada Pemesanan Pending';
        emptySubtitle = 'Saat ini tidak ada pemesanan baru yang menunggu konfirmasi.';
        break;
      case 'confirmed':
        emptyIcon = Icons.task_alt_rounded;
        emptyTitle = 'Belum Ada Pemesanan Confirmed';
        emptySubtitle = 'Pemesanan yang telah dikonfirmasi atau dibayar oleh customer akan muncul di sini.';
        break;
      case 'cancelled':
        emptyIcon = Icons.cancel_outlined;
        emptyTitle = 'Tidak Ada Pemesanan Dibatalkan';
        emptySubtitle = 'Pemesanan yang dibatalkan oleh customer atau admin akan dicatat di sini.';
        break;
      case 'blocked':
        emptyIcon = Icons.build_rounded;
        emptyTitle = 'Tidak Ada Slot Diblokir';
        emptySubtitle = 'Belum ada slot lapangan yang diblokir untuk keperluan maintenance.';
        break;
      default:
        emptyIcon = Icons.inbox_outlined;
        emptyTitle = 'Belum Ada Pemesanan';
        emptySubtitle = 'Belum ada transaksi pemesanan lapangan yang sesuai dengan filter.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(emptyIcon, size: 52, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              emptyTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedStatusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedStatusFilter = value;
          });
        }
      },
    );
  }

  Widget _buildStatusPill(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.trim().toLowerCase()) {
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
      case 'blocked':
        bgColor = Colors.blueGrey.shade100;
        textColor = AppColors.textPrimary;
        label = 'DIBLOKIR';
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildPaymentStatusPill(String paymentStatus) {
    final isPaid = paymentStatus.trim().toLowerCase() == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPaid ? AppColors.confirmedBg : AppColors.pendingBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isPaid ? 'PAID' : 'UNPAID',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isPaid ? AppColors.confirmedText : AppColors.pendingText,
        ),
      ),
    );
  }

  /// Show Modal Dialog for Blocking Court Slot for Maintenance
  void _showBlockMaintenanceDialog(BuildContext context) {
    final courtProvider = Provider.of<CourtProvider>(context, listen: false);
    final bookingService = BookingService();

    DateTime selectedDate = DateTime.now();
    String selectedTime = '08:00';
    CourtModel? selectedCourt;
    final noteController = TextEditingController();

    final timeSlots = [
      '07:00', '08:00', '09:00', '10:00', '11:00', '12:00',
      '13:00', '14:00', '15:00', '16:00', '17:00', '18:00',
      '19:00', '20:00', '21:00', '22:00'
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StreamBuilder<List<CourtModel>>(
          stream: courtProvider.allCourtsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return AlertDialog(
                title: const Text('Blokir Slot Maintenance'),
                content: snapshot.connectionState == ConnectionState.waiting
                    ? const SizedBox(
                        height: 80,
                        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      )
                    : const Text('Belum ada data lapangan. Silakan tambah lapangan terlebih dahulu.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Tutup'),
                  ),
                ],
              );
            }

            final courts = snapshot.data!;
            selectedCourt ??= courts.first;

            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.build_rounded, color: AppColors.warning),
                      SizedBox(width: 10),
                      Text('Blokir Slot Maintenance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pilih Lapangan:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<CourtModel>(
                          initialValue: selectedCourt,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: courts.map((c) {
                            return DropdownMenuItem(value: c, child: Text(c.name));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedCourt = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 14),

                        const Text('Pilih Tanggal Maintenance:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today_rounded, size: 16),
                          label: Text(DateFormat('EEE, dd MMM yyyy', 'id_ID').format(selectedDate)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 90)),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 14),

                        const Text('Pilih Jam Mulai Slot:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: selectedTime,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: timeSlots.map((t) {
                            return DropdownMenuItem(value: t, child: Text('$t WIB'));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedTime = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 14),

                        const Text('Catatan Maintenance (Opsional):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: noteController,
                          decoration: InputDecoration(
                            hintText: 'contoh: Perbaikan Jaring / Pengecatan',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
                      onPressed: () async {
                        if (selectedCourt == null) return;
                        try {
                          final startHour = int.parse(selectedTime.split(':')[0]);
                          final endTime = '${(startHour + 1).toString().padLeft(2, '0')}:00';

                          await bookingService.blockSlotForMaintenance(
                            courtId: selectedCourt!.id,
                            courtName: selectedCourt!.name,
                            date: selectedDate,
                            startTime: selectedTime,
                            endTime: endTime,
                            note: noteController.text.trim(),
                          );

                          if (!context.mounted) return;
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Slot $selectedTime di ${selectedCourt!.name} berhasil diblokir untuk maintenance!'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString().replaceAll('Exception: ', '')),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                      child: const Text('Simpan Blokir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
