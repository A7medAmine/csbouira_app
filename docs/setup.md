# Development setup

This guide takes you from a fresh clone to a fully working app, with accounts, favorites sync and the leaderboard running against your own Supabase project.

## 1. Prerequisites

- **Flutter 3.29.3** (stable). CI builds with this exact version (`.github/workflows/release.yml`); newer 3.x versions usually work.
- **Android SDK** and a device or emulator running Android 6.0 (API 23) or later.
- **JDK 17**.
- A free [Supabase](https://supabase.com) account.
- Optional, only for Google Sign-In: a [Google Cloud](https://console.cloud.google.com) project.

Check your toolchain:

```bash
flutter doctor
```

## 2. What works without any setup

| Feature | Backend | Needs your setup? |
| --- | --- | --- |
| Browse, search, preview, download | CS Bouira Drive API (public, read-only) | No |
| Guest favorites, guest profile | Stored on the device | No |
| Accounts, synced favorites, leaderboard | Supabase | **Yes**, see section 4 |
| Google Sign-In | Google Cloud + Supabase | **Yes**, see section 5 |
| Uploads | Official upload backend (private) | No, but see the warning in section 6 |

The app does still need a `.env` file with a Supabase URL and key to start. `main.dart` refuses to launch without them.

## 3. Environment file

```bash
cp .env.example .env
```

| Variable | Required | Where to find it |
| --- | --- | --- |
| `SUPABASE_URL` | Yes | Supabase → Project Settings → API → Project URL |
| `SUPABASE_ANON_KEY` | Yes | Supabase → Project Settings → API → `anon` / publishable key |
| `GOOGLE_SERVER_CLIENT_ID` | For Google Sign-In | Google Cloud → Credentials → **Web** OAuth client ID |
| `GOOGLE_ANDROID_CLIENT_ID` | Optional | Google Cloud → Credentials → **Android** OAuth client ID |
| `SENTRY_DSN` | Optional | Sentry → Project Settings → Client Keys (DSN). Empty means crash reporting is off; see section 7 |

> **Note:** `.env` is bundled into the APK as an asset (`pubspec.yaml`). Anyone can unzip an APK and read it. Only put **public** values in it: the Supabase anon key is designed to be public, and Row Level Security protects the data. Never put a `service_role` key, a database password or any other secret in `.env`, not even in a comment.

## 4. Supabase

### 4.1 Create the project

Create a new project in the Supabase dashboard and copy its URL and anon key into `.env`.

### 4.2 Create the database

Open **SQL Editor** and run these files from `supabase/` **in this order**:

1. `schema.sql`: tables `profiles`, `favorites`, `uploads`; RLS policies; leaderboard functions.
2. `migration_001.sql`: adds `profiles.username` and a legacy `otp_requests` table (not used by the app).
3. `migration_002.sql`: favorites columns `display_name` and `resource_type`.
4. `migration_003.sql`: favorites column `folder_path`.
5. `migration_004.sql`: security hardening: the `record_upload` RPC, a profile-creation trigger, and tightened policies.

Every file can safely be run again.

The forgot-password screen also calls a `check_email_exists` RPC, which is not in the SQL files yet. Create it with:

```sql
create or replace function public.check_email_exists(target_email text)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
begin
  return exists (select 1 from public.profiles where email = target_email);
end;
$$;
```

> This function lets anyone check whether an email is registered. It is a known issue, planned to be removed; see [SECURITY.md](../SECURITY.md).

### 4.3 Configure authentication

In **Authentication → Sign In / Providers → Email**:

- Enable the Email provider.
- **Confirm email**: either setting works. With it on, new users are asked to confirm their email before logging in.

The forgot-password flow has the user type a **6-digit code** in the app, not click a link. Edit the **Reset Password** template (**Authentication → Emails → Templates**) so it includes `{{ .Token }}`. Example body:

```html
<h2>Your CS Bouira code</h2>
<p>Enter this code in the app: <strong>{{ .Token }}</strong></p>
<p>It expires in 1 hour.</p>
```

The built-in Supabase email service is heavily rate-limited. For anything beyond local testing, configure your own SMTP under **Authentication → Emails → SMTP Settings**.

## 5. Google Sign-In (optional)

The app uses native Google Sign-In (`google_sign_in` 7.x) and passes the ID token to Supabase (`signInWithIdToken`).

1. **Get your signing certificate's SHA-1.**

   ```bash
   cd android
   ./gradlew signingReport
   ```

   Use the `debug` variant's SHA-1 for local development. Release builds need the SHA-1 of your release key as well.

2. **Google Cloud Console → APIs & Services → Credentials**. Set up the OAuth consent screen, then create two OAuth client IDs:
   - **Android**: package name `com.csbouira.csbouira_app`, plus the SHA-1 from step 1.
   - **Web application**: no redirect URIs needed.

3. **Supabase → Authentication → Sign In / Providers → Google**: enable it, paste the **Web** client ID and secret, and turn on **Skip nonce checks** (needed for native sign-in on Android).

4. **`.env`**: set `GOOGLE_SERVER_CLIENT_ID` to the **Web** client ID. Optionally set `GOOGLE_ANDROID_CLIENT_ID` to the Android client ID.

**Troubleshooting:** `ID token is null` or error code `10` / `DEVELOPER_ERROR` almost always means a SHA-1 or package-name mismatch in the Android client, or that `GOOGLE_SERVER_CLIENT_ID` is not the **Web** client ID.

## 6. Uploads

Uploaded files are sent to the project's official Google Apps Script endpoint (`ApiConstants.uploadUrl` in `lib/core/constants.dart`), which stores them in the CS Bouira Drive for moderation. That backend's source is not public.

> **Warning:** even in a development build, uploads go to the **real** CS Bouira Drive. Please don't upload test files. To test the upload UI, cancel before sending, or point `ApiConstants.uploadUrl` at your own endpoint.

After a successful upload, signed-in users get leaderboard credit through the `record_upload` RPC in your Supabase project, which allows at most 20 uploads per user per hour.

## 7. Crash reporting (optional)

Crash reports go to [Sentry](https://sentry.io) when `SENTRY_DSN` is set in `.env`; with no DSN, the Sentry SDK is never started. Users can also turn reports off in **Profile → Send crash reports**.

1. Create a Flutter project in Sentry and copy its DSN into `.env` (and into the `SENTRY_DSN` GitHub secret for release builds).
2. In the Sentry project, enable **Settings → Security & Privacy → Prevent Storing of IP Addresses**. The app already sends no user names, emails or IP addresses (`sendDefaultPii` is off), and the privacy policy promises this.

## 8. Run, analyze, test

```bash
flutter pub get
flutter run                # pick a device with -d <id>; list them with `flutter devices`
flutter analyze            # must report no issues
flutter test
```

Every pull request runs the same three checks on GitHub Actions (`.github/workflows/ci.yml`), plus a check that the generated localization files are up to date.

After editing any `lib/l10n/*.arb` file, regenerate the localization classes:

```bash
flutter gen-l10n
```

## 9. Release builds

```bash
flutter build apk --release
```

Official releases are built by GitHub Actions when a `v*.*.*` tag is pushed; see [CONTRIBUTING.md](../CONTRIBUTING.md#releases).
