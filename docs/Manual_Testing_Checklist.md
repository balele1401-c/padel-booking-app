# Checklist Testing Manual & Review UX/UI Aplikasi Padel Booking 🎾📋

Dokumen ini berisi panduan pengujian manual menyeluruh (*end-to-end testing checklist*) dan review UX/UI untuk persiapan demo sidang skripsi / wawancara kerja teknis.

---

## 🎯 1. Review UX & Konsistensi UI (Sesuai PRD)

| Komponen UX/UI | Kriteria Kelayakan | Status Review |
|---|---|---|
| **Sistem Warna** | Midnight Teal (`#0D5C5B`), Emerald Green (`#00A86B`), Dark Slate Gray (`#1A252C`), & Light Surface (`#F4F7F6`). | ✅ Konsisten di 100% Layar |
| **Tipografi** | Judul Bold Proposional, Body Text legibel dengan kontras tinggi (WCG AAA Compliant). | ✅ Konsisten di 100% Layar |
| **Loading State** | `CircularProgressIndicator` bergradien & Skeleton Loader saat mengambil data Firestore real-time. | ✅ Terpasang di semua Stream & Future |
| **Empty State** | Pesan & Ilustrasi yang ramah ketika data kosong (misal: *Belum Ada Booking*, *Tidak Ada Pembayaran*). | ✅ Terpasang di semua List Screen |
| **Error Handling** | Floating Snackbar / Error Card yang informatif jika koneksi gagal atau izin ditolak. | ✅ Terpasang di Auth, Booking, & Admin |

---

## 🧪 2. Checklist Testing Manual Skenario Demo

### A. Alur Otentikasi (Auth & Role Management)
- [x] **Registrasi Akun Baru**: Buat akun customer baru dengan email & kata sandi valid.
- [x] **Validasi Form Auth**: Pastikan error tampil jika email salah format atau kata sandi < 6 karakter.
- [x] **Login Customer**: Login akun customer ➔ Masuk ke **Customer Bottom Navigation (4 Tab)**.
- [x] **Login Admin**: Login akun `superadmin@gmail.com` ➔ Masuk ke **Admin Dashboard Analytics**.
- [x] **Role Guard**: Pastikan customer tidak bisa mengakses halaman admin secara paksa.

### B. Alur Customer Booking & Slot Selector
- [x] **Melihat Daftar Lapangan (Home)**: Tampilan card lapangan berfoto, badge harga, dan status aktif.
- [x] **Detail Lapangan**: Informasi spesifikasi lapangan, fasilitas (shower, loker, lampu), dan jam operasional.
- [x] **Slot Time Selector**:
  - Slot waktu terisi (merah / rose badge `DIBOOKING`) tidak bisa diklik.
  - Slot maintenance (slate gray badge `DIBLOKIR 🔒`) tidak bisa diklik.
  - Slot kosong (teal badge) dapat dipilih untuk durasi 1 Jam atau 2 Jam.
- [x] **Ringkasan Pemesanan**: Menampilkan tanggal main, rincian jam, durasi, total harga, dan data customer.

### C. Alur Pembayaran Midtrans Snap
- [x] **Sandbox Payment Gateway**: Integrasi dialog Midtrans Snap (QRIS Instan & Virtual Account).
- [x] **Proses Bayar Lunas**: Simulasi bayar sukses ➔ Struk **"Pembayaran Berhasil!"** tampil.
- [x] **Perubahan Status Real-Time**: Status booking otomatis berubah dari `PENDING` ➔ `CONFIRMED` & `PAID`.

### D. Alur Riwayat Booking & Pembatalan (H-1)
- [x] **Tab Riwayat (Upcoming vs History)**: Menampilkan daftar booking aktif dan lampau.
- [x] **Detail Bottom Sheet**: Menampilkan ID booking unik, rincian pembayaran, dan tombol aksi.
- [x] **Pembatalan H-1**: Tombol pembatalan aktif hanya untuk H-1 (24 jam sebelum main). Pembatalan kurang dari 24 jam dicegah dengan pesan peringatan.

### E. AI Chatbot Assistant (Smart Firestore Engine)
- [x] **Tanya Slot & Operasional**: Chatbot menjawab jumlah slot terisi hari ini & jam operasional real-time.
- [x] **Tanya Harga Sewa**: Chatbot menampilkan daftar harga sewa per jam terbaru dari Firestore.
- [x] **Tanya Pembayaran & Aturan**: Chatbot menjelaskan metode Midtrans & aturan main padel.
- [x] **Penyaringan Scope (Out-of-Scope)**: Pertanyaan di luar booking otomatis diarahkan ke Admin CS WhatsApp (`0812-3456-7890`).

### F. Panel Admin (Kelola Lapangan, Booking, & Pembayaran)
- [x] **Dashboard Analytics**: Kartu ringkasan 2 kolom (Total Booking Hari ini, Minggu ini, Bulan ini, & Total Revenue) + Grafik Bar Chart Okupansi `fl_chart`.
- [x] **Kelola Lapangan (CRUD)**: Admin bisa Menambah, Mengedit, dan Menghapus lapangan padel.
- [x] **Kelola Booking & Filter**: Filter berdasarkan tanggal (Date Picker) dan status chip (`Semua`, `Pending`, `Confirmed`, `Cancelled`, `Diblokir`).
- [x] **Blokir Slot Maintenance**: Modal dialog blokir slot maintenance meletakkan entry `status: 'blocked'`.
- [x] **Konfirmasi / Penolakan Manual**: Admin dapat mengonfirmasi atau menolak booking secara manual.
- [x] **Laporan Transaksi Pembayaran**: Halaman riwayat transaksi dari collection `payments` dengan rincian status `SUCCESS`, `PENDING`, `EXPIRED`, atau `FAILED`.

---

## 🌟 3. Tips Menjawab Pertanyaan Penguji / Dosen (Sidang & Wawancara)

1. **Topik Double-Booking Prevention**:
   > *"Sistem menggunakan **Deterministic Document ID** (`${courtId}_${yyyy-MM-dd}_${startTime}`) dan Firestore atomic transaction. Dua user yang menekan booking di detik yang sama tidak akan pernah mengalami double-booking karena dokumen ID slot yang sama diproteksi secara atomic di tingkat database."*

2. **Topik Keamanan (Security Rules & Credentials)**:
   > *"Seluruh aturan akses menggunakan **Firestore Security Rules** dengan verifikasi fungsi `isAdmin()` dan `isOwner()`. Customer tidak bisa mengubah status booking secara ilegal. File kredensial sensitif di-untrack dari Git dengan `.gitignore`."*

3. **Topik Arsitektur Code**:
   > *"Frontend dibangun dengan Flutter Material 3, State Management Provider, dan arsitektur modular yang memisahkan layer `features`, `models`, `services`, `providers`, dan `core/theme`."*
