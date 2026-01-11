# project_flutter

A new Flutter project.

## Supabase config (recommended)

This app reads Supabase keys from Dart defines (`SUPABASE_URL`, `SUPABASE_ANON_KEY`).
To avoid typing them on every run:

1) Copy `dart_defines.dev.json.example` to `dart_defines.dev.json`
2) Fill in your Supabase URL and anon key
3) Run:

- `flutter run --dart-define-from-file=dart_defines.dev.json`

For web with a stable port:

- `flutter run -d chrome --web-port=3000 --dart-define-from-file=dart_defines.dev.json`

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
