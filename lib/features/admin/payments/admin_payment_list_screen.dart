import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/payment_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/payment_service.dart';
import '../../customer/customer_main_screen.dart';

class AdminPaymentListScreen extends StatefulWidget {
  const AdminPaymentListScreen({super.key});

  @override
  State<AdminPaymentListScreen> createState() => _AdminPaymentListScreenState();
}

class _AdminPaymentListScreenState extends State<AdminPaymentListScreen> {
  String _selectedStatusFilter = 'all'; // 'all', 'success', 'pending', 'failed'

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

    final paymentService = PaymentService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi & Pembayaran',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<PaymentModel>>(
        stream: paymentService.getAllPaymentsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Gagal memuat data transaksi:\n${snapshot.error}',
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

          final allPayments = snapshot.data ?? [];

          // Calculate summary analytics
          final totalRevenue = allPayments
              .where((p) => p.status.trim().toLowerCase() == 'success' || p.status.trim().toLowerCase() == 'paid')
              .fold<double>(0, (sum, p) => sum + p.amount);

          final successCount = allPayments.where((p) => p.status.trim().toLowerCase() == 'success' || p.status.trim().toLowerCase() == 'paid').length;
          final pendingCount = allPayments.where((p) => p.status.trim().toLowerCase() == 'pending').length;
          final failedCount = allPayments.where((p) => p.status.trim().toLowerCase() == 'failed' || p.status.trim().toLowerCase() == 'expire').length;

          // Apply status filter
          final filteredPayments = _selectedStatusFilter == 'all'
              ? allPayments
              : allPayments.where((p) {
                  final st = p.status.trim().toLowerCase();
                  if (_selectedStatusFilter == 'success') return st == 'success' || st == 'paid';
                  if (_selectedStatusFilter == 'failed') return st == 'failed' || st == 'expire' || st == 'cancelled';
                  return st == _selectedStatusFilter;
                }).toList();

          return Column(
            children: [
              // Total Revenue Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, size: 30, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Pendapatan Terkonfirmasi',
                            style: TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyFormatter.formatRupiah(totalRevenue),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Chips Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'Semua (${allPayments.length})'),
                      const SizedBox(width: 8),
                      _buildFilterChip('success', 'Berhasil ($successCount)'),
                      const SizedBox(width: 8),
                      _buildFilterChip('pending', 'Pending ($pendingCount)'),
                      const SizedBox(width: 8),
                      _buildFilterChip('failed', 'Gagal ($failedCount)'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Payment Items List
              Expanded(
                child: filteredPayments.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredPayments.length,
                        itemBuilder: (context, index) {
                          final payment = filteredPayments[index];
                          final formattedTime = DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(payment.transactionTime);
                          final statusLower = payment.status.trim().toLowerCase();
                          final isSuccess = statusLower == 'success' || statusLower == 'paid';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AppColors.border),
                            ),
                            child: InkWell(
                              onTap: () => _showPaymentDetailModal(context, payment),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Top Row: Payment Method, Status Pill
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              _getPaymentMethodIcon(payment.method),
                                              size: 18,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _formatPaymentMethod(payment.method),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        _buildStatusPill(payment.status),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'ID Transaksi: ${payment.id}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                    Text(
                                      'Ref Booking: ${payment.bookingId}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                    const Divider(height: 18, color: AppColors.border),

                                    // Bottom Row: Time & Amount
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                                            const SizedBox(width: 4),
                                            Text(
                                              formattedTime,
                                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          CurrencyFormatter.formatRupiah(payment.amount),
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: isSuccess ? AppColors.confirmedText : AppColors.textPrimary,
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
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
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
              child: const Icon(Icons.payments_outlined, size: 52, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Transaksi Pembayaran',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Transaksi pembayaran dari Midtrans Snap atau konfirmasi manual akan dicatat di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
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
      case 'success':
      case 'paid':
        bgColor = AppColors.confirmedBg;
        textColor = AppColors.confirmedText;
        label = 'SUCCESS';
        break;
      case 'pending':
        bgColor = AppColors.pendingBg;
        textColor = AppColors.pendingText;
        label = 'PENDING';
        break;
      case 'failed':
      case 'expire':
      case 'cancelled':
        bgColor = AppColors.cancelledBg;
        textColor = AppColors.cancelledText;
        label = 'FAILED';
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

  IconData _getPaymentMethodIcon(String method) {
    final m = method.toLowerCase();
    if (m.contains('qris')) return Icons.qr_code_2_rounded;
    if (m.contains('bank') || m.contains('va') || m.contains('bca') || m.contains('mandiri')) return Icons.account_balance_rounded;
    if (m.contains('gopay') || m.contains('ewallet') || m.contains('ovo')) return Icons.account_balance_wallet_rounded;
    return Icons.payment_rounded;
  }

  String _formatPaymentMethod(String method) {
    final m = method.toLowerCase();
    if (m.contains('qris')) return 'QRIS Instan';
    if (m.contains('bank_transfer') || m.contains('va')) return 'Transfer Bank (VA)';
    if (m.contains('gopay')) return 'GoPay / E-Wallet';
    if (m.contains('manual')) return 'Konfirmasi Manual Admin';
    return method.toUpperCase();
  }

  void _showPaymentDetailModal(BuildContext context, PaymentModel payment) {
    final formattedTime = DateFormat('dd MMMM yyyy, HH:mm:ss', 'id_ID').format(payment.transactionTime);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Detail Transaksi Pembayaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const Divider(height: 24),

              _buildDetailRow('ID Transaksi Payment', payment.id),
              _buildDetailRow('ID Ref Booking', payment.bookingId),
              _buildDetailRow('Metode Pembayaran', _formatPaymentMethod(payment.method)),
              _buildDetailRow('Waktu Transaksi', formattedTime),
              _buildDetailRow('Status Transaksi', payment.status.toUpperCase()),
              _buildDetailRow('Total Nominal', CurrencyFormatter.formatRupiah(payment.amount)),
              if (payment.snapToken != null) ...[
                _buildDetailRow('Midtrans Snap Token', payment.snapToken!),
              ],
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
