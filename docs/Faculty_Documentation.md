# Flutter Shop App — Project Documentation

**Student:** Fratean Sorin
**Project:** `project_flutter`
**Date:** January 2026

---

## 1. Project overview

This project is a **Flutter (Material 3)** shopping application built for a faculty presentation. The app demonstrates:

- A modern, responsive UI (mobile + web)
- State management using `ChangeNotifier`
- Local persistence (“cookies”) for user preferences and cart data
- Authentication with **Supabase** (email/password + Google OAuth)
- A small database-backed profile table with Row Level Security (RLS)

The app focuses on a clean user experience and realistic e-commerce flows while keeping the architecture simple and understandable.

---

## 2. Main features

### 2.1 Shopping experience

- Product browsing with responsive grid/list layouts
- Product details page
- Cart with quantity controls and total calculation
- Favorites (saved locally)
- Search (in-app)

### 2.2 UX and UI

- Bottom navigation (Home / Favorites / Cart / Account)
- Material 3 design language
- Light/Dark theme toggle with persistence
- Responsive layouts for different screen sizes (mobile/tablet/web)

### 2.3 “Extra” features for differentiation

- **Group buying (Group Deal)**: a mock feature demonstrating collaborative shopping logic
- **Sustainability panel (Green Score)**: a mock sustainability tracker to add a modern “eco” dimension

### 2.4 Accounts and database

- Email/password register + login
- Google login (OAuth via Supabase)
- Auto-creation/upsert of a user profile row in the `profiles` table

---

## 3. Technologies and packages

### 3.1 Technologies

- Flutter (Material 3)
- Dart SDK (see `pubspec.yaml` constraints)
- Supabase (Auth + Postgres)

### 3.2 Main packages used

- `supabase_flutter`: authentication + database client
- `shared_preferences`: persistence (theme + cart + favorites)
- `cached_network_image`: image caching for better UX/performance

---

## 4. Project structure (architecture)

The project is organized by responsibility:

- `lib/main.dart`
  - App entry point, theming, navigation shell
- `lib/models/`
  - Data models (e.g., product, cart item)
- `lib/state/`
  - Application state (`ChangeNotifier` models)
- `lib/data/`
  - Mock product data
- `lib/features/`
  - Feature modules (auth, group buying, sustainability)
- `lib/ui/`
  - UI helpers (e.g., responsive utilities)

This structure keeps UI, state, and domain models separated and makes the project easier to maintain.

---

## 5. State management

The app uses **simple global `ChangeNotifier` models** (suitable for small/medium projects).

- `ThemeModel`: stores theme mode and persists it
- `CartModel`: manages cart items + persists cart
- `FavoritesModel`: manages favorites + persists favorites
- `AuthModel`: wraps Supabase auth state

A central initializer (`initAppState`) loads persisted data at startup.

---

## 6. Persistence (“cookies”)

Persistence is implemented using `shared_preferences`.

### 6.1 Theme persistence

- Stores a boolean flag for dark/light preference

### 6.2 Favorites persistence

- Stores product IDs as a list

### 6.3 Cart persistence

- Stores cart items as JSON
- On app start, cart data is reloaded and reconstructed using product IDs

---

## 7. Authentication (Supabase)

Authentication is implemented with `supabase_flutter`.

### 7.1 Supported login methods

- Email/password sign up
- Email/password sign in
- Google OAuth sign in

### 7.2 Web OAuth notes

When testing on web, OAuth redirects must match the exact origin/port used by Flutter web.

Recommended development command:

- `flutter run -d chrome --web-port=3000 --dart-define-from-file=dart_defines.dev.json`

And Supabase must have:

- Site URL: `http://localhost:3000`
- Additional Redirect URLs: `http://localhost:3000`

---

## 8. Database (profiles table + RLS)

The project includes a minimal Postgres table for user profiles.

### 8.1 Table

- `profiles(id uuid primary key, email text, updated_at timestamptz, ...)`

### 8.2 RLS security

- Row Level Security is enabled
- Policies allow a user to read/update only their own profile row

### 8.3 Why this matters

This is a realistic security baseline for student projects:

- the client uses the anonymous key
- RLS prevents users from accessing other users’ data

---

## 9. Setup and run instructions

### 9.1 Install dependencies

- `flutter pub get`

### 9.2 Configure Supabase keys (recommended file-based)

1) Copy `dart_defines.dev.json.example` → `dart_defines.dev.json`
2) Fill in:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`

### 9.3 Run on web

- `cd `

### 9.4 Database setup

- Run the SQL in `supabase/schema.sql` using Supabase SQL Editor

---

## 10. Testing and quality checks

- Static analysis:
  - `flutter analyze`
- Widget test:
  - `flutter test`

(You can add screenshots of passing tests here if required by the course.)

---

## 11. Known limitations

- Uses mock product data (not a full backend catalog)
- Group buying and sustainability are demo features (logic is illustrative)
- Profile table is minimal (no profile editing UI)

---

## 12. Future improvements

If extended beyond the class requirements:

- Product catalog in Supabase (tables + admin panel)
- Server-side cart sync per account
- Order placement + order history
- Better search (categories, filters, indexing)
- Improved error handling + loading states

---

## 13. Presentation checklist (suggested)

For a clean faculty demo, present in this order:

1) Home + product browsing
2) Search + open a product detail
3) Add to favorites + show Favorites tab
4) Add to cart + modify quantity
5) Toggle dark/light theme
6) Account tab: login with Google
7) Explain that profile row is created in Supabase
8) Mention RLS security policies

---

## 14. Screenshots (placeholders)

Insert screenshots here:

- Home page
- Product details
- Cart
- Favorites
- Account (logged out)
- Account (logged in)
- Supabase dashboard (Auth provider enabled)
- Supabase table `profiles` (show your row)

---

## Appendix A — Files to reference during demo

- `lib/main.dart`
- `lib/state/*`
- `lib/features/auth/*`
- `supabase/schema.sql`
- `supabase/SETUP.md`
