# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository layout

- `frontend/` — Flutter app (`smartai`); targets Android, iOS, web, macOS, Linux, Windows.
- `supabase/` — the backend: Postgres migrations (schema + RLS + RPCs) and Edge Functions (Deno).

## Architecture

**Supabase is the single backend; NVIDIA NIM provides the AI; Firebase is retained only for push (FCM).**

- **Auth + data + storage + realtime → Supabase.** `lib/services/auth_service.dart` (email/password only) and `lib/services/supabase_data_service.dart` (PostgREST reads/writes + `.stream()` realtime) talk to the local stack. The global client is `supabase` from `lib/core/supabase_config.dart`.
- **AI → Supabase Edge Functions → NVIDIA NIM.** `lib/services/ai_service.dart` calls `functions.invoke` for `nim-chat` (chat + vision), `nim-translate`, `nim-transcribe`, `nim-tts`. The functions (in `supabase/functions/`) hold `NVIDIA_API_KEY` server-side, verify the caller's JWT, and enforce the per-user daily quota via the `increment_daily_messages()` RPC. The client never sees the NVIDIA key. Two `admin-*` functions use the service-role key for privileged user create/delete.
- **Firebase** = `firebase_core` + `firebase_messaging` only (FCM). `firebase_options.dart` / `google-services.json` are kept for that. There is **no** Firestore/Firebase-Auth/Storage anymore.
- **RLS everywhere.** Every table has row-level security; owner-scoped by `auth.uid() = user_id`. Admins get cross-user read via the `public.is_admin()` SECURITY DEFINER helper. A `handle_new_user` trigger auto-creates a `profiles` row on signup; a trigger guards privileged profile fields from non-admin escalation.

### Frontend structure (`frontend/lib/`)

- State is **Provider**; `main.dart` registers `AuthProvider`, `UserProvider`, `ThemeProvider`, `LanguageProvider`. `AuthProvider` is the hub — wraps the auth + data services, listens to `supabase.auth.onAuthStateChange`, and holds the in-memory user + realtime stream data.
- Routing is a static named-`routes` map in `main.dart`. `_AuthGate` (`/`) resolves the Supabase session and redirects to `/admin/dashboard` (if `isAdmin`) or `/home`, else `/login`.
- Admin screens under `lib/screens/admin/**` are wrapped in `AdminLayout`; user screens under `lib/screens/user/**`.
- Theming in `lib/theme/` (`dark_mode_helpers.dart` exposes the `D.*` color helpers used everywhere). Localization is hand-rolled in `lib/l10n/app_localizations.dart`.

### Backend structure (`supabase/`)

- `migrations/` — the init migration builds all tables (`profiles`, `chat_sessions`, `chat_messages`, `image_analyses`, `speech_transcriptions`, `translations`, `user_activities`, `reviews`, `notifications`), their RLS policies, the `is_admin()` / `increment_daily_messages()` / `handle_new_user` functions, the `avatars` storage bucket, and the realtime publication. A later migration adds the `admin_dashboard_stats()` RPC (one admin-guarded call returning all dashboard aggregates).
- `functions/` — Deno Edge Functions. `_shared/` holds CORS + NVIDIA config helpers (model ids are env-overridable via `functions/.env`).

## Commands

```bash
# Flutter (from frontend/)
flutter pub get
flutter analyze
flutter test                       # flutter test test/foo_test.dart for one file
flutter run -d macos               # or -d chrome, etc.
flutter build macos --debug

# Supabase (from repo root; see the Podman note below for --network-id)
supabase start --network-id smartai_net
supabase functions serve --network-id smartai_net --env-file supabase/functions/.env
supabase migration new <name>
supabase db reset --network-id smartai_net    # replays migrations on a fresh local DB
```

`NVIDIA_API_KEY` lives in `supabase/functions/.env` (gitignored). To make a user an admin, set `is_admin = true` on their `profiles` row.

## Critical: running Supabase locally under Podman

Podman rootless containers can't forward external DNS via the default network's aardvark-dns, so the Edge Functions can't reach NVIDIA. Both `supabase start` **and** `supabase functions serve` must run on a network whose DNS forwards externally:

```bash
podman network create --dns 8.8.8.8 --dns 1.1.1.1 smartai_net   # one-time (recreate if the machine resets)
export DOCKER_HOST="unix://$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}')"
```

`functions serve` recreates the edge-runtime container, so it **also** needs `--network-id smartai_net` or it drops back onto the non-forwarding default network. Also: `[analytics] enabled = false` in `config.toml` (analytics/vector hang `supabase start` under Podman), and `supabase db reset` hangs on the post-apply restart even though the migration commits — kill it once the tables exist.

To run raw SQL locally (the CLI `db query` may hang under Podman), exec into the DB container:
`podman exec -i supabase_db_SmartAi psql -U postgres -c "<sql>"`.

## Conventions

- Supabase columns are **snake_case**; the Dart models map to them (`UserModel.fromMap`/`toMap`). The data service aliases legacy camelCase write keys (e.g. `isPremium` → `is_premium`) in `_cols`, so existing call sites keep working.
- Many async calls deliberately swallow errors (`try { ... } catch (_) {}`, `debugPrint`) so auxiliary actions (activity logging, admin notifications) never block the primary flow — preserve this.
- `AuthProvider` defers `notifyListeners()` via `SchedulerBinding.addPostFrameCallback` (`_safeNotify`) to avoid setState-during-build on realtime updates — follow this for new notifying paths.
- SECURITY DEFINER SQL functions must `set search_path = ''` and fully-qualify names; grant table privileges to `service_role` (it bypasses RLS but still needs grants) as well as `authenticated`.
- macOS entitlements (`macos/Runner/*.entitlements`) need network-client (Supabase/NVIDIA), audio-input (speech), and user-selected file read-write (avatar upload / report export). New native capabilities require updating both entitlement files + a full rebuild.
