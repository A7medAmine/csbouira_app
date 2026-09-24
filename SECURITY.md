# Security policy

## Supported versions

Only the [latest release](https://github.com/A7medAmine/csbouira_app/releases/latest) receives security fixes. The app updates itself, so please reproduce issues on the latest version.

## Reporting a vulnerability

**Please do not open a public issue for security problems.**

Report privately through GitHub: go to the repository's **Security** tab → **Report a vulnerability**. Include:

- what the issue is and what an attacker could do with it
- steps to reproduce (app version, requests or code)
- any suggested fix

You should get a reply within 7 days. Once a fix is released, you will be credited in the release notes unless you prefer not to be.

## Scope

In scope:

- this app's code
- the SQL and Row Level Security policies in `supabase/`
- how the app talks to its backends

Out of scope:

- the Supabase **anon key** and project URL. They are public by design and ship inside every APK; data is protected by Row Level Security, so a report needs to show an actual RLS bypass.
- denial-of-service or volume testing against the production backends
- the content of course files on the CS Bouira Drive

Please test only against your own Supabase project (see [docs/setup.md](docs/setup.md)), never against production user data.

## Known issues

- **Upload endpoint:** uploads are not tied to a verified account. Leaderboard credit is protected separately: it can only be recorded through the rate-limited `record_upload` RPC.
- **`check_email_exists`:** the forgot-password flow can reveal whether an email is registered. Planned for removal.
