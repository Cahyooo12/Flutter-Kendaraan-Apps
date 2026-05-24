# Kendaraanku - Aplikasi Pencatatan Kendaraan Pribadi (Full Offline)

## Project Overview
Flutter mobile app untuk mencatat seluruh aktivitas dan pengeluaran kendaraan pribadi secara offline.
Demo program + bonus source code untuk SharingSession JagoFlutter Free Event.

**PRD**: `docs/prd/KendaraanKu_PRD_v1.1.txt`
**Design**: `docs/design/kendaraanku/` (JSX design files + screenshots)
**Dev Plan**: `.claude/development-plan.md` (fase & checklist lengkap)
**Rules**: `.claude/rules.md` (architecture & coding conventions)

## Current Status
- UI Prototype: **COMPLETE** (12 screens sliced from design)
- Data Layer: **NOT STARTED** (semua data masih hardcoded)
- BLoC Integration: **NOT STARTED**
- Database (SQLite): **NOT STARTED**

## Tech Stack (dari PRD)
- Flutter 3.x + BLoC + Freezed + Dartz
- Sqflite (SQLite) + SharedPreferences
- fl_chart, pdf, csv, image_picker
- Navigator v1 (push/pop) — NO router library
- Plus Jakarta Sans (google_fonts)

## Architecture: 2-Layer Simpel (Data → Presentation)
```
lib/
  data/
    models/          → Freezed models
    repositories/    → SQLite query logic
    database_helper.dart → singleton
  presentation/
    <feature>/pages/ → screens
    <feature>/widgets/ → feature widgets
    blocs/           → BLoC per fitur
  core/
    constants/       → colors, styles, strings, enums
    components/      → reusable widgets
    extensions/      → context, int, string, datetime
    utils/           → formatters, image helper
    theme.dart       → light & dark theme
```

## Design System
- Primary: `#3D6BF5`, Hero gradient: `#4A7BF7` → `#6B95FA`
- Font: Plus Jakarta Sans, numeric: tabular figures
- Border radius: sm=10, r=14, lg=20, xl=28
- 6 tint pairs: blue, mint, peach, lavender, rose, amber

## Key Conventions
- NO auth/login (100% offline app)
- Onboarding → AddVehicle (first time) → Home
- BLoC: Event (Freezed) → BLoC → State (Freezed)
- DI manual via constructor (NO get_it)
- Navigator.push/pop standar
- Foto: compress 1280px/80%, save app directory
- Database: singleton pattern, 4 tabel (vehicles, fuel_logs, service_logs, expense_categories)
