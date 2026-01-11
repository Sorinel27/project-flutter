# Supabase Auth + Google (Setup)

This project uses `supabase_flutter` for authentication and a minimal `profiles` table.

## 1) Create Supabase project
- Create a new project on Supabase.
- Go to **Project Settings → API** and copy:
  - **Project URL**
  - **Anon public key**

## 2) Run the app with keys
Recommended: put your keys in a local file (so you don't type them every time).

1) Copy the example file:

- `dart_defines.dev.json.example` → `dart_defines.dev.json`

2) Edit `dart_defines.dev.json` and fill in your Supabase URL + anon key.

3) Run using `--dart-define-from-file`:

- `flutter run --dart-define-from-file=dart_defines.dev.json`

## 3) Create DB table
In Supabase **SQL Editor**, run:
- [schema.sql](schema.sql)

## 4) Enable Google sign-in in Supabase
Supabase dashboard:
- **Authentication → Providers → Google**
- Enable it.

You will need a Google Cloud OAuth Client ID/Secret.

## 5) Configure redirect URLs (important)
### Android/iOS (this repo default)
This repo is configured for the scheme:
- `com.example.project_flutter://login-callback`

Make sure you add the following redirect URL(s) in Supabase:
- `com.example.project_flutter://login-callback`

### Web
For Flutter web, you must set Supabase to redirect back to the exact origin your app is running on.

Recommended (stable local dev):

- Run Flutter with a fixed port: `flutter run -d chrome --web-port=3000`
- In Supabase Dashboard → **Authentication → URL Configuration**:
  - Set **Site URL** to `http://localhost:3000`
  - Add `http://localhost:3000` to **Additional Redirect URLs**

If you use a different port, add that exact origin (what you see in the browser address bar).

## 6) Notes
- For a class project, email/password + Google OAuth is usually fine on free tier.
- If you change `applicationId` in Android, update:
  - [android/app/src/main/AndroidManifest.xml](../android/app/src/main/AndroidManifest.xml)
  - [ios/Runner/Info.plist](../ios/Runner/Info.plist)
  - the redirect URL in [lib/features/auth/account_page.dart](../lib/features/auth/account_page.dart)
