# flutter_application_1

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Menjalankan di browser

Jalankan aplikasi web dengan:

```bash
flutter pub get
flutter run -d chrome
```

Database web disimpan di IndexedDB browser dan terpisah dari database Android/iOS.
Gunakan origin dan port yang sama agar data browser tetap tersedia. Jika file
SQLite web belum ada di folder `web/`, buat kembali dengan:

```bash
dart run sqflite_common_ffi_web:setup
```
