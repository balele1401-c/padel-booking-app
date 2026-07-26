# Panduan Implementasi & Deploy Firestore Security Rules 🛡️

Dokumen ini berisi panduan lengkap implementasi aturan keamanan (**Firestore Security Rules**) pada aplikasi Padel Booking App untuk melindungi data pengguna, mencegah manipulasi status transaksi, dan membatasi hak akses berdasarkan role (`admin` vs `customer`).

---

## 📌 Ringkasan Aturan Keamanan (Security Matrix)

| Collection | Role Customer | Role Admin | Ketentuan Khusus |
|---|---|---|---|
| `/users/{userId}` | Read & Edit dokumen sendiri | Read seluruh pengguna | Customer tidak bisa membaca data akun customer lain. |
| `/courts/{courtId}` | Read Publik (Semua orang) | Full CRUD (Tambah, Edit, Hapus) | Customer tidak bisa menambah atau mengubah data lapangan. |
| `/bookings/{bookingId}` | Read & Create booking milik sendiri | Full CRUD & Change Status | Customer **TIDAK BISA** mengubah status menjadi `confirmed` atau `completed` dari client. |
| `/payments/{paymentId}` | Read bukti pembayaran milik sendiri | Full Read & Management | Catatan transaksi terlindungi dari perubahan ilegal. |

---

## 🚀 Cara 1: Deploy Langsung via Firebase Console (Mudah & Cepat)

1. Buka [Firebase Console](https://console.firebase.google.com/) ➔ Pilih project **`padel-booking-app-1504d`**.
2. Di menu navigasi sebelah kiri, klik **Build** ➔ **Firestore Database**.
3. Pilih tab **Rules** di bagian atas halaman.
4. Salin (*copy*) seluruh isi dari file [`firestore.rules`](file:///d:/PENYIMPANAN%20TUGAS/Flutter/padel_booking_app/firestore.rules).
5. Tempelkan (*paste*) ke dalam editor Rules di Firebase Console.
6. Klik tombol **Publish** (Publikasikan) di sudut kanan atas.

---

## 💻 Cara 2: Deploy via Firebase CLI

Jika Anda menggunakan Firebase CLI dari terminal VS Code:

1. Pastikan file [`firestore.rules`](file:///d:/PENYIMPANAN%20TUGAS/Flutter/padel_booking_app/firestore.rules) berada di direktori utama project.
2. Jalankan perintah penggelaran berikut:
   ```bash
   firebase deploy --only firestore:rules
   ```

---

## 🧪 Verifikasi & Uji Coba Keamanan

1. **Uji Coba Customer**:
   - Login sebagai akun customer ➔ Buka **Home** ➔ Coba lakukan pemesanan slot.
   - Pemesanan akan berhasil disimpan dengan status awal `pending`.
   - Customer tidak akan bisa mengubah status transaksi customer lain atau mengubah harga sewa lapangan dari client.

2. **Uji Coba Admin**:
   - Login sebagai akun admin (`superadmin@gmail.com`) ➔ Buka **Kelola Booking**.
   - Admin dapat mengonfirmasi booking (`confirmed`), membatalkan, menandai selesai, atau memblokir slot maintenance (`blocked`).
