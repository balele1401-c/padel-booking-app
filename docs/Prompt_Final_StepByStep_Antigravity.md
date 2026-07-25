# Prompt Step-by-Step FINAL — Padel Court Booking App (Antigravity)

Kirim **satu per satu, berurutan**. Setelah tiap step, jalankan & tes dulu sebelum lanjut ke step berikutnya.

Sebelumnya, pastikan file `docs/PRD.md` (PRD lengkap yang sudah dibuat) sudah ada di root project sebelum mulai Step 1.

---

## STEP 0 — Setup Awal & Baca Konteks

```
Sebelum mulai, tolong baca file docs/PRD.md di root project ini. File itu berisi requirement lengkap aplikasi yang akan kita bangun: fitur, tech stack, struktur data, dan UI/UX guidelines.

Setelah kamu baca dan paham, ringkas dalam beberapa poin apa yang akan kita bangun, supaya saya bisa konfirmasi sebelum kita mulai coding.
```

---

## STEP 1 — Setup Project & Struktur Folder

```
Sesuai docs/PRD.md, buatkan project Flutter baru dengan:

1. Struktur folder feature-based berikut:
lib/
  core/constants/ (app_colors.dart, app_text_styles.dart, app_constants.dart)
  core/theme/ (app_theme.dart)
  core/utils/
  models/
  services/
  providers/
  features/auth/
  features/customer/ (home, booking, payment, history, profile)
  features/admin/ (dashboard, courts, bookings, payments)
  shared/widgets/

2. Isi core/constants/app_colors.dart sesuai skema warna di PRD (primary teal #0D9488, dst)
3. Isi core/theme/app_theme.dart dengan ThemeData Material 3 yang menggunakan warna & tipografi dari PRD
4. Tambahkan dependency yang dibutuhkan di pubspec.yaml: firebase_core, firebase_auth, cloud_firestore, provider (atau riverpod), intl, fl_chart
5. Jelaskan langkah setup Firebase yang perlu saya lakukan sendiri di Firebase Console (buat project, aktifkan Auth & Firestore, download config file, jalankan flutterfire configure)

Jangan buat fitur dulu, fokus setup dan struktur folder + tema dasar.
```

---

## STEP 2 — Data Model & Firestore Service

```
Lanjutkan dari project sebelumnya. Buatkan data model sesuai struktur Firestore di docs/PRD.md:

users/{userId}, courts/{courtId}, bookings/{bookingId}, payments/{paymentId}

Buatkan:
1. Model class Dart untuk User, Court, Booking, Payment (dengan fromFirestore/toFirestore)
2. Service class dasar untuk CRUD tiap collection di folder services/
3. Simpan sesuai struktur folder models/ dan services/

Setelah selesai, jelaskan cara saya cek koneksi Firestore-nya sudah benar atau belum.
```

---

## STEP 3 — Autentikasi (Customer & Admin)

```
Lanjutkan dari project sebelumnya. Buatkan fitur autentikasi:

1. Halaman Register (nama, email, password, no. HP) — role default "customer"
2. Halaman Login — setelah login, cek role dari Firestore, arahkan ke Home Customer atau Admin Dashboard
3. Halaman Reset Password
4. Logout function
5. State management untuk auth (current user, loading, error)

UI ikuti guideline di docs/PRD.md (warna teal, rounded input, label di atas field, dsb).

Jelaskan cara saya testing di emulator/device setelah selesai.
```

---

## STEP 4 — Home & Detail Lapangan (Customer)

```
Lanjutkan dari project sebelumnya. Buatkan:

1. Halaman Home — list card lapangan dari collection "courts" (foto, nama, harga, jam operasional), sesuai style card di PRD (rounded 12-16px, shadow tipis)
2. Halaman Detail Lapangan — foto besar di atas, info lengkap, tombol "Booking Sekarang" sticky di bawah
3. Loading state & empty state

Berikan juga contoh 2-3 dummy data lapangan yang bisa saya input manual ke Firestore Console untuk testing.
```

---

## STEP 5 — Booking Flow (Pilih Slot Real-time)

```
Lanjutkan dari project sebelumnya. Buatkan flow booking:

1. Date picker horizontal (7 hari ke depan) di halaman pilih slot
2. Grid slot jam — ambil data booking existing dari Firestore berdasarkan courtId + tanggal, slot yang sudah terisi otomatis disabled
3. Pilih durasi (1/2 jam), hitung otomatis jam selesai & total harga
4. Halaman ringkasan booking sebelum konfirmasi
5. Simpan ke collection "bookings" dengan status "pending" saat konfirmasi, gunakan Firestore transaction supaya tidak ada double booking

Jelaskan cara saya testing skenario 2 user booking slot yang sama secara bersamaan.
```

---

## STEP 6 — Integrasi Payment (Midtrans)

```
Lanjutkan dari project sebelumnya. Integrasikan Midtrans (Sandbox) ke flow booking:

1. Setelah konfirmasi booking, arahkan ke pembayaran Midtrans (QRIS, transfer bank, e-wallet)
2. Update status booking jadi "confirmed" kalau bayar sukses, simpan record ke collection "payments"
3. Halaman sukses/gagal setelah pembayaran

Jelaskan cara daftar akun Midtrans Sandbox, API key mana yang saya perlukan, dan cara menyimpannya dengan aman (jangan hardcode di kode).
```

---

## STEP 7 — Riwayat Booking & Profil

```
Lanjutkan dari project sebelumnya. Buatkan:

1. Halaman Riwayat Booking — tab Upcoming & History, status badge sesuai style di PRD (pill shape, warna per status)
2. Detail booking saat di-tap, fitur batalkan booking (minimal H-1 sebelum jadwal)
3. Halaman Profil — edit nama & no. HP, tombol Logout
4. Bottom navigation dengan 4 tab: Home, Riwayat, Chatbot (placeholder dulu), Profil

UI konsisten dengan style sebelumnya.
```

---

## STEP 8 — Admin: Kelola Lapangan

```
Lanjutkan dari project sebelumnya. Buatkan Admin Panel bagian kelola lapangan:

1. List semua lapangan (khusus admin)
2. Form tambah lapangan (nama, upload foto, harga per jam, jam buka-tutup)
3. Edit & hapus lapangan (dengan konfirmasi dialog)

Pastikan halaman ini hanya bisa diakses kalau role user "admin" (proteksi di level route/screen).
```

---

## STEP 9 — Admin: Kelola Booking & Pembayaran

```
Lanjutkan dari project sebelumnya. Buatkan:

1. List semua booking masuk, bisa difilter tanggal/status
2. Konfirmasi/tolak booking manual
3. Fitur blokir slot untuk maintenance
4. Riwayat semua transaksi pembayaran dengan status masing-masing
```

---

## STEP 10 — Admin Dashboard Ringkasan

```
Lanjutkan dari project sebelumnya. Buatkan halaman Dashboard sebagai halaman awal saat admin login:

1. Kartu ringkasan (grid 2 kolom): total booking hari ini/minggu ini/bulan ini, total pendapatan
2. Grafik okupansi lapangan sederhana pakai fl_chart (bar chart)

Sesuaikan warna dan style kartu dengan guideline di docs/PRD.md.
```

---

## STEP 11 — AI Chatbot Assistant

```
Lanjutkan dari project sebelumnya. Tambahkan fitur AI Chatbot assistant untuk customer:

1. Halaman chat sederhana (bubble chat, familiar seperti chat pada umumnya), pasang di tab "Chatbot" yang sudah jadi placeholder di Step 7
2. Integrasikan ke Claude API via Cloud Function sebagai proxy (jangan taruh API key di client)
3. Chatbot bisa jawab: ketersediaan slot (ambil data real dari Firestore berdasarkan pertanyaan user), harga sewa, jam operasional
4. Batasi scope: kalau pertanyaan di luar topik booking, chatbot arahkan user untuk hubungi admin langsung

Jelaskan cara saya setup Cloud Function dan menyimpan API key-nya dengan aman.
```

---

## STEP 12 — Firestore Security Rules

```
Lanjutkan dari project sebelumnya. Buatkan Firestore Security Rules yang aman:

1. Customer hanya bisa baca/tulis data booking miliknya sendiri (berdasarkan userId)
2. Customer tidak bisa mengubah field status atau payment_status secara langsung dari client
3. Hanya admin yang bisa CRUD collection "courts" dan mengubah status booking
4. Data user lain tidak bisa diakses/dibaca oleh customer selain miliknya sendiri

Jelaskan cara saya deploy rules ini ke Firebase Console.
```

---

## STEP 13 — Polish, Error Handling & Testing Akhir

```
Sekarang tolong bantu saya:

1. Review ulang seluruh flow aplikasi dari sisi UX — apakah ada langkah yang bisa disederhanakan
2. Pastikan semua halaman punya loading state, empty state, dan error state yang jelas
3. Cek konsistensi UI di semua halaman (warna, tipografi, spacing) sesuai docs/PRD.md
4. Berikan checklist lengkap hal-hal yang perlu saya test manual sebelum aplikasi ini didemokan (untuk wawancara kerja / sidang skripsi)
```

---

## STEP 14 — Siapkan untuk GitHub & Portofolio

```
Terakhir, tolong bantu saya:

1. Buatkan README.md yang profesional untuk repo GitHub — mencakup: deskripsi project, fitur utama, tech stack, screenshot placeholder, cara install & jalankan project, struktur folder
2. Buatkan .gitignore yang sesuai untuk project Flutter + Firebase (pastikan file config/API key sensitif tidak ikut ter-commit)
3. Beri saya saran singkat bagian mana dari project ini yang paling worth di-highlight saat wawancara kerja
```

---

### Catatan Pemakaian
- Total 15 step (0-14) — Step 0 wajib dulu biar Antigravity paham konteks dari PRD sebelum ngoding
- Tiap step = 1 sesi kerja, jangan gabung beberapa step dalam 1 prompt biar hasilnya gak terlalu berat dan susah di-debug
- Kalau di tengah jalan nemu bug, selesaikan dulu sebelum lanjut ke step berikutnya (bilang aja ke Antigravity: "ada error ini, tolong perbaiki: [paste error]")
- Step 11 (Chatbot) & Step 12 (Security Rules) jangan dilewatin — penting buat keamanan data, bukan cuma pemanis
