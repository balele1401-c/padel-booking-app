# 📋 Checklist Testing Manual & Review UX/UI Aplikasi Padel Booking 🎾

Dokumen ini berisi panduan pengujian manual menyeluruh (*end-to-end testing checklist*) dan review UX/UI untuk persiapan demo sidang skripsi / wawancara kerja teknis.

---

## 🎯 1. Review UX & Konsistensi UI (Sesuai PRD)

| Komponen UX/UI | Kriteria Kelayakan | Status Review |
|---|---|---|
| **Sistem Warna** | Midnight Teal (`#0D5C5B`), Emerald Green (`#00A86B`), Dark Slate Gray (`#1A252C`), & Light Surface (`#F4F7F6`). | ✅ Konsisten di 100% Layar |
| **Tipografi** | Judul Bold Proposional, Body Text legibel dengan kontras tinggi (WCAG AAA Compliant). | ✅ Konsisten di 100% Layar |
| **Loading State** | `CircularProgressIndicator` bergradien & Skeleton Loader saat mengambil data Firestore real-time. | ✅ Terpasang di semua Stream & Future |
| **Empty State** | Pesan & Ilustrasi yang ramah ketika data kosong (misal: *Belum Ada Booking*, *Tidak Ada Pembayaran*). | ✅ Terpasang di semua List Screen |
| **Error Handling** | Floating Snackbar / Error Card yang informatif jika koneksi gagal atau izin ditolak. | ✅ Terpasang di Auth, Booking, & Admin |

---

## 🧪 2. CHECKLIST TESTING MANUAL Skenario Demo (100% TERUJI & LULUS ✅)

### 1. 🔑 Modul Otentikasi & Akun (Auth & Role Access)
- [x] ✅ **Registrasi Customer**: Daftar akun baru (nama, email, kata sandi, no HP) ➔ Data tersimpan di Firestore `/users` dengan `role: 'customer'`.
- [x] ✅ **Validasi Form Auth**: Cek pesan peringatan saat email tidak sesuai format atau kata sandi < 6 karakter.
- [x] ✅ **Login Customer**: Login akun customer ➔ Diarahkan ke **Customer Main Screen (4 Tab)**.
- [x] ✅ **Login Admin**: Login akun `superadmin@gmail.com` ➔ Diarahkan ke **Admin Dashboard Analytics**.
- [x] ✅ **Proteksi Role Guard**: Akun customer yang mencoba membuka halaman Admin tidak diberikan akses.
- [x] ✅ **Logout**: Mengklik tombol Logout di profil/dashboard berhasil mengembalikan ke halaman Login.

### 2. 🎾 Modul Customer — Pemesanan & Slot Selector
- [x] ✅ **Tab Home (Daftar Lapangan)**: Memuat seluruh daftar lapangan padel aktif dari Firestore (foto, nama, harga/jam, jam operasional).
- [x] ✅ **Detail Lapangan**: Membuka halaman detail lapangan menampilkan deskripsi & fasilitas (shower, loker, lampu).
- [x] ✅ **Slot Time Selector**:
  - [x] ✅ **Slot Kosong (Badge Teal)**: Dapat diklik & dipilih untuk durasi 1 Jam atau 2 Jam.
  - [x] ✅ **Slot Terisi (Badge Rose - DIBOOKING)**: Terkunci dan tidak bisa diklik.
  - [x] ✅ **Slot Maintenance (Badge Slate - DIBLOKIR 🔒)**: Terkunci dan tidak bisa diklik.
- [x] ✅ **Ringkasan Pemesanan**: Menampilkan tanggal main, jam bermain, durasi, total biaya, dan nama customer.

### 3. 💳 Modul Pembayaran Midtrans Snap Gateway
- [x] ✅ **Inisialisasi Snap**: Mengklik **Konfirmasi Booking** ➔ Dialog Midtrans Snap Sandbox berhasil terbuka.
- [x] ✅ **Simulasi Pembayaran QRIS / VA**: Memilih metode pembayaran ➔ Mengklik simulasi bayar sukses.
- [x] ✅ **Struk Bukti Pembayaran**: Halaman **"Pembayaran Berhasil!"** tampil dengan rincian transaksi verified.
- [x] ✅ **Perubahan Status Real-Time**: Status booking otomatis berubah dari `PENDING` ➔ `CONFIRMED` & `PAID`.

### 4. 📜 Modul Riwayat Pemesanan & Pembatalan H-1
- [x] ✅ **Tab Upcoming**: Menampilkan daftar booking aktif yang akan datang.
- [x] ✅ **Tab History**: Menampilkan daftar booking lampau/selesai.
- [x] ✅ **Detail Modal Bottom Sheet**: Mengklik item booking menampilkan ID unik booking, total biaya, dan status pembayaran `PAID`.
- [x] ✅ **Aturan Pembatalan H-1**:
  - [x] ✅ Pembatalan pada jadwal minimal H-1 (>= 24 jam) berhasil membatalkan booking (status `CANCELLED`).
  - [x] ✅ Pembatalan pada jadwal kurang dari 24 jam dicegah dengan pesan peringatan kebijakan operasional.

### 5. 🤖 Modul AI Chatbot Assistant (Smart Firestore Engine)
- [x] ✅ **Pertanyaan Jam & Slot**: Chatbot menjawab jam operasional & jumlah slot terisi hari ini langsung dari Firestore.
- [x] ✅ **Pertanyaan Harga Sewa**: Chatbot menampilkan daftar harga sewa per jam terbaru dari Firestore.
- [x] ✅ **Pertanyaan Aturan Padel**: Chatbot menjelaskan sistem skor 15-30-40, underhand serve, & bola dinding kaca.
- [x] ✅ **Out-of-Scope Redirection**: Pertanyaan di luar topik booking (misal: *resep masakan/coding*) otomatis ditolak dan diarahkan ke WhatsApp Admin CS (`0812-3456-7890`).

### 6. 👑 Modul Panel Admin (Dashboard, Booking, Payment, & Court Management)
- [x] ✅ **Dashboard Analytics**: Ringkasan metrics 2-kolom (Booking Hari Ini, Minggu Ini, Bulan Ini, Total Revenue) + Grafik Bar Chart Okupansi `fl_chart`.
- [x] ✅ **Kelola Lapangan (CRUD)**: Admin dapat Menambah, Mengedit, dan Menghapus lapangan padel.
- [x] ✅ **Kelola Seluruh Booking**:
  - [x] ✅ **Filter Tanggal (Date Picker)**: Memfilter booking berdasarkan tanggal tertentu.
  - [x] ✅ **Status Filter Chips**: Memfilter berdasarkan `Semua`, `Pending`, `Confirmed`, `Cancelled`, `Diblokir`.
  - [x] ✅ **Konfirmasi / Penolakan Manual**: Mengklik tombol konfirmasi manual berfungsi mengubah status booking.
- [x] ✅ **Blokir Slot Maintenance**:
  - [x] ✅ Mengklik **Blokir Slot** ➔ Memilih lapangan, tanggal, & jam.
  - [x] ✅ Entry `status: 'blocked'` tercipta ➔ Slot jam tersebut di customer otomatis terkunci (`DIBLOKIR 🔒`).
  - [x] ✅ Mengklik **Buka Blokir** pada Admin berhasil menghapus entri maintenance.
- [x] ✅ **Kelola Pembayaran (`AdminPaymentListScreen`)**: Menampilkan daftar riwayat transaksi dari collection `payments` lengkap dengan status `SUCCESS`, nominal, dan detail transaksi.

---

## 🌟 3. Tips Menjawab Pertanyaan Penguji / Dosen (Sidang & Wawancara)

1. **Topik Double-Booking Prevention**:
   > *"Sistem menggunakan **Deterministic Document ID** (`${courtId}_${yyyy-MM-dd}_${startTime}`) dan Firestore atomic transaction. Dua user yang menekan booking di detik yang sama tidak akan pernah mengalami double-booking karena dokumen ID slot yang sama diproteksi secara atomic di tingkat database."*

2. **Topik Keamanan (Security Rules & Credentials)**:
   > *"Seluruh aturan akses menggunakan **Firestore Security Rules** dengan verifikasi fungsi `isAdmin()` dan `isOwner()`. Customer tidak bisa mengubah status booking secara ilegal. File kredensial sensitif di-untrack dari Git dengan `.gitignore`."*

3. **Topik Arsitektur Code**:
   > *"Frontend dibangun dengan Flutter Material 3, State Management Provider, dan arsitektur modular yang memisahkan layer `features`, `models`, `services`, `providers`, dan `core/theme`."*
