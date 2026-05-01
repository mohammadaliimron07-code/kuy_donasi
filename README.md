# KuyDonasi

KuyDonasi adalah platform donasi digital yang dibangun dengan prinsip transparansi dan akuntabilitas. Proyek ini dirancang untuk menerapkan Standar Akuntansi Keuangan (SAK) Entitas Non-Laba (ISAK 35) dalam seluruh aliran dana, sehingga setiap transaksi tercatat dengan jelas dan dapat diaudit.

## Fokus Pengembangan

| Minggu | Fokus | Aktivitas Utama | Status |
| --- | --- | --- | --- |
| Minggu 1 | Inisialisasi & Auth | Setup project, integrasi Git, UI login & register | 🟢 Progress |
| Minggu 2 | Core UI & Dasar Akuntansi | Dashboard, manajemen campaign, setup Chart of Accounts (COA) | ⚪ Todo |
| Minggu 3 | Transaksi & Jurnal | Fitur pembayaran, penjurnalan otomatis | ⚪ Todo |
| Minggu 4 | Reporting | Laporan posisi keuangan, laporan penghasilan komprehensif | ⚪ Todo |
| Minggu 5 | Testing & Fix | Uji coba fitur (UAT), perbaikan bug, finalisasi Git | ⚪ Todo |
| Minggu 6 | Deployment | Pendaftaran ke Google Play Store / App Store | ⚪ Todo |

## Fitur Utama

### A. Fitur Pengguna (Donatur)
- Multi-auth: Login melalui Email/Password atau Google.
- Campaign explorer: Menjelajahi kategori donasi seperti Bencana, Pendidikan, Panti.
- Payment integration: Dukungan transfer bank, e-wallet, QRIS.
- Tracking donasi: Riwayat donasi dan status penyaluran.

### B. Fitur Akuntansi (Admin/Yayasan)
- Automated journaling: Setiap donasi masuk dicatat otomatis sebagai Kas (Debit) dan Pendapatan Donasi (Kredit).
- General ledger: Buku besar otomatis untuk memantau saldo per akun.
- Financial reports:
  - Laporan Posisi Keuangan (Neraca).
  - Laporan Arus Kas.
  - Laporan Perubahan Aset Neto.

## Teknologi
- Framework: Flutter (Dart)
- State Management: Provider
- Version Control: Git
- UI Style: Clean, Modern, Elegant dengan Material 3

## Panduan Instalasi

```bash
git clone <url-repo>
cd kuydonasi
flutter pub get
flutter run
```

## Keterangan Saat Ini

- Fase awal telah dibangun: foundation aplikasi, tema Material 3, UI login/register, navigasi dasar, dan dashboard placeholder.
- Integrasi autentikasi masih berupa mock awal; selanjutnya akan dikembangkan dengan backend atau Firebase.

## Struktur Awal

- `lib/main.dart`: entry point aplikasi dan routing dasar.
- `lib/providers/auth_provider.dart`: state auth sederhana.
- `lib/screens/login_screen.dart`: UI login.
- `lib/screens/register_screen.dart`: UI pendaftaran.
- `lib/screens/dashboard_screen.dart`: ruang kerja dashboard awal.
