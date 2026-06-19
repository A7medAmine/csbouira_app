# CS Bouira App — Build Progress

## Phase 1: Scaffold & Theme
- [x] Create Flutter project (Android + iOS only)
- [x] Remove extra platforms (linux, macos, windows, web)
- [x] Set up folder structure (`core/`, `data/`, `features/`, `shared/`)
- [x] Add dependencies (flutter_riverpod, go_router, google_fonts, shared_preferences, http, flutter_dotenv)
- [x] Build `app_colors.dart` — full dark M3 palette from DESIGN.md export
- [x] Build `app_radius.dart` — 4/8/12/16/24/9999px radii
- [x] Build `app_spacing.dart` — 4px unit, gutters, margins, stacks
- [x] Build `app_theme.dart` — light (seeded) + dark (exact) ThemeData with Manrope/Inter/JetBrainsMono
- [x] Create `constants.dart` — API URLs, storage keys, upload limits
- [x] Create GoRouter skeleton with all routes
- [x] Create placeholder screens for all features
- [x] Wire `ProviderScope` and `MaterialApp.router`
- [x] Pass `flutter analyze` with 0 issues

## Phase 1b: Splash Screen
- [x] Build `SplashScreen` from Stitch export (dark bg `#0D0D14`, logo with pulse-glow and float animations, tagline, progress bar, noise overlay)
- [x] Add `/splash` route as initial GoRouter location
- [x] Auto-navigate to home after 3.5s

## Phase 2: Drive API & Browsing
- [x] Build `DriveFile` model with `fromJson`/`toJson`
- [x] Build `DriveNode` model with `fromJson`/`toJson` (handles `(empty)` suffix, error shapes)
- [x] Build `DriveRootData` + `OnlineResource` models
- [x] Build `DriveApiService` — all 7 endpoint methods, path joining, in-memory cache, `DriveApiException`
- [x] Create `driveApiServiceProvider`, `driveRootDataProvider`, `fileCountsProvider`, `driveNodeProvider`
- [x] Update `HomeScreen` — year cards with file count badges from real API data
- [x] Update `SemesterScreen` — semester list with module counts from cached tree
- [x] Update `ModuleScreen` — module list with folder/file counts
- [x] Update `FolderScreen` — 5 folder types (Cours/Exams/Résumé/TDs & TPs/Tests) with empty-state disable
- [x] Update `FileScreen` — file listing with type-specific icons

## Phase 3: File Preview & Download
- [ ] Add dependencies (flutter_pdfview or syncfusion_flutter_pdfviewer, cached_network_image, url_launcher, permission_handler)
- [ ] Build `PreviewScreen` — PDF rendering with temp download + cached network image for images
- [ ] Implement file download to device storage with progress callback
- [ ] Wire `PreviewScreen` from `FileScreen` via GoRouter `extra`
- [ ] Fallback for unsupported file types via `url_launcher`

## Phase 4: Auth & Profile
- [ ] Add supabase_flutter dependency
- [ ] Set up flutter_dotenv + .env.example with Supabase URL/anon key
- [ ] Initialize Supabase in `main.dart`
- [ ] Build `LoginScreen` — segmented Log In / Sign Up toggle (email/password)
- [ ] Build `authStateProvider` — wraps Supabase auth stream
- [ ] Build `profiles` table write on signup
- [ ] Guest mode — full browsing without session, gate upload/favorites behind login
- [ ] Build `ProfileScreen` — user info, theme toggle, logout
- [ ] Add route guards for upload/favorites

## Phase 5: Favorites
- [ ] Create `supabase/schema.sql` with favorites table + RLS policies
- [ ] Build `FavoritesService` — addFavorite, removeFavorite, isFavorite, streamFavorites
- [ ] Build `favoritesProvider` (Riverpod)
- [ ] Build `FavoritesScreen` — two-tab layout (Modules / Files)
- [ ] Wire favorite toggle into browse screens (FolderScreen, FileScreen)
- [ ] Gate favorite action behind auth (route to login if null)

## Phase 6: Upload
- [ ] Add file_picker dependency
- [ ] Build `UploadService` — base64 encode, POST to GAS endpoint, progress indicator
- [ ] Add client-side size guard (15MB default)
- [ ] Prefill fullName/email from Supabase profile
- [ ] Validate all fields before submit
- [ ] Build `UploadScreen` — full upload form matching Stitch design
- [ ] Success/failure UI states

## Phase 7: Search
- [ ] Implement client-side search across cached full tree
- [ ] Debounce input (300ms)
- [ ] Case-insensitive + diacritic-insensitive name matching
- [ ] Filter chips (Year, Semester, Module, Type)
- [ ] Build `SearchScreen`

## Phase 8: Polish
- [ ] Skeleton/shimmer loading states for all screens
- [ ] Empty state illustrations/messages
- [ ] Light/dark theme toggle backed by shared_preferences (ThemeModeController)
- [ ] Error handling sweep — retry buttons, error banners
- [ ] Bottom navigation bar (Home, Search, Favorites, Upload, Profile)
- [ ] Run `flutter analyze` — 0 warnings

## Testing
- [ ] Unit tests: DriveApiService path-joining/encoding logic
- [ ] Unit tests: UploadService payload construction
- [ ] Widget tests for key screens

## Infrastructure
- [x] Create `.env.example` with Supabase keys template
- [x] Add `.env` to `.gitignore`
- [x] Add `.env` to pubspec.yaml assets
- [x] Create `EnvKeys` constants class for dotenv access
- [x] `flutter_lints` included
- [ ] Final `flutter analyze` pass before release
