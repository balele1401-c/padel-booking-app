import '../services/booking_service.dart';
import '../services/court_service.dart';

class ChatbotService {
  final CourtService _courtService;
  final BookingService _bookingService;

  ChatbotService({
    CourtService? courtService,
    BookingService? bookingService,
  })  : _courtService = courtService ?? CourtService(),
        _bookingService = bookingService ?? BookingService();

  /// Send message to AI Assistant.
  /// Queries live Firestore court & booking data to generate instant smart answers.
  Future<String> sendMessage({
    required String message,
    required String userId,
  }) async {
    // 1. Enforce strict scope boundary locally
    if (_isOutOfScope(message)) {
      return 'Maaf, saya adalah **Padel AI Assistant** yang dikhususkan untuk membantu seputar pemesanan lapangan padel, jam operasional, harga sewa, dan metode pembayaran. 🎾\n\n'
          'Untuk pertanyaan di luar topik booking, silakan hubungi **Admin Customer Service** kami langsung via WhatsApp di **0812-3456-7890** atau kunjungi meja resepsionis di lokasi!';
    }

    // 2. Smart Firestore Assistant Engine (Real-Time Data Integration)
    return await _generateSmartLocalResponse(message);
  }

  /// Check if question is outside the scope of booking / padel
  bool _isOutOfScope(String query) {
    final q = query.toLowerCase();

    // Out-of-scope keywords
    final outKeywords = [
      'resep', 'masak', 'nasi goreng', 'coding', 'flutter', 'python', 'java',
      'politik', 'pemilu', 'presiden', 'film', 'sinetron', 'anime', 'cuaca',
      'gempa', 'saham', 'crypto', 'bitcoin', 'lirik lagu', 'tugas sekolah'
    ];

    for (final kw in outKeywords) {
      if (q.contains(kw)) return true;
    }

    return false;
  }

  /// Smart Firestore Engine: Queries live courts & bookings from Firestore
  Future<String> _generateSmartLocalResponse(String query) async {
    final q = query.toLowerCase();

    // Query 1: Operating Hours & Slots
    if (q.contains('jam') || q.contains('buka') || q.contains('operasional') || q.contains('slot') || q.contains('jadwal')) {
      try {
        final courts = await _courtService.getActiveCourtsStream().first;
        final allBookings = await _bookingService.getAllBookingsStream().first;
        final todayCount = allBookings.where((b) {
          final bd = b.bookingDate;
          final now = DateTime.now();
          return bd.year == now.year && bd.month == now.month && bd.day == now.day;
        }).length;

        final count = courts.length;
        return '🕒 **Jam Operasional & Ketersediaan Slot**:\n\n'
            '• **Jam Operasional**: 07:00 WIB - 23:00 WIB (Buka Setiap Hari).\n'
            '• **Jumlah Lapangan Aktif**: $count Lapangan Padel Premium tersedia.\n'
            '• **Booking Hari Ini**: Ada $todayCount slot terisi hari ini.\n'
            '• **Status Slot**: Anda dapat mengecek slot jam yang tersedia secara real-time dan memilih durasi main (1-2 Jam) langsung di tab **Home**!\n\n'
            'Apakah ada lapangan tertentu yang ingin Anda tanyakan?';
      } catch (_) {
        return '🕒 **Jam Operasional Lapangan**:\n\n'
            'Lapangan Padel kami beroperasi setiap hari dari jam **07:00 WIB hingga 23:00 WIB**.\n'
            'Pemesanan slot dapat dilakukan secara real-time di tab **Home**!';
      }
    }

    // Query 2: Prices / Rental Rates
    if (q.contains('harga') || q.contains('sewa') || q.contains('biaya') || q.contains('tarif') || q.contains('berapa')) {
      try {
        final courts = await _courtService.getActiveCourtsStream().first;
        final buffer = StringBuffer('💰 **Daftar Harga Sewa Lapangan Padel Real-Time**:\n\n');
        for (final c in courts) {
          final priceFormatted = 'Rp ${c.pricePerHour.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
          buffer.writeln('• **${c.name}**: $priceFormatted / jam (Jam ${c.openTime} - ${c.closeTime} WIB)');
        }
        buffer.writeln('\n*Harga sudah termasuk fasilitas shower, loker, dan lampu lapangan malam.');
        return buffer.toString();
      } catch (_) {
        return '💰 **Harga Sewa Lapangan Padel**:\n\n'
            '• **Lapangan Standard**: Rp 150.000 / jam\n'
            '• **Lapangan Premium**: Rp 200.000 / jam\n'
            'Detail lengkap dapat Anda lihat di tab **Home**!';
      }
    }

    // Query 3: Payment Methods
    if (q.contains('bayar') || q.contains('pembayaran') || q.contains('midtrans') || q.contains('qris') || q.contains('bank') || q.contains('transfer')) {
      return '💳 **Metode Pembayaran Tersedia (Midtrans Snap)**:\n\n'
          'Pemesanan terintegrasi dengan **Midtrans Gateway** untuk konfirmasi otomatis:\n'
          '• **QRIS Instan**: Scan via GoPay, OVO, Dana, ShopeePay, LinkAja, & m-Banking.\n'
          '• **Virtual Account**: BCA, Mandiri, BNI, & BRI.\n'
          '• **Pembayaran Manual**: Konfirmasi langsung oleh Admin di lokasi.';
    }

    // Query 4: Cancellation Policy
    if (q.contains('batal') || q.contains('cancel') || q.contains('refund') || q.contains('syarat')) {
      return '❌ **Ketentuan Batalkan Booking**:\n\n'
          '• Pembatalan booking hanya dapat dilakukan minimal **H-1 (24 jam)** sebelum waktu jadwal main.\n'
          '• Pembatalan yang dilakukan kurang dari 24 jam tidak dapat dikembalikan sesuai kebijakan operasional lapangan.\n'
          '• Pembatalan dapat dilakukan langsung melalui tab **Riwayat** -> Tap item booking -> Batalkan.';
    }

    // Query 5: Padel Rules & Racket Tips
    if (q.contains('aturan') || q.contains('peraturan') || q.contains('skor') || q.contains('servis') || q.contains('raket')) {
      return '🎾 **Aturan Dasar & Perlengkapan Padel**:\n\n'
          '1. **Sistem Skor**: Menggunakan perhitungan skor 15, 30, 40, Game (sama seperti Tenis).\n'
          '2. **Servis**: Diharuskan underhand (pantul bola 1x di tanah sebelum dipukul di bawah pinggang).\n'
          '3. **Dinding Kaca**: Bola pantulan dari lantai boleh mengenai kaca lapangan.\n'
          '4. **Sewa Raket**: Lapangan menyediakan sewa raket & bola padel standar WPT di lokasi!';
    }

    // Query 6: Default fallback for general greetings / booking questions
    return 'Terima kasih telah menghubungi **Padel AI Assistant**! 🤖\n\n'
        'Saya siap membantu Anda seputar ketersediaan slot, harga sewa lapangan, jam operasional, dan cara pembayaran.\n\n'
        'Silakan pilih pertanyaan populer di atas atau ketik pertanyaan seputar pemesanan lapangan Anda!';
  }
}
