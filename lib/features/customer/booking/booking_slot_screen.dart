import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/booking_model.dart';
import '../../../models/court_model.dart';
import '../../../providers/booking_provider.dart';
import '../../../shared/widgets/custom_button.dart';
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
        title: const Text('Pilih Jadwal Main'),
        centerTitle: true,
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Court info banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.sports_tennis,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
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
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section Title 1: Pilih Tanggal (7 Hari)
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          const Text('Pilih Tanggal', style: AppTextStyles.subheading),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Horizontal Date Picker (7 days)
                      SizedBox(
                        height: 76,
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
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 72,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.border,
                                      width: isSelected ? 2 : 1,
                                    ),
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
                                      Text(
                                        dayName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? Colors.white : AppColors.textSecondary,
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
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          const Text('Pilih Durasi', style: AppTextStyles.subheading),
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
                              label: Text('$dur Jam'),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.surface,
                              disabledColor: AppColors.background,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
                              Icon(Icons.schedule, size: 20, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('Pilih Jam Main', style: AppTextStyles.subheading),
                            ],
                          ),
                          Row(
                            children: [
                              _buildLegendItem(AppColors.primary, 'Dipilih'),
                              const SizedBox(width: 8),
                              _buildLegendItem(AppColors.surface, 'Tersedia', hasBorder: true),
                              const SizedBox(width: 8),
                              _buildLegendItem(Colors.grey.shade300, 'Terisi'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Grid Slot Jam Operasional
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2.2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: allSlots.length,
                        itemBuilder: (context, index) {
                          final slotTime = allSlots[index];
                          final isOccupied = _isSlotOccupied(slotTime, activeBookings);
                          final isSelected = _selectedStartTime == slotTime;

                          Color bgColor = AppColors.surface;
                          Color textColor = AppColors.textPrimary;
                          Color borderColor = AppColors.border;

                          if (isOccupied) {
                            bgColor = Colors.grey.shade200;
                            textColor = Colors.grey.shade500;
                            borderColor = Colors.transparent;
                          } else if (isSelected) {
                            bgColor = AppColors.primary;
                            textColor = Colors.white;
                            borderColor = AppColors.primary;
                          }

                          return InkWell(
                            onTap: isOccupied
                                ? null
                                : () {
                                    setState(() {
                                      _selectedStartTime = slotTime;
                                      // If 2 hours is selected, check if valid, otherwise auto-revert to 1 hour
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
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    slotTime,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected || isOccupied ? FontWeight.bold : FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                                  if (isOccupied) ...[
                                    const SizedBox(height: 1),
                                    const Text(
                                      'Terisi',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
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

              // Bottom Navigation bar with summary & button
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Biaya',
                              style: TextStyle(
                                fontSize: 12,
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
                      ),
                      Expanded(
                        child: CustomButton(
                          text: 'Lanjut',
                          icon: Icons.arrow_forward,
                          onPressed: _selectedStartTime == null
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

  Widget _buildLegendItem(Color color, String label, {bool hasBorder = false}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: hasBorder ? Border.all(color: AppColors.border) : null,
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
