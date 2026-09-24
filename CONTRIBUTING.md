# Contributing to CS Bouira

Thanks for helping! This app is built by students for students, and every bug report, translation fix and pull request helps.

## Ways to contribute

- **Report a bug or suggest a feature:** open an [issue](https://github.com/A7medAmine/csbouira_app/issues/new/choose) using one of the templates.
- **Improve translations:** Arabic, French and English strings live in `lib/l10n/`. See [Translations](#translations) below.
- **Fix bugs or build features:** see [Pull requests](#pull-requests) below.
- **Report a security issue:** please **don't** open a public issue. Follow [SECURITY.md](SECURITY.md) instead.

Course material (missing files, wrong files) is managed on the CS Bouira Drive, not in this repository. Use the in-app **Upload** screen to contribute files.

## Getting set up

Follow [docs/setup.md](docs/setup.md). Browsing works as soon as you have a `.env`. Accounts need your own free Supabase project.

Read [docs/architecture.md](docs/architecture.md) to find your way around the code.

## Pull requests

1. **Open an issue first** for anything bigger than a small fix, so we can agree on the approach before you spend time on it.
2. Fork the repo and create a branch from `main`, e.g. `fix/favorites-sync` or `feat/dark-mode-toggle`.
3. Make your change. Keep each PR focused on one thing.
4. Before pushing, make sure all of these pass:

   ```bash
   dart format lib test
   flutter analyze        # no issues
   flutter test
   ```

5. Test on a real device or emulator, in at least one LTR language and in Arabic (RTL) if you touched the UI.
6. Open the PR and fill in the template. Add screenshots for UI changes.

### Commit messages

Use short, imperative messages with a type prefix:

```
fix: roll back favorite star when the server rejects the change
feat: add pull-to-refresh on module screen
docs: explain Google Sign-In setup
```

Common types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `l10n`.

## Code guidelines

- **Follow the existing structure:** screens in `lib/features/<feature>/`, network and storage code in `lib/data/services/`, state in `lib/data/providers/`. Widgets should not call Supabase or `http` directly.
- **Never hardcode user-facing text.** Add it to the ARB files and use `AppLocalizations.of(context)!`.
- **Use theme values**, not raw `Color(0x…)` literals: `Theme.of(context).colorScheme`, `AppSpacing`, `AppRadius`.
- **Stay RTL-safe:** use `EdgeInsetsDirectional`, `AlignmentDirectional` and `start`/`end` instead of `left`/`right`.
- **Handle failure:** network calls need a timeout, and errors should reach the user as a friendly localized message (see `core/error_messages.dart`), never as a raw exception string.
- **Debug logging:** wrap verbose logs in `if (!kReleaseMode)` and never log tokens, passwords or personal data.
- **Database changes:** add a new `supabase/migration_00N.sql` file. Make it safe to run twice (`IF NOT EXISTS`, `CREATE OR REPLACE`, `DROP … IF EXISTS`), and keep RLS on every table. Describe the change in your PR.
- **Tests:** new logic in `lib/data/` should come with unit tests in `test/data/`.

## Translations

1. Add or edit the key in `lib/l10n/app_en.arb`, the template file. Every new key needs an `@key` entry with a `description`, and `placeholders` if it has parameters.
2. Add the same key to `app_fr.arb` and `app_ar.arb`. Your change is **incomplete** without all three.
3. Regenerate the Dart classes:

   ```bash
   flutter gen-l10n
   ```

4. Commit both the `.arb` changes and the regenerated `app_localizations*.dart` files.

For Arabic, prefer natural Modern Standard Arabic as used in university settings, and check the result on a device, since RTL layout issues only show up there.

## Releases

*Maintainers only.*

1. Bump `version:` in `pubspec.yaml`, e.g. `1.0.3+3`. Always increase the build number.
2. Commit, then tag and push:

   ```bash
   git tag v1.0.3
   git push origin v1.0.3
   ```

3. `.github/workflows/release.yml` builds the APK with the repository secrets (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GOOGLE_SERVER_CLIENT_ID`, `GOOGLE_ANDROID_CLIENT_ID`) and publishes a GitHub Release. Installed apps pick it up through the in-app updater.
4. If the release depends on a database change, apply the migration to the production Supabase project **before** pushing the tag.

## Code of conduct

Be respectful and constructive. Harassment, discrimination or personal attacks are not tolerated in issues, pull requests or discussions. Maintainers may remove content or block users who break this rule.
