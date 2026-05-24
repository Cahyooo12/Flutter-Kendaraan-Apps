# KendaraanKu — Development Plan & Checklist

## Mapping PRD vs UI Prototype

### Perbedaan yang Perlu Disesuaikan

| UI Prototype (sekarang)        | PRD v1.1                          | Action                              |
|-------------------------------|-----------------------------------|-------------------------------------|
| Login & Register page         | KEEP — auth lokal (SQLite)        | Login/Register tetap ada, simpan user di SQLite lokal, cek auth via SharedPreferences |
| Dokumen page (STNK, BPKB)    | Tidak ada di PRD                  | Keep sebagai bonus UI, tapi bukan prioritas development |
| Notifikasi page               | Tidak ada push notif              | Keep sebagai UI reminder lokal (servis/pajak reminder dari DB) |
| Profil page                   | Settings page                     | Ubah jadi Settings (theme, backup, export, satuan) |
| Static hardcoded data         | SQLite + BLoC dynamic             | Semua data dari database |
| Tidak ada form input          | Form CRUD lengkap                 | Buat form add/edit untuk semua fitur |
| Tidak ada dashboard chart     | fl_chart grafik                   | Buat dashboard dengan line/bar/pie chart |
| Tidak ada export              | PDF + CSV export                  | Implementasi export |
| Tidak ada foto/kamera         | image_picker + compress           | Integrasi kamera untuk nota/kwitansi |

---

## Development Phases & Checklist

### FASE 0: Foundation & Restructure (0.5 hari)
Sesuaikan arsitektur dari prototype ke PRD spec.

- [ ] **0.1** Update pubspec.yaml — tambah dependencies:
  - `flutter_bloc`, `freezed_annotation`, `freezed` (dev), `build_runner` (dev)
  - `dartz`, `sqflite`, `path_provider`, `shared_preferences`
  - `image_picker`, `fl_chart`, `pdf`, `printing`, `csv`
  - `path` (dart core)
- [ ] **0.2** Buat `lib/data/database_helper.dart` — singleton SQLite helper
  - Schema: vehicles, fuel_logs, service_logs, expense_categories
  - `_onCreate` dengan seed data expense_categories default
- [ ] **0.3** Buat data models (dengan Freezed):
  - `lib/data/models/vehicle_model.dart`
  - `lib/data/models/fuel_log_model.dart`
  - `lib/data/models/service_log_model.dart`
  - `lib/data/models/expense_category_model.dart`
- [ ] **0.4** Buat repositories:
  - `lib/data/repositories/vehicle_repository.dart`
  - `lib/data/repositories/fuel_log_repository.dart`
  - `lib/data/repositories/service_log_repository.dart`
- [ ] **0.5** Buat `lib/core/theme.dart` — light & dark ThemeData
- [ ] **0.6** Buat `lib/core/constants/strings.dart` & `lib/core/constants/enums.dart`
- [ ] **0.7** Buat `lib/core/utils/formatters.dart` — currency, date, odometer formatters
- [ ] **0.8** Buat `lib/core/utils/image_helper.dart` — compress & save image
- [ ] **0.9** Update `main.dart` — inisialisasi database, settings bloc, theme
- [ ] **0.10** Run `build_runner` untuk generate Freezed files

### FASE 1: Modul Kendaraan (1 hari)
CRUD kendaraan lengkap dengan BLoC.

- [ ] **1.1** Buat BLoC:
  - `lib/presentation/blocs/vehicle/vehicle_event.dart`
  - `lib/presentation/blocs/vehicle/vehicle_state.dart`
  - `lib/presentation/blocs/vehicle/vehicle_bloc.dart`
- [ ] **1.2** Update `home_page.dart`:
  - Ganti hardcoded data → BlocBuilder dari VehicleBloc
  - Vehicle selector chips dari database
  - Hero card dari selected vehicle
  - Quick stats dari calculated data
- [ ] **1.3** Update `add_vehicle_page.dart`:
  - Form lengkap: nama, tipe (motor/mobil/lainnya), merk, model, tahun, plat, warna
  - Foto kendaraan (image_picker)
  - Fuel type selector
  - Odometer awal
  - Simpan ke SQLite via BLoC
- [ ] **1.4** Buat `edit_vehicle_page.dart`:
  - Pre-fill form dari existing data
  - Update ke SQLite
- [ ] **1.5** Update `detail_vehicle_page.dart`:
  - Data dari BLoC/database
  - Tombol edit → EditVehiclePage
  - Tombol arsipkan (soft delete)
- [ ] **1.6** Update `main_navigation_page.dart`:
  - First-time flow: jika belum ada kendaraan → redirect ke AddVehiclePage
  - Wrap dengan MultiBlocProvider

### FASE 2: Modul BBM (1.5 hari)
Pencatatan BBM lengkap dengan kalkulasi konsumsi.

- [ ] **2.1** Buat BLoC:
  - `lib/presentation/blocs/fuel_log/fuel_log_event.dart`
  - `lib/presentation/blocs/fuel_log/fuel_log_state.dart`
  - `lib/presentation/blocs/fuel_log/fuel_log_bloc.dart`
- [ ] **2.2** Buat `add_fuel_log_page.dart`:
  - Form: tanggal, odometer, liter, harga/liter, jenis BBM, nama SPBU
  - Auto-calculate total (liter × harga)
  - Toggle full tank / partial
  - Foto struk (image_picker + compress)
  - Simpan ke SQLite
- [ ] **2.3** Update `fuel_page.dart`:
  - Data dari BlocBuilder
  - Summary card dari calculated stats
  - Bar chart dari fl_chart (real data)
  - FuelCard list dari database
  - Filter tanggal
- [ ] **2.4** Implementasi logika konsumsi BBM:
  - Full-tank-to-full-tank method
  - km/liter, biaya/km calculation
  - Rata-rata konsumsi

### FASE 3: Modul Servis (1 hari)
Pencatatan servis lengkap dengan kategori.

- [ ] **3.1** Buat BLoC:
  - `lib/presentation/blocs/service_log/service_log_event.dart`
  - `lib/presentation/blocs/service_log/service_log_state.dart`
  - `lib/presentation/blocs/service_log/service_log_bloc.dart`
- [ ] **3.2** Buat `add_service_log_page.dart`:
  - Form: tanggal, kategori (dropdown/chip), deskripsi, biaya, bengkel, odometer
  - Foto kwitansi (image_picker + compress)
  - Set reminder (odometer/tanggal berikutnya)
  - Simpan ke SQLite
- [ ] **3.3** Update `service_page.dart`:
  - Data dari BlocBuilder
  - Summary hero card dari calculated stats
  - Filter chips per kategori
  - Timeline list dari database
  - Grouped by bulan
- [ ] **3.4** Seed default expense_categories:
  - Ganti Oli Mesin, Ganti Oli Gardan, Ganti Ban, Tune Up, Ganti Aki
  - Ganti Kampas Rem, Ganti V-Belt, Servis AC, Perpanjang STNK, Lain-lain

### FASE 4: Dashboard & Statistik (1.5 hari)
Visualisasi data dengan fl_chart.

- [ ] **4.1** Buat BLoC:
  - `lib/presentation/blocs/dashboard/dashboard_event.dart`
  - `lib/presentation/blocs/dashboard/dashboard_state.dart`
  - `lib/presentation/blocs/dashboard/dashboard_bloc.dart`
- [ ] **4.2** Update home_page dashboard section:
  - Total pengeluaran bulan ini (real data)
  - Quick stats dari database
  - Reminder servis yang akan datang
- [ ] **4.3** Buat/update `dashboard_page.dart` (per kendaraan):
  - Summary card: total BBM, total servis, total keseluruhan
  - Line chart: tren pengeluaran bulanan (BBM vs Servis)
  - Bar chart: konsumsi BBM per bulan (km/liter)
  - Pie chart: distribusi jenis pengeluaran
  - Info cards: rata-rata biaya/km, rata-rata km/liter, total jarak
- [ ] **4.4** Filter periode:
  - Minggu ini, Bulan ini, 3 Bulan, 6 Bulan, Tahun ini, Custom range

### FASE 5: Export & Settings (1 hari)
PDF/CSV export, backup/restore, settings.

- [ ] **5.1** Buat BLoC:
  - `lib/presentation/blocs/settings/settings_bloc.dart` (SharedPreferences)
  - `lib/presentation/blocs/image/image_bloc.dart`
- [ ] **5.2** Update profile_page → `settings_page.dart`:
  - Theme toggle (light/dark/system)
  - Mata uang, satuan jarak, satuan volume
  - Default kendaraan
- [ ] **5.3** Buat `backup_restore_page.dart`:
  - Backup: copy .db file → share sheet
  - Restore: import .db file → replace database
  - Reset semua data (dialog konfirmasi ganda)
- [ ] **5.4** Implementasi PDF export:
  - Laporan per kendaraan dengan tabel dan summary
  - Filter periode
  - Share via share sheet
- [ ] **5.5** Implementasi CSV export:
  - Export fuel_logs dan service_logs
  - Per kendaraan atau semua
  - Share via share sheet
- [ ] **5.6** Foto nota gallery:
  - GridView semua foto per kendaraan
  - Tap untuk fullscreen view

### FASE 6: Polish & Auth Flow Fix (0.5 hari)
Final adjustments.

- [ ] **6.1** Update auth flow:
  - Splash → cek logged in (SharedPreferences) → jika sudah login → HomePage
  - Splash → jika belum → Onboarding (first time) atau Login (returning)
  - Onboarding → Register → Login → Home
  - Auth data disimpan lokal di SQLite (tabel users), session di SharedPreferences
- [ ] **6.3** Update Dokumen page → jadikan galeri foto nota/kwitansi per kendaraan
- [ ] **6.4** Update Notifikasi page → jadikan reminder list dari servis/pajak yang upcoming
- [ ] **6.5** UI polish: loading states, empty states, error states
- [ ] **6.6** Bug fixing & testing semua flow
- [ ] **6.7** Update CLAUDE.md dengan final state

---

## Urutan Prioritas Development
1. Fase 0 (Foundation) — HARUS duluan, semua fase lain depend on this
2. Fase 1 (Kendaraan) — Core feature, semua fitur lain butuh vehicle_id
3. Fase 2 (BBM) — Fitur paling sering dipakai user
4. Fase 3 (Servis) — Pattern mirip BBM, lebih cepat
5. Fase 4 (Dashboard) — Butuh data BBM & servis sudah ada
6. Fase 5 (Export & Settings) — Nice to have, bisa parallel
7. Fase 6 (Polish) — Terakhir

## Status: UI PROTOTYPE COMPLETE ✅
Semua 12 screen sudah di-slice dengan presisi dari design. 
Selanjutnya: implementasi logic & data layer sesuai fase di atas.
