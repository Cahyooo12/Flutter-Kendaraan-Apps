# Kendaraanku — Release Guide (Google Play Store)

Panduan menuju produksi. Ikuti urutan dari atas ke bawah. Yang sudah dikerjakan di repo ditandai ✅; yang perlu Anda kerjakan sendiri ditandai ▢.

---

## 1. Identitas Aplikasi ✅

- `applicationId` = `id.kendaraanku.app`
- `namespace` = `id.kendaraanku.app`
- App label di AndroidManifest = `Kendaraanku`
- Versi: `1.0.0+1` di `pubspec.yaml`

Jika ingin pakai applicationId berbeda, ubah:
- `android/app/build.gradle.kts` (2 tempat: `namespace` & `applicationId`)
- `android/app/src/main/kotlin/id/kendaraanku/app/MainActivity.kt` (package + folder)
- `android/app/src/main/AndroidManifest.xml` (tidak perlu, label saja yang tersurat)

**Tidak bisa diubah setelah upload pertama ke Play Store.**

---

## 2. App Icon & Splash ✅

Source asset di `assets/branding/`:
- `app_icon.png` (1024×1024) — icon utama, sudah branded gradient biru + huruf "K"
- `app_icon_foreground.png` — adaptive icon foreground (Android 8+)
- `splash_logo.png` — logo untuk splash screen

> Ini **placeholder**. Untuk produksi, ganti dengan icon final Anda (size sama), lalu regenerasi:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Brand color: `#4A7BF7` (sama dengan `AppColors.heroTop`). Adaptive icon background pakai warna ini, splash juga.

---

## 3. Release Keystore ▢

Play Store **wajib** AAB di-sign dengan release keystore. Saat ini repo masih fallback ke debug signing kalau `android/key.properties` tidak ada.

### Generate keystore (sekali saja, simpan baik-baik)

```bash
keytool -genkey -v -keystore ~/kendaraanku-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Akan ditanya password keystore, password key, dan info CN/OU/dst. **Simpan password & file `.jks` di tempat aman** (password manager + offline backup). Kehilangan keystore = tidak bisa update app lagi tanpa minta key reset ke Google.

### Setup `android/key.properties`

```bash
cp android/key.properties.template android/key.properties
```

Edit isinya:
```
storePassword=<password keystore>
keyPassword=<password key>
keyAlias=upload
storeFile=/Users/<user>/kendaraanku-upload.jks
```

File `key.properties` & `*.jks` sudah di-`.gitignore` — jangan commit.

### Verifikasi

```bash
flutter build appbundle --release
```

Output ada di `build/app/outputs/bundle/release/app-release.aab`. Cek signing-nya:
```bash
keytool -list -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
```

---

## 4. ProGuard / R8 ✅

`android/app/proguard-rules.pro` sudah berisi rule untuk:
- Flutter engine & plugins
- Google ML Kit text recognition (tanpa ini OCR akan crash di release)
- Sqflite, image_picker, flutter_image_compress, printing

`buildTypes.release` di `build.gradle.kts` sudah:
- `isMinifyEnabled = true`
- `isShrinkResources = true`

Jika ada plugin baru ditambah, mungkin perlu update rules-nya.

---

## 5. Permission ✅

`AndroidManifest.xml` sudah declare:
- `CAMERA` (untuk foto kendaraan, dokumen, OCR nota)
- `READ_MEDIA_IMAGES` (Android 13+) untuk gallery picker
- `READ_EXTERNAL_STORAGE` (max sdk 32) untuk gallery picker legacy
- `<uses-feature camera/autofocus required=false>` agar app tetap bisa di-install di device tanpa kamera

**Tidak ada `INTERNET`** — sesuai PRD app 100% offline. Bagus untuk Data Safety form.

---

## 6. Privacy Policy URL ▢

Play Store wajib URL publik. In-app `PrivacyPage` tidak cukup (Console minta link HTTPS).

Cara termudah:
1. Buat repo public di GitHub
2. Tambah `privacy-policy.md` (copy konten dari `lib/presentation/profile/pages/privacy_page.dart`)
3. Enable GitHub Pages (Settings → Pages → Source: main, /docs atau root)
4. URL hasil → masukkan ke Play Console saat submit

Atau pakai service gratisan: Notion publish, GitBook, Vercel static page.

---

## 7. Data Safety Form ▢

Di Play Console → App content → Data safety, jawab:

| Pertanyaan | Jawaban untuk Kendaraanku |
|---|---|
| Does your app collect or share any of the required user data types? | **No** |
| Is all user data encrypted in transit? | N/A (no network) |
| Do you provide a way for users to request that their data is deleted? | **Yes** — via uninstall (data 100% lokal) |

Karena tidak ada server, semua kategori "data collection" = **none**. Sebutkan ini di app description juga untuk trust.

---

## 8. Store Listing ▢

Yang harus disiapkan untuk listing:

| Item | Spesifikasi |
|---|---|
| App name | `Kendaraanku` (≤ 30 char) |
| Short description | 80 char, contoh: "Catat BBM, servis, dan dokumen kendaraan. 100% offline." |
| Full description | ≤ 4000 char, deskripsi lengkap + bullet fitur |
| App icon | 512×512 PNG 32-bit (≤ 1 MB) — gunakan `assets/branding/app_icon.png` |
| Feature graphic | 1024×500 PNG/JPG |
| Phone screenshots | 2–8 buah, 16:9 atau 9:16, min 320 px sisi pendek |
| 7-inch tablet | opsional |
| 10-inch tablet | opsional |
| Promo video | opsional (YouTube URL) |
| Category | Tools atau Auto & Vehicles |
| Content rating | Isi questionnaire (kemungkinan Everyone) |
| Contact email | wajib publik |
| Privacy Policy URL | dari step 6 |

---

## 9. App Signing by Google Play ▢

Recommended: pakai App Signing by Google Play (default sekarang).
- Anda upload AAB di-sign dengan **upload key** (keystore di step 3)
- Google Play re-sign dengan **app signing key** mereka sebelum distribusi
- Kalau upload key hilang, masih bisa reset via Console (asalkan Anda buktikan ownership)

Saat upload pertama, Console akan auto-enroll kalau Anda pakai AAB (bukan APK).

---

## 10. Build Command Final

```bash
# Bersihkan
flutter clean
flutter pub get

# Generate ulang asset (kalau ganti icon)
dart run flutter_launcher_icons
dart run flutter_native_splash:create

# Build app bundle release
flutter build appbundle --release

# Output:
# build/app/outputs/bundle/release/app-release.aab
```

Upload `.aab` ke Play Console → Internal testing → tester sendiri/tim → kalau OK promote ke Production.

---

## 11. Pre-launch Checklist ▢

- [ ] applicationId final (`id.kendaraanku.app` atau lainnya) — **tidak bisa diubah lagi**
- [ ] Icon final mengganti placeholder di `assets/branding/`
- [ ] Splash logo final
- [ ] Keystore release dibuat, password disimpan aman, sudah di-backup
- [ ] `android/key.properties` di-set & TIDAK ter-commit
- [ ] `flutter build appbundle --release` sukses & install di device fisik
- [ ] Test golden path: register → tambah kendaraan → catat BBM (scan nota) → catat servis (scan nota) → tambah dokumen → export PDF
- [ ] Test di Android 8 (minimum supported), 13 (READ_MEDIA_IMAGES split), 14+
- [ ] Privacy Policy URL publik & dapat diakses
- [ ] Data Safety form diisi (semua "no" untuk collection)
- [ ] Store listing: icon 512, feature graphic 1024×500, ≥ 2 screenshots
- [ ] Contact email aktif
- [ ] Content rating questionnaire selesai
- [ ] Internal testing track sukses minimal 14 hari sebelum ke Production (Google policy)

---

## 12. Yang Perlu Diperhatikan di iOS (App Store) — Opsional

Repo ini sudah set `flutter_launcher_icons` & `flutter_native_splash` untuk iOS juga. Tapi untuk submit ke App Store:
- Bundle ID iOS perlu diset di Xcode (`ios/Runner.xcworkspace`)
- Apple Developer account ($99/tahun)
- Provisioning profile + cert
- TestFlight internal sebelum Production review
- Privacy nutrition label (mirip Data Safety di Play Store)

Tidak diperlukan jika launch hanya di Android.
