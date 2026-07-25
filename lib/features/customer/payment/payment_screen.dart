import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/config/midtrans_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/booking_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import 'payment_failed_screen.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final BookingModel booking;

  const PaymentScreen({
    super.key,
    required this.booking,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedCategory = 'qris'; // 'qris', 'bank_transfer', 'ewallet'
  String _selectedMethod = 'QRIS / GoPay';
  String _vaNumber = '';

  @override
  void initState() {
    super.initState();
    _generateVaNumber();
  }

  void _generateVaNumber() {
    // Generate deterministic VA number for sandbox simulation
    final cleanId = widget.booking.id.replaceAll(RegExp(r'[^0-9]'), '');
    final suffix = cleanId.isNotEmpty ? cleanId.padRight(8, '0').substring(0, 8) : '88392019';
    _vaNumber = '88012$suffix';
  }

  Future<void> _handlePayNow() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    final userId = authProvider.userModel?.id ?? widget.booking.userId;

    // Simulate Midtrans Snap token
    final mockSnapToken = 'SNAP-SANDBOX-${DateTime.now().millisecondsSinceEpoch}';

    final success = await paymentProvider.processPaymentSuccess(
      bookingId: widget.booking.id,
      userId: userId,
      method: _selectedMethod,
      amount: widget.booking.totalPrice,
      snapToken: mockSnapToken,
    );

    if (!mounted) return;

    if (success) {
      final updatedBooking = widget.booking.copyWith(
        status: 'confirmed',
        paymentStatus: 'paid',
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            booking: updatedBooking,
            paymentMethod: _selectedMethod,
            paymentId: mockSnapToken,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(paymentProvider.errorMessage ?? 'Gagal memproses pembayaran.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleCancel() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    final userId = authProvider.userModel?.id ?? widget.booking.userId;

    await paymentProvider.processPaymentFailure(
      bookingId: widget.booking.id,
      userId: userId,
      method: _selectedMethod,
      amount: widget.booking.totalPrice,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentFailedScreen(
          booking: widget.booking,
          reason: 'Pembayaran dibatalkan oleh pengguna.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pembayaran Midtrans Snap'),
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
                  // Midtrans Sandbox Environment Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.payment, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Midtrans Payment Gateway',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'SANDBOX MODE',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.pendingText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Client Key: ${MidtransConfig.clientKey.length > 14 ? MidtransConfig.clientKey.substring(0, 14) : MidtransConfig.clientKey}...',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Billing Amount Header Card
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Tagihan',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                              Text(
                                CurrencyFormatter.formatRupiah(widget.booking.totalPrice),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.booking.courtName ?? 'Lapangan Padel',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${widget.booking.startTime} - ${widget.booking.endTime} WIB (${widget.booking.durationHours} Jam)',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section Title: Pilih Metode Pembayaran
                  const Text('Pilih Metode Pembayaran', style: AppTextStyles.subheading),
                  const SizedBox(height: 12),

                  // Category Tabs (QRIS, Bank Transfer, E-Wallet)
                  Row(
                    children: [
                      _buildCategoryTab('qris', 'QRIS', Icons.qr_code_2),
                      const SizedBox(width: 10),
                      _buildCategoryTab('bank_transfer', 'Transfer Bank', Icons.account_balance),
                      const SizedBox(width: 10),
                      _buildCategoryTab('ewallet', 'E-Wallet', Icons.account_balance_wallet),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Method details container
                  if (_selectedCategory == 'qris') ...[
                    _buildQrisSection(),
                  ] else if (_selectedCategory == 'bank_transfer') ...[
                    _buildBankTransferSection(),
                  ] else ...[
                    _buildEwalletSection(),
                  ],

                  const SizedBox(height: 24),

                  // Simulator Info Notice
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.pendingBg.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.pendingText.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.pendingText, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Sandbox Mode Active. Anda dapat menyimulasikan konfirmasi pembayaran instan dengan menekan tombol "Bayar Sekarang".',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.amber.shade900,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Buttons
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomButton(
                    text: 'Bayar Sekarang (${CurrencyFormatter.formatRupiah(widget.booking.totalPrice)})',
                    icon: Icons.lock_outline,
                    isLoading: paymentProvider.isProcessing,
                    onPressed: paymentProvider.isProcessing ? null : _handlePayNow,
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    text: 'Batal Pembayaran',
                    type: ButtonType.secondary,
                    onPressed: paymentProvider.isProcessing ? null : _handleCancel,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String categoryId, String label, IconData icon) {
    final isSelected = _selectedCategory == categoryId;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = categoryId;
            if (categoryId == 'qris') {
              _selectedMethod = 'QRIS / GoPay';
            } else if (categoryId == 'bank_transfer') {
              _selectedMethod = 'Transfer Bank BCA';
            } else {
              _selectedMethod = 'GoPay / ShopeePay';
            }
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrisSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_2, color: AppColors.primary, size: 28),
                SizedBox(width: 8),
                Text(
                  'QRIS Standar Indonesia',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 160,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Bisa di-scan menggunakan GoPay, OVO, Dana, ShopeePay, LinkAja, atau m-Banking',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankTransferSection() {
    final banks = [
      {'name': 'Transfer Bank BCA', 'code': 'BCA'},
      {'name': 'Transfer Bank BNI', 'code': 'BNI'},
      {'name': 'Transfer Bank BRI', 'code': 'BRI'},
      {'name': 'Transfer Bank Mandiri', 'code': 'Mandiri'},
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Bank Virtual Account',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...banks.map((b) {
              final isSelected = _selectedMethod == b['name'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMethod = b['name']!;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          b['name']!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const Divider(height: 24),
            const Text(
              'Nomor Virtual Account (Sandbox)',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _vaNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy, color: AppColors.primary),
                  tooltip: 'Salin VA',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _vaNumber));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nomor Virtual Account berhasil disalin!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEwalletSection() {
    final ewallets = [
      {'name': 'GoPay / QRIS', 'desc': 'Bayar instan via aplikasi Gojek'},
      {'name': 'ShopeePay', 'desc': 'Bayar via aplikasi Shopee'},
      {'name': 'Dana / OVO', 'desc': 'Bayar via aplikasi E-Wallet'},
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Layanan E-Wallet',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...ewallets.map((ew) {
              final isSelected = _selectedMethod == ew['name'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMethod = ew['name']!;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ew['name']!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              ew['desc']!,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
