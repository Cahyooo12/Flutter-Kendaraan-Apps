# KendaraanKu

Aplikasi pencatatan kendaraan pribadi **100% offline** untuk mencatat pengisian BBM, riwayat servis, dokumen kendaraan, dan pengingat masa berlaku — lengkap dengan OCR struk, ekspor laporan, backup database, dan notifikasi lokal.

---

## Fitur

| Modul | Highlight |
|---|---|
| Kendaraan | Tambah/edit/detail, multi-kendaraan per user, foto kendaraan |
| BBM | Catat pengisian, harga/liter otomatis, ringkasan konsumsi & total biaya |
| Servis | Riwayat per kategori (oli, ban, tune-up, dll), reminder servis berikutnya |
| Dokumen | STNK / BPKB / SIM / Pajak / Asuransi dengan masa berlaku |
| Scan Nota | OCR via Google ML Kit, parse total/tanggal/bengkel otomatis ke form |
| Notifikasi | Pengingat lokal H-7, H-1, H-0 untuk servis & masa berlaku dokumen |
| Backup | Salinan database `.db` lokal, restore, kirim ke WhatsApp/Drive via share sheet |
| Ekspor | Laporan PDF & CSV untuk arsip pribadi |
| Profil | Tema, bahasa, keamanan, bantuan, T&C, privasi |

---

## Tech Stack

- **Flutter 3.x** + Dart `^3.11.5`
- **State**: `flutter_bloc`
- **Model**: `freezed_annotation` + `dartz` (Either)
- **DB**: `sqflite` (SQLite) + `shared_preferences`
- **Chart**: `fl_chart`
- **Ekspor**: `pdf`, `printing`, `csv`
- **Foto**: `image_picker`, `flutter_image_compress`
- **OCR**: `google_mlkit_text_recognition`
- **Share**: `share_plus`
- **Notifikasi**: `flutter_local_notifications`, `timezone`, `flutter_timezone`, `permission_handler`
- **Routing**: Navigator v1 (push/pop) — TANPA router library
- **Font**: Plus Jakarta Sans via `google_fonts`

---

## Arsitektur

Pendekatan **2-layer simpel**: data → presentation.

```
lib/
├── core/
│   ├── components/        # widget reusable (buttons, cards, chips)
│   ├── constants/         # colors, styles, strings, enum
│   ├── extensions/        # context / int / string helpers
│   ├── services/
│   │   └── notification_service.dart   # singleton scheduler local notif
│   ├── utils/             # formatters, export_helper, receipt_parser, image_helper
│   └── theme.dart
├── data/
│   ├── database_helper.dart            # singleton sqflite
│   ├── local/                          # SharedPreferences datasource (auth)
│   ├── models/                         # plain Dart models (toMap/fromMap)
│   └── repositories/                   # query SQLite, return Either<String, T>
└── presentation/
    ├── auth/    fuel/    service/    docs/
    ├── home/    profile/ vehicle/    scan/
    ├── settings/  notifications/
    └── blocs/                          # BLoC per fitur (event + state + bloc)
```

**Konvensi**:
- DI manual via constructor (NO `get_it`).
- BLoC: `Event` → `Bloc` → `State`.
- Repository return `Either<String, T>` — error message di kiri, data di kanan.
- Foto disimpan di app directory, di-compress 1280px / 80% sebelum simpan.

---

## Database

4 tabel utama + 1 tabel auth lokal:

| Tabel | Isi |
|---|---|
| `users` | Auth lokal (offline-only, satu user per device biasanya) |
| `vehicles` | Master kendaraan, link `user_id` |
| `fuel_logs` | Catatan pengisian BBM, link `vehicle_id` |
| `service_logs` | Catatan servis + `next_service_date` untuk reminder |
| `vehicle_documents` | STNK/Pajak/dll + `expiry_date` untuk reminder |
| `expense_categories` | Kategori pengeluaran (opsional) |

DB path: `getDatabasesPath()/kendaraanku.db`.

---

## Logic Notifikasi Lokal

### Kapan dijadwalkan
Tiga slot otomatis dijadwalkan setiap kali user **menyimpan / mengubah** record yang punya tanggal jatuh tempo:
- **H-7** (7 hari sebelum)
- **H-1** (sehari sebelum)
- **H-0** (hari H, pagi)

Semuanya fire **jam 09:00 waktu lokal device**. Slot yang sudah lewat saat scheduling **di-skip otomatis** (mis. user catat dokumen yang habis 3 hari lagi → cuma H-1 & H-0 yang masuk antrian).

Triggernya hidup di BLoC:
- `ServiceLogBloc._onAdd / _onUpdate` → schedule pakai `next_service_date`
- `ServiceLogBloc._onDelete` → cancel set notif untuk id itu
- `VehicleDocumentBloc._onAdd / _onUpdate` → schedule pakai `expiry_date`
- `VehicleDocumentBloc._onDelete` → cancel

### ID namespacing (anti-collision)
Notification ID harus int32 dan stable agar bisa di-cancel/reschedule. Format:

```
service log     : 10_000_000 + (serviceId * 10) + dayCode
vehicle document: 20_000_000 + (documentId * 10) + dayCode
```

`dayCode` ∈ `{0, 1, 7}`. Kapasitas ~1jt record per kategori, tidak akan collide dalam pemakaian normal.

### Android scheduling mode
Pakai `AndroidScheduleMode.inexactAllowWhileIdle` → **tidak perlu** runtime permission `SCHEDULE_EXACT_ALARM` (Android 12+). Toleransi waktu ±beberapa menit, sangat memadai untuk reminder dokumen/servis.

Boot receiver `ScheduledNotificationBootReceiver` didaftarkan di `AndroidManifest.xml` agar antrian notif survive restart device.

### In-app reminder list
Halaman `NotificationsPage` menggabungkan reminder yang sama:
- Service log dengan `next_service_date` mendatang
- Document dengan `expiry_date` dalam 30 hari ke depan

Urut berdasarkan `daysUntil` ascending. Card paling urgent (≤7 hari) di-tint merah (`tintRose`), sisanya amber.

---

## Logic Backup & Restore

| Aksi | Yang terjadi |
|---|---|
| **Backup** | Copy `kendaraanku.db` → `getApplicationDocumentsDirectory()/kendaraanku_backup_<timestamp>.db` |
| **Restore** | Copy file backup terpilih → menimpa `kendaraanku.db`. Snackbar minta user restart app (sqflite instance lama masih open) |
| **Kirim** | `Share.shareXFiles([XFile(path, mimeType: 'application/octet-stream')])` → buka share sheet → pilih WhatsApp/Drive/Gmail/Telegram |
| **Hapus** | `File.delete()` lalu refresh list |

Catatan: backup hanya berisi file `.db` mentah. Foto pendukung (struk, foto kendaraan) **belum** ter-include — file di app directory.

---

## Setup

```bash
flutter pub get
flutter run
```

Hot-restart (bukan hot-reload) **wajib** setelah pull perubahan native plugin (notification / ML Kit).

### Generate launcher icon & splash

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## Permission Android

Sudah didaftarkan di `android/app/src/main/AndroidManifest.xml`:

| Permission | Untuk |
|---|---|
| `CAMERA` | Foto kendaraan & scan nota |
| `READ_MEDIA_IMAGES` (Android 13+) | Pick foto dari galeri |
| `READ_EXTERNAL_STORAGE` (≤ Android 12) | Legacy image picker |
| `POST_NOTIFICATIONS` (Android 13+) | Notifikasi lokal |
| `RECEIVE_BOOT_COMPLETED` | Reschedule notif setelah reboot |
| `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM` | (defensive, kalau suatu saat ganti ke mode exact) |

Permission notifikasi direquest di `MainNavigationPage.initState()` (sekali waktu post-login).

---

## Navigation

Pakai **Navigator v1** murni. Aturan penting:
- `MainNavigationPage` di-wrap `PopScope(canPop: false, ...)`. Android back dari tab non-Home → balik ke tab Home. Back dari Home → `SystemNavigator.pop()` (minimize, bukan blank).
- Tombol back custom di page yang **bisa jadi route root** (Login, Register) di-guard dengan `Navigator.canPop(context)` — kalau false, tombol disembunyikan.
- Page yang dipush DI-WRAP `BlocProvider.value(value: existingBloc, child: ...)` agar bloc dari parent tetap accessible.

---

## Convention

- Bahasa UI: **Indonesia**.
- Numeric: tabular figures (Plus Jakarta Sans).
- Currency: `Formatters.currency(value)` → `Rp 1.250.000`.
- Date: `Formatters.date(dt)` / `'dd MMMM yyyy', 'id_ID'`.

---

## Dokumentasi tambahan

- **PRD**: `docs/prd/KendaraanKu_PRD_v1.1.txt`
- **Design**: `docs/design/kendaraanku/`
- **Rules & dev plan**: `.claude/rules.md`, `.claude/development-plan.md`
- **Overview**: `docs/kendaraanku_overview.md` / `.html` / `.pdf`
