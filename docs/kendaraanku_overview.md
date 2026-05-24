# Kendaraanku

> **Aplikasi Pencatatan Kendaraan Pribadi — 100% Offline**
> SharingSession JagoFlutter · Free Event · Demo + Bonus Source Code
> Versi 1.0.0+1 · 24 Mei 2026 · Prepared by JagoFlutter Academy

---

## Daftar Isi

1. [Tentang Kendaraanku](#1-tentang-kendaraanku)
2. [Tech Stack](#2-tech-stack)
3. [Fitur Utama](#3-fitur-utama)
4. [Arsitektur Aplikasi](#4-arsitektur-aplikasi)
5. [Database Schema](#5-database-schema)
6. [Flow Fitur (User Journey)](#6-flow-fitur-user-journey)
7. [Cara Menjalankan Aplikasi](#7-cara-menjalankan-aplikasi)

---

## 1. Tentang Kendaraanku

Mobile app Flutter untuk mencatat seluruh aktivitas dan pengeluaran kendaraan pribadi — bensin, servis, dokumen, sampai scan nota — semua tersimpan lokal di device tanpa perlu internet.

| Highlight | Deskripsi |
|---|---|
| **Multi-Kendaraan** | Kelola beberapa kendaraan (motor, mobil, lainnya) sekaligus dalam satu aplikasi. |
| **100% Offline** | Tidak butuh internet. Semua data tersimpan lokal di device pengguna via SQLite. |
| **Scan Nota OCR** | Foto struk SPBU / bengkel, ML Kit baca otomatis (total, liter, tanggal, dll). |
| **Statistik & Grafik** | Lihat pengeluaran, konsumsi BBM rata-rata, dan tren bulanan via fl_chart. |
| **Dokumen Kendaraan** | Simpan STNK, BPKB, SIM, asuransi, dan jadwal pajak — lengkap dengan foto. |
| **Export Laporan** | Generate laporan PDF rapi atau CSV untuk dibuka di spreadsheet. |

> **Filosofi Teknis.** Source code sengaja dibuat *simpel dan straightforward*: tanpa DI framework, tanpa router declarative, tanpa abstraksi berlebihan. Tujuannya supaya peserta sharing session bisa langsung baca, paham, dan modifikasi tanpa harus belajar 5 library tambahan dulu.

---

## 2. Tech Stack

Stack yang dipakai sesuai standar JagoFlutter — pragmatis dan production-ready.

| Layer | Library | Keterangan |
|---|---|---|
| Framework | `Flutter 3.x` (sdk ^3.11.5) | Cross-platform Android & iOS |
| State Management | `flutter_bloc` · `freezed` · `dartz` | BLoC pattern standar JagoFlutter |
| Local Database | `sqflite` · `path` | SQLite wrapper — vehicles, fuel_logs, service_logs, dokumen |
| Key-Value Storage | `shared_preferences` | Session login & flag onboarding |
| Camera & Gambar | `image_picker` · `flutter_image_compress` | Ambil foto, compress 1280px @ 80% sebelum simpan |
| OCR Nota | `google_mlkit_text_recognition` | Baca total, liter, tanggal dari struk bengkel/SPBU |
| Charts | `fl_chart` | Grafik pengeluaran & konsumsi BBM bulanan |
| Export PDF | `pdf` · `printing` | Generate laporan PDF rapi dari data lokal |
| Export CSV | `csv` | Data tabular untuk spreadsheet |
| Navigation | Navigator v1 (push/pop) | Tidak pakai go_router — simpel & mudah dipahami |
| Path & Storage | `path_provider` | Akses app documents directory untuk foto |
| Typography | `google_fonts` (Plus Jakarta Sans) | Numeric tabular figures, weight 400/500/700/800 |
| Lokalisasi | `intl` (id_ID) | Format tanggal & rupiah Indonesia |

### Yang Sengaja TIDAK Dipakai

| Library | Alasan |
|---|---|
| **go_router / auto_route** | `Navigator.push/pop` lebih mudah dipahami pemula. Tidak ada kebutuhan deep linking. |
| **get_it + injectable** | DI manual via constructor sudah cukup untuk skala aplikasi ini. |
| **Hive / Isar** | SharedPreferences cukup untuk settings ringan. Data relasional konsisten pakai SQLite. |
| **Riverpod / Provider** | Konsisten pakai BLoC sebagai state management utama di seluruh kurikulum JagoFlutter. |

---

## 3. Fitur Utama

Aplikasi punya 4 tab utama (Home · Service · Docs · Profile) plus fitur scan nota dan export.

### Authentication (Lokal)
- **Splash → Onboarding** (first time) **→ Register / Login** — semua lokal, password di-hash & simpan di tabel `users`.
- Session disimpan di SharedPreferences. Logout = clear flag.
- Edit profil + ganti foto profil dari kamera/galeri.

### Tab 1 · Home (Dashboard)
- **Hero Card** kendaraan aktif: plat, odometer, kapasitas tangki.
- **Statistik bulan ini**: total pengeluaran BBM, total servis, rata-rata konsumsi (km/liter).
- **Chart fl_chart**: tren pengeluaran 6 bulan terakhir.
- **Switch kendaraan** aktif lewat selector di atas. Riwayat BBM & servis terbaru di bawah.

### Tab 2 · Service (Servis & BBM)
- **Catat BBM**: tanggal, odometer, liter, harga/liter, total auto-calc, jenis BBM, SPBU, full-tank flag, foto struk.
- **Catat Servis**: jenis servis (10 kategori default), bengkel, biaya, kwitansi, reminder odometer/tanggal servis berikutnya.
- **Scan nota** dari halaman tambah — auto-fill field dari ML Kit OCR.

### Tab 3 · Docs (Dokumen Kendaraan)
- **5 jenis dokumen**: STNK, BPKB, SIM, Asuransi, Pajak.
- Simpan nomor, tanggal terbit, tanggal expired, foto dokumen, catatan.
- Empty state & reminder untuk dokumen yang akan jatuh tempo.

### Tab 4 · Profile
- Edit Profile · Theme · Language · Security · Backup · Help · About · T&C · Privacy.
- **Export** data ke **PDF** (laporan rapi via package `pdf`) atau **CSV** (spreadsheet-ready).

---

## 4. Arsitektur Aplikasi

2 layer simpel: **Data → Presentation**. Tidak ada domain layer terpisah, tidak ada use case, tidak ada repository interface.

### Folder Structure

```
lib/
├── data/
│   ├── models/              # Freezed models (vehicle, fuel_log, service_log, ...)
│   ├── repositories/        # SQLite query logic (5 repos)
│   ├── local/               # auth_local_datasource (SharedPreferences)
│   └── database_helper.dart # singleton DB helper
├── presentation/
│   ├── auth/                # splash · onboarding · login · register
│   ├── home/                # dashboard + main_navigation
│   ├── fuel/                # fuel page + add fuel
│   ├── service/             # service page + add service
│   ├── vehicle/             # add · edit · detail vehicle
│   ├── docs/                # list dokumen + add document
│   ├── scan/                # OCR scan receipt page
│   ├── profile/             # 10 menu profil
│   ├── settings/            # export PDF/CSV
│   ├── notifications/       # notifications page
│   └── blocs/               # vehicle, fuel_log, service_log, dashboard, vehicle_document
├── core/
│   ├── constants/           # colors, strings, enums
│   ├── components/          # reusable widgets (bottom_nav, dll)
│   ├── extensions/          # context, int, string, datetime
│   ├── utils/               # formatters, image helper
│   └── theme.dart           # light & dark theme
└── main.dart
```

### Alur Data (Linear & Mudah Di-trace)

1. **Page dispatch Event ke BLoC** — User tap tombol di UI → `context.read<FuelLogBloc>().add(AddFuelLog(...))`
2. **BLoC panggil Repository** — Bloc langsung instantiate Repository via constructor (no DI framework)
3. **Repository execute query SQLite** — Via `DatabaseHelper.getInstance()` singleton — pure CRUD
4. **BLoC emit State baru** — State pakai Freezed sealed class (loading / loaded / error)
5. **BlocBuilder rebuild UI** — UI react ke perubahan state — `Navigator.pop(true)` untuk refresh parent

---

## 5. Database Schema

SQLite via `sqflite`. 6 tabel utama, semua relasional via foreign key ke `vehicles.id` atau `users.id`.

### `users`
| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | INTEGER PK | Auto increment |
| `name` · `email` · `password` | TEXT | Email unique, password di-hash |
| `image_path` | TEXT? | Foto profil (nullable) |
| `created_at` · `updated_at` | TEXT | ISO 8601 |

### `vehicles`
| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` · `user_id` | INTEGER | FK ke `users` |
| `name` · `type` · `brand` · `model` | TEXT | Identitas kendaraan |
| `year` · `plate_number` · `color` | INT / TEXT | Detail registrasi |
| `initial_odometer` · `tank_capacity` | REAL | Spesifikasi awal |
| `fuel_type` · `is_active` · `notes` | TEXT / INT | Pertalite default, soft archive |
| `image_path` | TEXT? | Foto kendaraan |

### `fuel_logs`
| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` · `vehicle_id` | INTEGER | FK ke `vehicles` |
| `date` · `odometer` · `liters` | TEXT / REAL | Data utama isi BBM |
| `price_per_liter` · `total_cost` | REAL | Total auto-calculate |
| `fuel_type` · `station_name` · `is_full_tank` | TEXT / INT | Detail SPBU |
| `receipt_image_path` | TEXT? | Foto struk SPBU |

### `service_logs`
| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` · `vehicle_id` | INTEGER | FK ke `vehicles` |
| `date` · `odometer` · `service_type` | TEXT / REAL | Kategori: oli, ban, tune-up, dll |
| `description` · `cost` · `workshop_name` | TEXT / REAL | Detail pekerjaan |
| `next_service_odometer` · `next_service_date` | REAL? / TEXT? | Reminder servis berikutnya |
| `receipt_image_path` | TEXT? | Foto kwitansi bengkel |

### `vehicle_documents`
| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` · `vehicle_id` | INTEGER | FK ke `vehicles` |
| `document_type` · `document_number` | TEXT | STNK / BPKB / SIM / Asuransi / Pajak |
| `issue_date` · `expiry_date` | TEXT? | Tanggal terbit & kadaluarsa |
| `image_path` · `notes` | TEXT? | Foto dokumen + catatan |

### `expense_categories` *(seeded otomatis)*

10 kategori default sudah di-insert otomatis saat `onCreate`:
Ganti Oli Mesin · Ganti Oli Gardan · Ganti Ban · Tune Up / Servis Rutin · Ganti Aki · Ganti Kampas Rem · Ganti V-Belt · Servis AC · Perpanjang STNK / Pajak · Lain-lain.

---

## 6. Flow Fitur (User Journey)

Flow utama yang akan didemo di sharing session — dari pertama install sampai bisa export laporan.

### Flow A · First Time User → Catat BBM Pertama

1. **Splash Page** — Cek flag `isFirstTime` & `isLoggedIn` di SharedPreferences (delay 2 detik).
2. **Onboarding** — 3 slide intro fitur. Setelah selesai, set `isFirstTime = false`.
3. **Register** — Form name + email + password + checkbox T&C. Insert ke tabel `users`, set session.
4. **Add Vehicle** — User wajib tambah kendaraan pertama — nama, plat, brand, tipe BBM, odometer awal, foto.
5. **Home (Dashboard)** — Hero card kendaraan + statistik bulan ini + chart 6 bulan. Empty state karena belum ada catatan.
6. **FAB → Catat BBM** — Pilih tanggal, isi odometer, liter, harga/liter. Total auto-calc realtime.
7. **Optional: Scan Nota** — Tap "Scan Struk" → buka kamera → ML Kit OCR baca total, liter, tanggal → auto-fill form.
8. **Simpan** — Foto di-compress 1280px@80%, save ke app dir. Row insert ke `fuel_logs`. Pop back ke Home, dashboard auto-refresh.

### Flow B · Catat Servis + Set Reminder

1. **Tab Service → FAB Add** — Pilih jenis servis dari 10 kategori default (Ganti Oli, Tune Up, dll).
2. **Isi Detail Servis** — Tanggal, odometer, bengkel, biaya, deskripsi. Optional foto kwitansi.
3. **Set Reminder Servis Berikutnya** — Isi `next_service_odometer` (mis. odometer sekarang + 2.500 km) atau tanggal.
4. **Save** — Insert ke `service_logs`. Reminder muncul di dashboard saat odometer/tanggal mendekati target.

### Flow C · Tambah Dokumen Kendaraan

1. **Tab Docs → Pilih Tipe** — STNK / BPKB / SIM / Asuransi / Pajak.
2. **Isi Form Dokumen** — Nomor dokumen, tanggal terbit, tanggal expired, foto dokumen.
3. **Save** — Insert ke `vehicle_documents`. Card dokumen muncul di Docs tab dengan badge expired/akan jatuh tempo.

### Flow D · Export Laporan PDF/CSV

1. **Profile → Export** — Pilih kendaraan, range tanggal, format (PDF / CSV).
2. **Generate** — Repository query semua `fuel_logs` & `service_logs` dalam range → package `pdf` bikin dokumen rapi atau `csv` bikin spreadsheet.
3. **Share / Print** — Package `printing` buka share sheet — kirim via WhatsApp / email / save ke Files.

---

## 7. Cara Menjalankan Aplikasi

Langkah-langkah dari clone repo sampai aplikasi jalan di device fisik / emulator.

### Prasyarat
- **Flutter SDK 3.11.5** atau lebih baru — cek dengan `flutter --version`
- **Android Studio** + Android SDK + emulator, ATAU **Xcode** + iOS Simulator (macOS)
- **Device fisik** dengan USB debugging aktif (opsional, recommended untuk test kamera/OCR)
- **JDK 17** untuk Android build

### Langkah 1 · Clone & Install Dependencies

```bash
# Clone repo
git clone <repo-url> flutter_kendaraanku_app
cd flutter_kendaraanku_app

# Install dependencies
flutter pub get

# Cek health Flutter — pastikan semua centang hijau
flutter doctor -v
```

### Langkah 2 · Generate Freezed Code

```bash
# Generate file *.freezed.dart untuk semua model & state
dart run build_runner build --delete-conflicting-outputs
```

### Langkah 3 · (Opsional) Regenerate Icon & Splash

```bash
# Hanya jika ganti file di assets/branding/
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

### Langkah 4 · Jalankan Aplikasi

```bash
# Cek device yang ter-connect
flutter devices

# Run di device default (debug mode)
flutter run

# Run di device spesifik
flutter run -d <device-id>

# Hot reload: tekan r di terminal. Hot restart: tekan R
```

### Langkah 5 · Build Release (Android)

```bash
# Setup keystore — lihat docs/RELEASE.md untuk detail
cp android/key.properties.template android/key.properties
# Edit android/key.properties dengan path & password keystore

# Build APK (untuk testing langsung)
flutter build apk --release

# Build App Bundle (untuk upload ke Play Store)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

> **Tips Demo.** Untuk demo sharing session, jalankan `flutter run --release` di device fisik supaya animasi smooth & performance OCR ML Kit terasa beneran. Debug mode bisa lag saat scan nota.

### Troubleshooting Singkat

| Masalah | Solusi |
|---|---|
| **Error: file `.freezed.dart` not found** | Jalankan ulang `dart run build_runner build --delete-conflicting-outputs` |
| **OCR crash di release build** | Pastikan ProGuard rule di `android/app/proguard-rules.pro` sudah include rule ML Kit. |
| **Database error setelah update model** | Uninstall app dari device, atau bump version di `database_helper.dart` & tambah migration di `_onUpgrade`. |
| **Foto tidak muncul setelah restart** | Cek `image_path` di DB pakai absolute path dari `path_provider`. Path simulator bisa berubah saat hot restart. |

---

**Kendaraanku** · SharingSession JagoFlutter Free Event · 24 Mei 2026
Demo Program + Bonus Source Code · Prepared by JagoFlutter Academy
