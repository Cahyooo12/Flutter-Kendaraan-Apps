# KendaraanKu — Development Rules & Conventions

## Architecture Rules (dari PRD v1.1)

### 2-Layer Architecture (Data → Presentation)
- **TIDAK** pakai domain layer, use case class, atau repository interface/abstract
- Repository langsung berisi logic query SQLite, dipanggil oleh BLoC
- BLoC langsung instantiate Repository via constructor

### Folder Structure (Target)
```
lib/
  data/
    models/              → vehicle_model.dart, fuel_log_model.dart, service_log_model.dart, expense_category_model.dart
    repositories/        → vehicle_repository.dart, fuel_log_repository.dart, service_log_repository.dart
    database_helper.dart → singleton SQLite helper
  presentation/
    auth/pages/          → splash_page, onboarding_page, login_page, register_page (auth lokal SQLite)
    home/pages/          → home_page, main_navigation_page
    home/widgets/        → vehicle_card, summary_card
    vehicle/pages/       → detail_vehicle_page, add_vehicle_page, edit_vehicle_page
    vehicle/widgets/     → vehicle_form_fields
    fuel/pages/          → fuel_page, add_fuel_log_page
    fuel/widgets/        → fuel_card, fuel_stats_card
    service/pages/       → service_page, add_service_log_page
    service/widgets/     → service_card, service_category_chip
    dashboard/pages/     → dashboard_page
    dashboard/widgets/   → chart widgets (line, bar, pie)
    settings/pages/      → settings_page, backup_restore_page
    blocs/               → vehicle_bloc, fuel_log_bloc, service_log_bloc, dashboard_bloc, image_bloc, settings_bloc
  core/
    constants/           → colors.dart, app_styles.dart, strings.dart, enums.dart
    components/          → reusable widgets
    extensions/          → build_context_ext, int_ext, string_ext, date_time_ext
    utils/               → formatters, calculators, image_helper
    theme.dart           → light & dark ThemeData
  main.dart
```

### Tech Stack
- State Management: `flutter_bloc` + `freezed` + `dartz`
- Database: `sqflite` (SQLite)
- Settings: `shared_preferences`
- Camera: `image_picker`
- Charts: `fl_chart`
- PDF: `pdf` + `printing`
- CSV: `csv`
- Navigation: Navigator v1 (push/pop) — NO go_router/auto_route
- Font: Plus Jakarta Sans via `google_fonts`

### Coding Conventions
- Semua BLoC pakai pattern: Event (Freezed) → BLoC → State (Freezed)
- State: initial, loading, loaded, error
- Error handling pakai Dartz Either
- Navigator.push/pop standar, pass data via constructor, receive result via await
- Dependency injection manual via constructor (NO get_it/injectable)
- Database: singleton pattern DatabaseHelper
- Image: compress max 1280px, quality 80%, save ke app directory
- Naming file: `{vehicle_id}_{type}_{timestamp}.jpg`

### Yang TIDAK Dipakai
- Hive (pakai SharedPreferences + SQLite)
- go_router / auto_route (pakai Navigator v1)
- get_it + injectable (DI manual)
- Riverpod / Provider (pakai BLoC)
- Google ML Kit / OCR (foto lampiran saja)
- Cloud sync / backend API
- Push notifications
