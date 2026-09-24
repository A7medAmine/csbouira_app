# Architecture

A map of the codebase for new contributors: where things live, where data comes from, and how state moves through the app.

## The big picture

```
                         ┌────────────────────────────┐
                         │        Flutter app         │
                         │  features/  →  providers   │
                         │              →  services   │
                         └──┬──────────┬──────────┬───┘
                            │          │          │
          read-only JSON    │          │ auth,    │ JSON + base64 
                            ▼          │ tables,  ▼
          ┌─────────────────────┐      │ RPCs   ┌──────────────────────┐
          │ CS Bouira Drive API │      │        │ Upload endpoint      │
          │ api.csbouira.xyz    │      │        │ (Google Apps Script) │
          └──────────┬──────────┘      ▼        └──────────┬───────────┘
                     │        ┌─────────────────┐          │
                     │        │    Supabase     │          │
                     │        │ Auth + Postgres │          │
                     │        └─────────────────┘          │
                     ▼                                     ▼
          ┌────────────────────────────────────────────────────┐
          │                  Google Drive                      │
          │  (the actual files; downloaded via drive.google…)  │
          └────────────────────────────────────────────────────┘
```

There are three backends, each with one job:

| Backend | Used for | Code |
| --- | --- | --- |
| **Drive API** (`ApiConstants.driveBaseUrl`) | The catalogue: years → semesters → modules → folders → files, file counts, online resources. Public and read-only. Documented in [api.md](../api.md). | `data/services/drive_api_service.dart` |
| **Supabase** | Accounts, profiles, synced favorites, upload history, leaderboard. Protected by Row Level Security. Schema in `supabase/`. | `data/services/auth_service.dart`, `data/repositories/favorites_repository.dart`, `data/services/leaderboard_service.dart` |
| **Upload endpoint** (`ApiConstants.uploadUrl`) | Receives uploaded files (base64 JSON) and stores them in Drive for moderation. Private. | `data/services/upload_service.dart` |

File contents are always downloaded straight from Google Drive using the links the Drive API returns.

## Folder layout

```
lib/
├── main.dart              Loads .env, initializes Supabase and Google Sign-In, runs the app
├── app.dart               MaterialApp, theme, locale, and the go_router route table
├── core/
│   ├── constants.dart     API URLs, upload limits, network timeouts
│   ├── error_messages.dart Maps exceptions to localized, user-friendly messages
│   ├── providers/         App-wide providers (locale)
│   └── theme/             Colors, spacing, radius, ThemeData
├── data/
│   ├── models/            Plain data classes (DriveNode, DriveFile, UploadResult, …)
│   ├── services/          Talk to one backend or one local store each
│   ├── repositories/      Combine several sources (FavoritesRepository: Supabase + local)
│   └── providers/         Riverpod providers that expose services and state to the UI
├── features/              One folder per screen or flow
│   ├── splash/ home/ browse/ search/ preview/ downloads/
│   ├── favorites/ upload/ scan/ leaderboard/ profile/
│   └── auth/ about/ legal/
├── shared/widgets/        Reusable widgets (bottom nav, network banner, favorite star, …)
└── l10n/                  ARB translation files and the generated AppLocalizations
```

**Rule of thumb:** widgets in `features/` should read data through providers and call services, rather than making network or database calls themselves. Some older screens still call Supabase directly; moving that logic into `data/` is welcome.

## State management (Riverpod)

All providers are plain Riverpod 2 (no code generation). The important ones:

| Provider | Kind | Purpose |
| --- | --- | --- |
| `supabaseProvider` | `Provider` | The `SupabaseClient` |
| `authStateProvider` / `currentUserProvider` | `StreamProvider` / `Provider` | Current Supabase session and user |
| `driveApiServiceProvider` | `Provider` (keep-alive) | Drive API client with an in-memory cache |
| `driveRootDataProvider` | `FutureProvider` (keep-alive) | The full catalogue tree, preloaded on the splash screen |
| `driveNodeProvider(key)` | `FutureProvider.family` | One folder node; served from the cached tree when possible |
| `favoritesRepositoryProvider` | `Provider` | Rebuilt whenever the signed-in user changes |
| `favoritesListProvider` | `AsyncNotifierProvider` | Favorites list with optimistic add and remove |
| `uploadStateProvider` | `StateNotifierProvider` | Upload progress and error state |
| `updateDownloadProvider` | `StateNotifierProvider` | In-app update APK download |

**Refreshing catalogue data:** Drive responses are cached for the whole session. Pull-to-refresh calls `ref.refreshDriveData()` (in `drive_providers.dart`), which clears the service cache and invalidates every Drive provider.

## Key flows

### Browsing

`splash_screen` preloads `driveRootDataProvider`, which fetches the whole tree in one request. The browse screens (`semester_screen`, `module_screen`, `folder_screen`, `file_screen`) watch `driveNodeProvider` with a path key. Paths are joined with `>subfolders>`, matching the Drive API's path syntax.

### Favorites: guest vs. signed in

`FavoritesRepository` behaves differently depending on who is signed in:

| | Source of truth | Local store (SharedPreferences) |
| --- | --- | --- |
| Guest | Device | `local_favorites` |
| Signed in | Supabase `favorites` table | `account_favorites_<userId>`: offline mirror only |

The two local stores never mix. When a guest signs in with favorites on the device, the login screen offers to merge them into the account (`GuestMergeService`, which inserts with `ON CONFLICT DO NOTHING`). Logging out deletes that account's mirror from the device.

Writes are optimistic: `FavoritesNotifier.add` and `remove` update the UI immediately, and roll back and return `false` if the server call fails.

### Upload

1. `upload_screen` collects metadata (category, grade, semester, module) and one or more files, picked from storage or scanned with `flutter_doc_scanner`.
2. For each file, `UploadService.uploadResource` sends a JSON body with the file as base64. The service handles timeouts, retries with exponential backoff, cancellation and Apps Script redirects, and reports progress.
3. On success, signed-in users call the `record_upload` RPC (rate-limited, security definer) so the upload counts on the leaderboard. Guests' uploads are counted locally.
4. If some files fail, only the failed ones stay selected, so Retry re-sends just those.

### Auth

- **Email/password:** `supabase.auth.signUp` stores `full_name` in the user metadata. The `on_auth_user_created` trigger (`migration_004.sql`) creates the `profiles` row. If email confirmation is on, the user is asked to confirm and then log in.
- **Google:** native `google_sign_in` returns an ID token, which is exchanged with `signInWithIdToken`. The profile is upserted with the Google name and photo.
- **Password reset:** a 6-digit recovery code is sent by email and verified in-app, then the new password is set.

### Downloads and preview

- **Preview** (`preview/`) uses `FileCacheService`: files are streamed into `temp/file_cache/`, keyed by Drive file ID, and the least recently used files are evicted above 200 MB.
- **Downloads** (`downloads/`) use `DownloadService`: files are streamed into the app documents folder, and download records are kept in SharedPreferences.
- Both use `http_download.dart`, which streams to a `.part` file, renames it when complete, applies an idle timeout, and rejects HTML error pages.

### In-app updates

`UpdateService` asks GitHub Releases for the latest release, at most once every 12 hours, and compares versions with `pub_semver`. `UpdateDownloadNotifier` downloads the APK and opens the Android installer.

## Localization

- Source strings live in `lib/l10n/app_en.arb` (the template). `app_fr.arb` and `app_ar.arb` hold the translations.
- `flutter gen-l10n` (configured by `l10n.yaml`) generates `app_localizations*.dart` in the same folder. The generated files are committed.
- Arabic is right-to-left: use `EdgeInsetsDirectional` and `AlignmentDirectional` instead of left/right.

## Database

Tables in the `public` schema, all with RLS enabled:

| Table | Rows visible to a user | Written by |
| --- | --- | --- |
| `profiles` | Own row | Signup trigger; the user can update their own row |
| `favorites` | Own rows | The user (insert and delete own rows) |
| `uploads` | Own rows | Only through the `record_upload` RPC |

The leaderboard is computed by `get_leaderboard` and `get_user_rank`: security definer functions that expose only names, avatars and counts.

## Android-specific code

`android/app/src/main/kotlin/.../MainActivity.kt` implements the `csbouira_app/file_utils` method channel, which reads `content://` URIs that `file_picker` sometimes returns and Dart cannot open directly.
