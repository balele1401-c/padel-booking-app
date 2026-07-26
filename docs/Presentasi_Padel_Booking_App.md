# 📊 Draf Presentasi PPT — Padel Court Booking & Management System

Dokumen ini berisi struktur slide presentasi PowerPoint (**10 Slide Profesional**) lengkap dengan judul, poin utama, rancangan visual slide, dan *speaker notes* (catatan pembicara) untuk **Sidang Skripsi**, **Wawancara Kerja**, maupun **Presentasi Penawaran Klien (B2B)**.

---

## 🖼️ SLIDE 1: Title Slide (Halaman Judul)
- **Judul Utama**: Padel Court Booking & Management System
- **Sub-Judul**: Solusi Terpadu Digitalisasi & Otomatisasi Pemesanan Lapangan Padel Berbasis Flutter & Firebase
- **Rancangan Visual**: Tema gelap (Midnight Teal `#0D5C5B` & Emerald Green `#00A86B`), logo raket padel, dan badge teknologi (Flutter | Firebase | Midtrans Snap).
- **Presenter**: [Nama Anda] — *Software Engineer / Project Lead*

---

## 🖼️ SLIDE 2: Problem Statement (Latar Belakang & Permasalahan)
- **Judul**: Tantangan Operasional Pemesanan Lapangan Olahraga
- **Poin Utama**:
  1. **Proses Manual via WA**: Pembatalan & konfirmasi via chat memakan waktu dan berisiko salah catat.
  2. **Risiko Double-Booking**: Dua pemain sering memesan slot waktu yang sama di jam sibuk.
  3. **Verifikasi Pembayaran Lambat**: Tim CS harus mengecek mutasi rekening satu per satu secara manual.
  4. **Kurangnya Laporan Finansial**: Pengelola sulit memantau grafik okupansi lapangan dan pendapatan harian secara akurat.
- **Speaker Notes**: 
  *"Banyak pengelola lapangan padel saat ini masih menggunakan pencatatan manual via WhatsApp. Hal ini tidak hanya membebani tim CS, tetapi juga sering memicu bentrok jadwal dan kebocoran transaksi keuangan."*

---

## 🖼️ SLIDE 3: The Solution (Solusi Sistem Digital Terpadu)
- **Judul**: Solusi Digital: Platform Pemesanan & Manajemen Otomatis
- **Poin Utama**:
  - **Aplikasi Customer**: Pengecekan slot real-time, pembayaran instan, & AI Chatbot 24/7.
  - **Panel Manajemen Admin**: Analytics dashboard, CRUD lapangan, & fitur blokir maintenance slot.
  - **Sistem Pembayaran Otomatis**: Integrasi Midtrans Snap (QRIS & Virtual Account).
- **Rancangan Visual**: Diagram alur 3 pilar utama (Customer App ➔ Payment Gateway ➔ Admin Dashboard).

---

## 🖼️ SLIDE 4: Customer App Features (Fitur Utama Customer)
- **Judul**: Kemudahan Akses & Transaksi Bagi Pelanggan
- **Poin Utama**:
  - **Interactive Slot Selector**: Indikator warna visual — Terisi (Merah), Maintenance (Abu-abu 🔒), Kosong (Teal).
  - **Flexibility Duration**: Pilihan durasi 1 Jam atau 2 Jam dengan kalkulasi harga otomatis.
  - **Digital Receipt & Struk**: Riwayat pemesanan lengkap dengan status lunas dan ID transaksi unik.
  - **Kebijakan Pembatalan H-1**: Fitur pembatalan otomatis maksimal 24 jam sebelum jadwal main.
- **Rancangan Visual**: Tangkapan layar (*Screenshot*) tampilan Home & Slot Selector pada HP.

---

## 🖼️ SLIDE 5: Admin Panel & Analytics (Fitur Utama Pengelola)
- **Judul**: Kontrol Operasional & Dashboard Finansial Admin
- **Poin Utama**:
  - **2-Column Metrics Summary**: Total booking (Hari Ini, Minggu Ini, Bulan Ini) & Total Pendapatan Terkonfirmasi.
  - **Bar Chart Okupansi Lapangan**: Visualisasi tingkat penggunaan lapangan berbasis `fl_chart`.
  - **Fitur Blokir Slot Maintenance**: Menutup slot lapangan tertentu untuk perawatan rumput/lampu.
  - **Filter Booking & Tanggal**: Penyaringan data berdasarkan Date Picker & Status Badges.
- **Rancangan Visual**: Screenshot tampilan Admin Dashboard & Kelola Booking di Browser.

---

## 🖼️ SLIDE 6: Advanced Technology Integration (Midtrans & AI Chatbot)
- **Judul**: Integrasi Gateway Pembayaran & AI Asisten Pintar
- **Poin Utama**:
  - **Midtrans Snap Integration**:
    - QRIS Instan (GoPay, OVO, Dana, ShopeePay, m-Banking).
    - Bank Virtual Account (BCA, Mandiri, BNI, BRI).
    - Status transaksi otomatis berubah dari `Pending` ➔ `Confirmed` & `Paid`.
  - **Smart Firestore AI Chatbot**:
    - Membaca data real-time ketersediaan slot & harga lapangan dari Firestore.
    - Menjawab pertanyaan operasional, metode bayar, & aturan padel.
    - Otomatis menolak pertanyaan di luar topik booking (Out-of-Scope Redirection ke WA CS).

---

## 🖼️ SLIDE 7: System Architecture & Tech Stack (Arsitektur Sistem)
- **Judul**: Arsitektur & Teknologi Terkini
- **Poin Utama**:
  - **Frontend**: Flutter Framework 3.27+ (Cross-Platform Mobile & Web).
  - **State Management**: Provider Architecture (Clean & Modular separation).
  - **Backend**: Firebase Cloud Firestore (NoSQL Real-Time Database) & Firebase Authentication.
  - **Theme System**: Material 3 dengan palet warna Midnight Teal & Emerald Green.
- **Rancangan Visual**: Diagram Arsitektur (Flutter App ➔ Provider ➔ Firebase Firestore & Midtrans).

---

## 🖼️ SLIDE 8: Security & Reliability (Keamanan Data & Anti Double-Booking)
- **Judul**: Keamanan Data & Pencegahan Double-Booking
- **Poin Utama**:
  - **Deterministic Document ID**: Format ID unik `${courtId}_${yyyy-MM-dd}_${startTime}` menjamin **0% risiko double-booking** di tingkat database atomic transaction.
  - **Firestore Security Rules**: Aturan keamanan berbasis role (`isAdmin()` vs `isOwner()`). Customer tidak bisa mengubah status booking secara ilegal.
  - **Kredensial Aman**: File sensitif di-untrack dari Git repository (`.gitignore`).

---

## 🖼️ SLIDE 9: Business Impact & ROI (Nilai Tambah Bisnis)
- **Judul**: Dampak Bisnis & Efisiensi Operasional
- **Poin Utama**:
  - ⏱️ **Efisiensi Waktu CS**: Mengurangi hingga 80% beban chat manual balasan WhatsApp.
  - 📈 **Peningkatan Pendapatan**: Pembayaran instan mencegah *No-Show* / booking palsu.
  - 📊 **Keputusan Berbasis Data**: Grafik okupansi membantu pengelola menentukan jam promo & jam *peak-hour*.
  - 🔒 **Transparansi Keuangan**: Laporan pendapatan harian terekam secara otomatis.

---

## 🖼️ SLIDE 10: Closing & Live Demo (Penutup & Sesi Sesi Q&A)
- **Judul**: Kesimpulan & Sesi Demo Aplikasi
- **Poin Utama**:
  - "Sistem ini siap digunakan secara langsung untuk meningkatkan pengalaman pelanggan dan efisiensi operasional venue padel Anda."
  - **Link Repository GitHub**: [github.com/balele1401-c/padel-booking-app](https://github.com/balele1401-c/padel-booking-app)
  - **Status Analisis**: `flutter analyze`: **`No issues found!`** (0 errors).
- **Call to Action**: *"Mari kita langsung coba simulasi pemesanan lapangan & pembayarannya secara live!"*

---

### 💡 Panduan Penggunaan:
Anda dapat menyalin struktur di atas langsung ke **Microsoft PowerPoint**, **Google Slides**, atau **Canva** dengan memilih template bertema *Modern Tech / Corporate Teal*!
