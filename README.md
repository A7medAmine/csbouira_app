# CS Bouira

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.29.3-02569B?logo=flutter)](https://flutter.dev)
[![Latest release](https://img.shields.io/github/v/release/A7medAmine/csbouira_app)](https://github.com/A7medAmine/csbouira_app/releases/latest)

An open-source Android app for Computer Science students at the University of Bouira. Browse, preview, download and share course material (courses, TDs, TPs, exams) organized by year, semester and module — in Arabic, French or English.

<!--
Screenshots: add images to docs/screenshots/ and uncomment.
<p align="center">
  <img src="docs/screenshots/home.png" width="200" alt="Home">
  <img src="docs/screenshots/module.png" width="200" alt="Module">
  <img src="docs/screenshots/preview.png" width="200" alt="Preview">
  <img src="docs/screenshots/upload.png" width="200" alt="Upload">
</p>
-->

## Download

Grab the latest APK from the [Releases page](https://github.com/A7medAmine/csbouira_app/releases/latest). The app checks GitHub Releases for new versions and can download and install updates itself.

## Features

- **Browse** every year (Licence 1 → Master 2), semester, module and folder, plus books, exercises and curated online resources.
- **Preview** PDFs, images and documents in-app, or open them in another app.
- **Search** modules and files across the whole catalogue, ignoring accents and small typos, with year, module and category filters.
- **Past exams**: every exam and test of a semester, grouped by module, with corrections flagged.
- **What's new**: files added in the last two weeks; follow a module to get a notification when new files arrive.
- **Favorites** for modules, files and online resources — works as a guest and syncs to your account when you sign in.
- **Offline downloads** you can open without a connection, one file at a time or a whole module at once.
- **Upload** material from your device or scan paper documents with the camera.
- **Leaderboard** of the top contributors.
- **Sharing**: share a file as a `csbouira://file/…` link or QR code; scanning it with the camera opens the app.
- **Home screen widget** (Android) with your recently opened files.
- **Light, dark or system theme.**
- **Accounts** with email/password or Google Sign-In, including password reset by email code.
- **Three languages**: العربية (RTL), Français, English.

## Tech stack

| Area | Choice |
| --- | --- |
| Framework | Flutter 3.29 (Dart 3.7), Android |
| State management | Riverpod 2 |
| Routing | go_router |
| Catalogue data | [CS Bouira Drive API](api.md) (read-only, backed by Google Drive) |
| Accounts, favorites, leaderboard | Supabase (Auth + Postgres with row-level security) |
| Uploads | Google Apps Script endpoint that stores files in Drive |
| Localization | `flutter_localizations` + ARB files |

See [docs/architecture.md](docs/architecture.md) for how the pieces fit together.

## Quick start

```bash
git clone https://github.com/A7medAmine/csbouira_app.git
cd csbouira_app
cp .env.example .env      # then fill in the values
flutter pub get
flutter run
```

Browsing works as soon as the app starts, since the Drive API is public. Accounts, favorites sync and the leaderboard need a Supabase project: follow **[docs/setup.md](docs/setup.md)** for the full setup (Supabase, database, Google Sign-In).

## Documentation

| Document | What it covers |
| --- | --- |
| [docs/setup.md](docs/setup.md) | Local development setup: Supabase, database, auth, Google Sign-In |
| [docs/architecture.md](docs/architecture.md) | Project structure, data flow, state management |
| [api.md](api.md) | The Drive API that serves the catalogue |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute, code style, translations, releases |
| [SECURITY.md](SECURITY.md) | How to report a vulnerability |

## Contributing

Contributions are welcome, whether bug reports, translations, fixes or features. Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

## License

[MIT](LICENSE) © 2026 Ahmed Amine. See also the app's [Privacy Policy](PRIVACY_POLICY.md) and [Terms of Use](TERMS_OF_USE.md).
