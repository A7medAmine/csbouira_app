# CS Bouira

A Flutter app for browsing and downloading academic resources (courses, exams, exercises) for the Computer Science department at University of Bouira.

## Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Routing**: go_router
- **Data Source**: Custom Drive API

## Features

- Browse years, semesters, modules, and folders
- Search and filter files
- View file previews
- Favorite/bookmark resources
- Upload resources
- Dark theme UI

## Getting Started

```bash
flutter pub get
flutter run
```

## Environment Variables

Copy `.env.example` to `.env` and fill in your Supabase credentials:

```bash
cp .env.example .env
```

Required values (from your Supabase project dashboard → Settings → API):

| Variable           | Description                              |
| ------------------ | ---------------------------------------- |
| `SUPABASE_URL`     | Your Supabase project URL                |
| `SUPABASE_ANON_KEY`| Your Supabase anon/public API key        |

The app loads these via `flutter_dotenv` at startup — no `--dart-define` flags needed.
