# PRD Lengkap — Padel Court Booking App

## 1. Overview

**Nama Project:** Padel Court Booking App
**Platform:** Mobile App (Flutter) — Customer & Admin
**Tujuan:** Memudahkan customer booking lapangan padel secara online (cek jadwal, booking, bayar) dan memudahkan admin/pemilik lapangan mengelola jadwal, booking, dan pembayaran tanpa proses manual.

**Konteks penggunaan:** Portofolio kerja (Flutter Developer) & berpotensi jadi project skripsi.

**Prinsip desain:** Sederhana tapi profesional — fitur inti solid dan rapi, tidak over-engineered, mudah didemokan.

---

## 2. Target Pengguna

| Role | Deskripsi |
|---|---|
| **Customer** | Orang yang mau booking lapangan padel |
| **Admin/Owner** | Pemilik/pengelola tempat penyewaan lapangan padel |

---

## 3. Tech Stack

| Layer | Teknologi |
|---|---|
| Frontend Mobile | Flutter (Dart) |
| Backend & Database | Firebase (Firestore, Authentication, Cloud Functions) |
| Payment Gateway | Midtrans (Sandbox untuk development) |
| State Management | Provider / Riverpod |
| Notifikasi | Firebase Cloud Messaging |
| AI Chatbot (opsional, fase 2) | Claude/OpenAI API via Cloud Function proxy |

---

## 4. Fitur — Customer App

### 4.1 Autentikasi
- Register/Login (email & password)
- Reset password

### 4.2 Home
- List lapangan yang tersedia (nama, foto, harga per jam, jam operasional)

### 4.3 Booking
- Pilih lapangan → pilih tanggal → lihat slot jam tersedia (real-time) → pilih durasi → ringkasan → konfirmasi

### 4.4 Pembayaran
- Integrasi Midtrans (QRIS, transfer bank, e-wallet)
- Status: pending, success, failed

### 4.5 Riwayat Booking
- Tab Upcoming & History, status jelas, fitur batalkan booking (minimal H-1)

### 4.6 Profil
- Edit nama & no. HP, logout

### 4.7 AI Chatbot Assistant (fase 2, nice-to-have)
- Tanya ketersediaan slot & harga, berbasis data real dari Firestore

---

## 5. Fitur — Admin Panel

### 5.1 Autentikasi Admin (role-based)
### 5.2 Kelola Lapangan — CRUD data lapangan
### 5.3 Kelola Booking — lihat, konfirmasi/tolak, blokir slot maintenance
### 5.4 Kelola Pembayaran — riwayat & status transaksi
### 5.5 Dashboard Ringkasan — total booking & pendapatan, grafik okupansi

---

## 6. Struktur Data Firestore

```
users/{userId}: nama, email, no_hp, role (customer/admin)
courts/{courtId}: nama, foto, harga_per_jam, jam_buka, jam_tutup
bookings/{bookingId}: userId, courtId, tanggal, jam_mulai, jam_selesai,
                       status (pending/confirmed/completed/cancelled),
                       total_harga, payment_status, payment_id
payments/{paymentId}: bookingId, metode, status, jumlah, waktu_transaksi
```

---

## 7. Alur Utama (User Flow)

1. Customer buka app → lihat list lapangan
2. Pilih lapangan → pilih tanggal & jam kosong
3. Konfirmasi booking → bayar (Midtrans)
4. Bayar sukses → status booking "confirmed"
5. Customer dapat notifikasi & bisa lihat di riwayat
6. Admin monitor semua booking & pembayaran lewat dashboard

---

## 8. UI/UX Guidelines

### 8.1 Prinsip Desain
- **Clean & minimal** — hindari elemen visual yang tidak perlu, prioritaskan keterbacaan dan kemudahan alur booking
- **Konsisten** — komponen (button, card, input) pakai style yang sama di seluruh app
- **Mobile-first** — semua layout dioptimalkan untuk layar HP, touch-friendly (target tap area minimal 44x44px)
- **Feedback jelas** — setiap aksi (booking, bayar, submit) ada loading state, success state, dan error state yang jelas

### 8.2 Skema Warna

| Elemen | Warna | Hex |
|---|---|---|
| Primary (aksen utama) | Teal/Emerald | `#0D9488` |
| Primary Dark (hover/pressed) | Teal gelap | `#0F766E` |
| Background | Putih/abu sangat terang | `#FAFAFA` |
| Surface (card) | Putih | `#FFFFFF` |
| Text Primary | Abu gelap | `#1F2937` |
| Text Secondary | Abu medium | `#6B7280` |
| Success | Hijau | `#16A34A` |
| Warning/Pending | Kuning/Oranye | `#F59E0B` |
| Error/Failed | Merah | `#DC2626` |
| Border/Divider | Abu muda | `#E5E7EB` |

> Catatan: skema ini light mode. Kalau nanti mau dark mode, tinggal invert background/surface (`#111827` / `#1F2937`) dan tetap pertahankan warna aksen teal supaya identitas visual konsisten.

### 8.3 Tipografi
- **Font:** Inter (atau font default Material 3 — Roboto — kalau ingin lebih simpel)
- **Heading (judul halaman):** 20-24px, semi-bold
- **Subheading (judul section/card):** 16-18px, medium
- **Body text:** 14px, regular
- **Caption/label kecil:** 12px, regular, warna Text Secondary

### 8.4 Komponen UI Utama

**Button**
- Primary button: background teal, teks putih, rounded corner 8-12px
- Secondary/outline button: border teal, teks teal, background transparan
- Disabled state: abu-abu, tidak bisa ditekan

**Card (lapangan, booking item)**
- Rounded corner 12-16px
- Subtle shadow (elevation rendah, jangan terlalu tebal)
- Padding konsisten 12-16px

**Input Field**
- Border rounded 8px, warna border abu muda, jadi teal saat fokus
- Label di atas field (bukan placeholder doang), biar jelas saat sudah terisi
- Error state: border merah + teks error kecil di bawah field

**Status Badge** (dipakai di riwayat booking & admin)
- Pending: background kuning muda, teks oranye
- Confirmed/Success: background hijau muda, teks hijau
- Cancelled/Failed: background merah muda, teks merah
- Bentuk pill (rounded penuh), teks kecil (11-12px), bold

**Bottom Navigation (Customer)**
- 4 tab: Home, Booking/Riwayat, Chatbot (fase 2), Profil
- Icon + label, warna aktif teal, warna tidak aktif abu-abu

**Navigasi Admin**
- Bisa pakai Drawer (side menu) atau Bottom Navigation sederhana: Dashboard, Lapangan, Booking, Pembayaran

### 8.5 Layout Per Halaman (garis besar)

**Home (Customer)**
- App bar dengan nama app/logo
- List card lapangan (1 kolom, full width, foto di atas — info di bawah)

**Detail Lapangan**
- Foto besar di atas (carousel kalau ada beberapa foto)
- Info: nama, harga per jam, jam operasional
- Tombol "Booking Sekarang" sticky di bawah layar

**Booking — Pilih Slot**
- Date picker horizontal scroll (7 hari ke depan) di atas
- Grid slot jam di bawahnya — slot tersedia (outline teal), slot terisi (abu-abu, disabled)

**Ringkasan & Konfirmasi**
- Card ringkasan (lapangan, tanggal, jam, durasi, total harga) di tengah
- Tombol "Bayar Sekarang" full-width di bawah

**Riwayat Booking**
- Tab switcher (Upcoming / History) di atas
- List card booking dengan status badge di pojok kanan atas tiap card

**Dashboard Admin**
- Bagian atas: 3-4 kartu ringkasan angka (total booking, pendapatan, dst) dalam grid 2 kolom
- Bagian bawah: grafik okupansi sederhana (bar chart)

### 8.6 Ikon
- Gunakan Material Icons bawaan Flutter (`Icons.*`) atau package `lucide_icons`/`phosphor_flutter` untuk tampilan lebih modern
- Konsisten pakai satu icon set saja di seluruh app, jangan campur

---

## 9. Non-Functional Requirements
- **Reliability:** Slot yang sudah dibooking tidak boleh bisa dibooking ganda (validasi real-time via Firestore transaction)
- **Security:** Role-based access, data pembayaran tidak disimpan mentah (pakai payment gateway resmi)
- **Performance:** Loading list lapangan & slot jadwal cepat (< 2 detik)
- **Usability:** Alur booking maksimal 4-5 langkah dari buka app sampai bayar
- **Accessibility:** Kontras warna teks-background memenuhi standar minimal (rasio 4.5:1 untuk teks normal)

---

## 10. Scope

**MVP (wajib ada):**
- Autentikasi customer & admin
- List lapangan & booking dengan cek slot real-time
- Integrasi payment gateway
- Riwayat booking
- Admin: kelola lapangan, booking, pembayaran, dashboard ringkasan

**Nice-to-have (fase 2):**
- AI Chatbot assistant
- Notifikasi push (reminder H-1)
- Rating/review lapangan
- Dark mode

---

## 11. Success Criteria
- Customer bisa booking dari awal sampai bayar tanpa error, end-to-end
- Admin bisa pantau semua booking & pendapatan dari 1 dashboard
- Tidak ada bentrok slot (double booking)
- UI konsisten mengikuti guideline di atas (warna, tipografi, komponen)
- Bisa didemokan penuh untuk keperluan wawancara kerja / sidang skripsi
