import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/booking_model.dart';
import '../../../models/court_model.dart';
import '../../../providers/booking_provider.dart';
import 'booking_summary_screen.dart';

class BookingSlotScreen extends StatefulWidget {
  final CourtModel court;

  const BookingSlotScreen({
    super.key,
    required this.court,
  });

  @override
  State<BookingSlotScreen> createState() => _BookingSlotScreenState();
}

class _BookingSlotScreenState extends State<BookingSlotScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _next7Days;

  String? _selectedStartTime;
  int _selectedDuration = 1; // 1 or 2 hours

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _next7Days = List.generate(
      7,
      (index) => _selectedDate.add(Duration(days: index)),
    );
  }

  /// Generate all available 1-hour slot start times between openTime and closeTime
  List<String> _generateTimeSlots() {
    final List<String> slots = [];
    try {
      final openHour = int.parse(widget.court.openTime.split(':')[0]);
      final closeHour = int.parse(widget.court.closeTime.split(':')[0]);

      for (int hour = openHour; hour < closeHour; hour++) {
        final formattedHour = hour.toString().padLeft(2, '0');
        slots.add('$formattedHour:00');
      }
    } catch (_) {
      // Fallback default 08:00 - 22:00
      for (int hour = 8; hour < 22; hour++) {
        final formattedHour = hour.toString().padLeft(2, '0');
        slots.add('$formattedHour:00');
      }
    }
    return slots;
  }

  /// Helper to calculate end time string based on start time and duration in hours
  String _calculateEndTime(String startTime, int durationHours) {
    final parts = startTime.split(':');
    final hour = int.parse(parts[0]);
    final endHour = hour + durationHours;
    return '${endHour.toString().padLeft(2, '0')}:00';
  }

  /// Check if a given 1-hour slot is occupied by any active booking
  bool _isSlotOccupied(String slotTime, List<BookingModel> activeBookings) {
    for (final booking in activeBookings) {
      final bStart = booking.startTime;
      final bEnd = booking.endTime;

      // Slot is occupied if slotTime falls within [bStart, bEnd)
      if (slotTime.compareTo(bStart) >= 0 && slotTime.compareTo(bEnd) < 0) {
        return true;
      }
    }
    return false;
  }

  /// Check if a given slot is specifically blocked for maintenance
  bool _isSlotBlocked(String slotTime, List<BookingModel> activeBookings) {
    for (final booking in activeBookings) {
      if (booking.status.trim().toLowerCase() == 'blocked') {
        final bStart = booking.startTime;
        final bEnd = booking.endTime;
        if (slotTime.compareTo(bStart) >= 0 && slotTime.compareTo(bEnd) < 0) {
          return true;
        }
      }
    }
    return false;
  }

  /// Check if a 2-hour duration starting at [startTime] is valid
  bool _canSelect2Hours(String startTime, List<BookingModel> activeBookings) {
    final endTime2h = _calculateEndTime(startTime, 2);
    final closeTime = widget.court.closeTime;

    // Check if 2h exceeds close time
    if (endTime2h.compareTo(closeTime) > 0) {
      return false;
    }

    // Next 1-hour slot
    final nextSlot = _calculateEndTime(startTime, 1);

    // Check if either current slot or next slot is occupied
    if (_isSlotOccupied(startTime, activeBookings) || _isSlotOccupied(nextSlot, activeBookings)) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final allSlots = _generateTimeSlots();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Pilih Jadwal Main',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: bookingProvider.getBookingsForCourtAndDateStream(
          widget.court.id,
          _selectedDate,
        ),
        builder: (context, snapshot) {
          final activeBookings = snapshot.data ?? [];

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Court Info Header Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 54,
                                height: 54,
                                color: AppColors.primary.withValues(alpha: 0.1),
                                child: Image.network(
                                  widget.court.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Center(
                                    child: Icon(Icons.sports_tennis, color: AppColors.primary, size: 28),
                                  ),
                                ),
                              ),
                            ),
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
                                  const SizedBox(height: 2),
                                  Text(
                                    '${CurrencyFormatter.formatRupiah(widget.court.pricePerHour)} / jam',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Section Title 1: Pilih Tanggal (7 Hari)
                      const Row(
                        children: [
                          Icon(Icons.calendar_month_rounded, size: 20, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Pilih Tanggal Bermain', style: AppTextStyles.subheading),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Horizontal Date Picker (7 days)
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _next7Days.length,
                          itemBuilder: (context, index) {
                            final date = _next7Days[index];
                            final isSelected = date.year == _selectedDate.year &&
                                date.month == _selectedDate.month &&
                                date.day == _selectedDate.day;

                            final isToday = index == 0;
                            final dayName = isToday ? 'Hari Ini' : DateFormat('EEE', 'id_ID').format(date);
                            final dateStr = DateFormat('dd MMM', 'id_ID').format(date);

                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedDate = date;
                                    _selectedStartTime = null; // Reset selection on date change
                                  });
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 74,
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? const LinearGradient(
                                            colors: [AppColors.primaryDark, AppColors.primary],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          )
                                        : null,
                                    color: isSelected ? null : AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.border,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary.withValues(alpha: 0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        dayName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected ? Colors.white70 : AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateStr,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section Title 2: Durasi Bermain
                      const Row(
                        children: [
                          Icon(Icons.timer_rounded, size: 20, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Pilih Durasi Bermain', style: AppTextStyles.subheading),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Duration Selector Chips (1 Jam / 2 Jam)
                      Row(
                        children: [1, 2].map((dur) {
                          final isSelected = _selectedDuration == dur;
                          final bool can2h = _selectedStartTime == null || _canSelect2Hours(_selectedStartTime!, activeBookings);

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ChoiceChip(
                              label: Text('$dur Jam Permainan'),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.surface,
                              disabledColor: AppColors.background,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                fontSize: 13,
                              ),
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : AppColors.border,
                              ),
                              onSelected: (dur == 2 && !can2h)
                                  ? null
                                  : (selected) {
                                      if (selected) {
                                        setState(() {
                                          _selectedDuration = dur;
                                        });
                                      }
                                    },
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Legend Status Slot
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 20, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('Pilih Jam Operasional', style: AppTextStyles.subheading),
                            ],
                          ),
                          Row(
                            children: [
                              _buildLegendItem(AppColors.primary, 'Dipilih'),
                              const SizedBox(width: 8),
                              _buildLegendItem(AppColors.surface, 'Tersedia', hasBorder: true),
                              const SizedBox(width: 8),
                              _buildLegendItem(AppColors.cancelledBg, 'Dibooking', hasBorder: true, borderColor: AppColors.error),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Grid Slot Jam Operasional
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2.1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: allSlots.length,
                        itemBuilder: (context, index) {
                          final slotTime = allSlots[index];
                          final isOccupied = _isSlotOccupied(slotTime, activeBookings);
                          final isBlocked = _isSlotBlocked(slotTime, activeBookings);
                          final isSelected = _selectedStartTime == slotTime;

                          Color bgColor = AppColors.surface;
                          Color textColor = AppColors.textPrimary;
                          Color borderColor = AppColors.border;

                          if (isBlocked) {
                            bgColor = Colors.blueGrey.shade100;
                            textColor = AppColors.textPrimary;
                            borderColor = Colors.blueGrey.shade300;
                          } else if (isOccupied) {
                            bgColor = AppColors.cancelledBg;
                            textColor = AppColors.error;
                            borderColor = AppColors.error.withValues(alpha: 0.3);
                          } else if (isSelected) {
                            bgColor = AppColors.primary;
                            textColor = Colors.white;
                            borderColor = AppColors.primary;
                          }

                          return InkWell(
                            onTap: (isOccupied || isBlocked)
                                ? null
                                : () {
                                    setState(() {
                                      _selectedStartTime = slotTime;
                                      if (_selectedDuration == 2 && !_canSelect2Hours(slotTime, activeBookings)) {
                                        _selectedDuration = 1;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Durasi disesuaikan menjadi 1 jam (slot berikutnya tidak tersedia).'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    });
                                  },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [AppColors.primaryDark, AppColors.primary],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected ? null : bgColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (isSelected) const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                                      if (isBlocked) const Icon(Icons.build_rounded, size: 13, color: AppColors.textPrimary),
                                      if (isOccupied && !isBlocked) const Icon(Icons.lock_rounded, size: 13, color: AppColors.error),
                                      if (isSelected || isOccupied || isBlocked) const SizedBox(width: 4),
                                      Text(
                                        slotTime,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isSelected || isOccupied || isBlocked ? FontWeight.bold : FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isBlocked) ...[
                                    const SizedBox(height: 2),
                                    const Text(
                                      'DIBLOKIR',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ] else if (isOccupied) ...[
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Dibooking',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: AppColors.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Sticky Bottom Navigation Bar with summary & gradient CTA button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedStartTime == null
                                ? 'Total Biaya'
                                : '${_selectedStartTime!} - ${_calculateEndTime(_selectedStartTime!, _selectedDuration)} WIB',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedStartTime == null
                                ? 'Pilih Jam'
                                : CurrencyFormatter.formatRupiah(widget.court.pricePerHour * _selectedDuration),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: _selectedStartTime == null
                                ? null
                                : const LinearGradient(
                                    colors: [AppColors.primaryDark, AppColors.primary],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            color: _selectedStartTime == null ? Colors.grey.shade300 : null,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: _selectedStartTime == null
                                ? null
                                : [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _selectedStartTime == null
                                  ? null
                                  : () {
                                      final endTime = _calculateEndTime(_selectedStartTime!, _selectedDuration);
                                      final totalPrice = widget.court.pricePerHour * _selectedDuration;

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BookingSummaryScreen(
                                            court: widget.court,
                                            bookingDate: _selectedDate,
                                            startTime: _selectedStartTime!,
                                            endTime: endTime,
                                            durationHours: _selectedDuration,
                                            totalPrice: totalPrice,
                                          ),
                                        ),
                                      );
                                    },
                              borderRadius: BorderRadius.circular(14),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Lanjut ke Ringkasan',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool hasBorder = false, Color? borderColor}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: hasBorder ? Border.all(color: borderColor ?? AppColors.border) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
