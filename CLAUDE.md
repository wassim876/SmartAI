# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository layout

- `frontend/` — Flutter app (`smartai`); targets Android, iOS, web, macOS, Linux, Windows.
- `supabase/` — the backend: Postgres migrations (schema + RLS + RPCs) and Edge Functions (Deno).

## Architecture

**Supabase is the single backend; NVIDIA NIM provides the server-side AI; Firebase is retained only for push (FCM).**

- **Auth + data + storage + realtime → Supabase.** `lib/services/auth_service.dart` (email/password + Google/GitHub OAuth + OTP password reset) and `lib/services/supabase_data_service.dart` (PostgREST reads/writes + `.stream()` realtime). The global client is `supabase` from `lib/core/supabase_config.dart`.
- **`supabase_config.dart` currently points at the HOSTED project** (`bxuwjcliikrolkgyllyo.supabase.co` + publishable key), not the local stack. To develop against `supabase start`, swap `url`/`publishableKey` there for the values `supabase status` prints — and remember Android emulators need `10.0.2.2`, not `127.0.0.1`.
- **AI → Supabase Edge Functions → NVIDIA NIM.** `lib/services/ai_service.dart` calls `functions.invoke` for three functions: `nim-chat` (chat + vision), `nim-translate`, and `nim-models` (the model allowlist). The functions hold `NVIDIA_API_KEY` server-side, verify the caller's JWT, and enforce the per-user daily quota via the `increment_daily_messages()` RPC *before* calling NVIDIA. The client never sees the NVIDIA key. Two `admin-*` functions use the service-role key for privileged user create/delete.
- **Model selection is server-authoritative.** `_shared/nvidia.ts` owns `CHAT_MODELS` (the allowlist), `DEFAULT_CHAT_MODEL`, `DEFAULT_VISION_MODEL` and `resolveChatModel()`. The client sends an optional `model` id; anything off the list is rejected with 400 *before* quota is spent, so a caller can't bill an arbitrary model to the key. `nim-models` serves the list to the app, so retiring or adding a model is a function deploy — not an app release. Requests carrying an image always resolve to a vision-capable model regardless of the pick, and every response echoes the `model` that actually ran.
- **NVIDIA retires models, and that takes the app down.** The old hardcoded `meta/llama-3.1-8b-instruct` reached end-of-life on 2026-08-26 and every chat/translate call started returning 410→502. Two traps when picking a replacement: the public catalog (`curl https://integrate.api.nvidia.com/v1/models`, no auth) lists far more models than a given account can actually call — most return 404 `Not found for account` — so **probe a candidate with a real request before adding it**; and the Nemotron models are reasoning-capable, so a tight `max_tokens` can return raw chain-of-thought instead of an answer (the 1024 default is fine).
- **Speech is on-device, not server-side.** `chat_screen.dart` uses the `speech_to_text` and `flutter_tts` packages directly. There is **no** `nim-transcribe` / `nim-tts` Edge Function, and no ASR/TTS model config. (The README's claim of hosted Speech NIM is stale.) The `speech_transcriptions` table still records on-device results.
- **Firebase** = `firebase_core` + `firebase_messaging` only (FCM). `firebase_options.dart` / `google-services.json` are kept for that. There is **no** Firestore/Firebase-Auth/Storage anymore.
- **RLS everywhere.** Every table has row-level security; owner-scoped by `auth.uid() = user_id`. Admins get cross-user read via the `public.is_admin()` SECURITY DEFINER helper. A `handle_new_user` trigger auto-creates a `profiles` row on signup; `protect_privileged_profile_fields` guards `is_admin`/`is_premium`/limits from non-admin escalation.

### Frontend structure (`frontend/lib/`)

- State is **Provider**; `main.dart` registers exactly three: `ThemeProvider`, `AuthProvider`, `LanguageProvider`. `AuthProvider` is the hub — wraps the auth + data services, listens to `supabase.auth.onAuthStateChange`, and holds the in-memory user plus the realtime stream data (chat history, image analyses, transcriptions, activities).
- Routing is a static named-`routes` map in `main.dart`. `_AuthGate` (`/`) calls `AuthProvider.resolveUser()` and redirects to `/admin/dashboard` (if `isAdmin`) or `/home`, else `/login`. `ForgotPasswordScreen` is pushed directly from the login screen, not routed.
- Admin screens under `lib/screens/admin/**` are wrapped in `AdminLayout`; user screens under `lib/screens/user/**`.
- Theming in `lib/theme/` — `dark_mode_helpers.dart` exposes the `D.*` color helpers (`D.bg(context)`, `D.card`, `D.t1`…) used in place of raw colors everywhere. Localization is hand-rolled in `lib/l10n/app_localizations.dart`: one giant `Map<String, Map<String, String>>` covering 8 locales (en, fr, ar, de, es, tr, ru, zh) — add a key to **every** locale map when adding a string.
- Use `PhotoPickerService` (`file_picker`) rather than `image_picker` for images — `image_picker`'s gallery source doesn't work on macOS.
- Admin report exports are **CSV** (hand-built in `reports_screen.dart` + `FilePicker.saveFile`), despite `syncfusion_flutter_pdf` being a dependency.

### Backend structure (`supabase/`)

- `migrations/20260701000026_init_schema.sql` builds everything: tables (`profiles`, `chat_sessions`, `chat_messages`, `image_analyses`, `speech_transcriptions`, `translations`, `user_activities`, `reviews`, `notifications`), their RLS policies (the owner-scoped ones are generated by a `do $$ ... format()` loop over a table-name array — edit the loop, not per-table copies), the `is_admin()` / `increment_daily_messages()` / `handle_new_user()` / `protect_privileged_profile_fields()` functions, the `avatars` storage bucket, and the `supabase_realtime` publication.
- `migrations/20260701020320_admin_dashboard_stats.sql` adds `admin_dashboard_stats()` — one admin-guarded RPC returning every dashboard aggregate in a single call.
- `functions/_shared/` holds CORS + the NVIDIA config and the two Supabase client factories: `userClient(authHeader)` (caller's JWT, RLS applies — use for quota/ownership) vs `adminClient()` (service role, bypasses RLS — only after verifying the caller is an admin). The two defaults stay env-overridable (`NIM_CHAT_MODEL` / `NIM_VISION_MODEL`) so a model retirement can be worked around without a redeploy.

## Commands

```bash
# Flutter (from frontend/)
nix develop                        # dev shell: Flutter SDK, JDK17, Android SDK, CocoaPods
flutter pub get
flutter analyze
flutter test                       # flutter test test/widget_test.dart for one file
flutter run -d macos               # or -d chrome, -d android, etc.
flutter build macos --debug

# Supabase (from repo root; see the Podman note below for --network-id)
supabase start --network-id smartai_net
supabase functions serve --network-id smartai_net --env-file supabase/functions/.env
supabase migration new <name>
supabase db reset --network-id smartai_net    # replays migrations on a fresh local DB
supabase functions deploy <name>
```

`NVIDIA_API_KEY` lives in `supabase/functions/.env` (gitignored). To make a user an admin, set `is_admin = true` on their `profiles` row.

There is one test file (`frontend/test/widget_test.dart`); it covers self-contained widgets only — `SmartAIApp` can't be pumped directly because `main()` bootstraps Supabase and Firebase first.

## The Nix dev shell (`frontend/flake.nix`)

`nix develop` in `frontend/` is the supported toolchain. Two non-obvious workarounds live in its `shellHook` — preserve them if you touch the flake:

- It uses `mkShellNoCC`, not `mkShell`. The Darwin stdenv's cc-wrapper shadows Apple's clang/ld/lipo and breaks iOS/macOS Xcode builds; the Darwin branch also force-sets `DEVELOPER_DIR` and unsets `CC`/`LD`/`NIX_*FLAGS`.
- It materializes a **writable copy** of the Flutter SDK at `frontend/.flutter-sdk` and re-points `FLUTTER_ROOT`/`PATH` at it, because Android's Gradle composite build and Xcode's in-place `lipo` thinning both need to write into the SDK, which is read-only in the Nix store. Dangling relative `bin/` symlinks and engine `.xcframework`s are repaired during that copy.

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

- Supabase columns are **snake_case**; the Dart models map to them (`UserModel.fromMap`/`toMap`). The data service aliases legacy camelCase write keys (e.g. `isPremium` → `is_premium`) in `_columnAliases`/`_cols`, so existing call sites keep working — add an alias there rather than renaming call sites.
- Many async calls deliberately swallow errors (`try { ... } catch (_) {}`, `debugPrint`) so auxiliary actions (activity logging, admin notifications, Firebase init) never block the primary flow — preserve this.
- `AuthProvider` defers `notifyListeners()` via `SchedulerBinding.addPostFrameCallback` to avoid setState-during-build on realtime updates — follow this for new notifying paths.
- SECURITY DEFINER SQL functions must `set search_path = ''` and fully-qualify names; grant table privileges to `service_role` (it bypasses RLS but still needs grants) as well as `authenticated`.
- Edge Functions all follow the same shape: handle the `OPTIONS` preflight with `corsHeaders`, require an `Authorization` header, build a `userClient(authHeader)` and `getUser()` before doing anything, and return via the shared `json()` helper. `nim-chat` maps a NIM 429 through as a 429 so the client can raise `AiQuotaException`.
- macOS entitlements (`macos/Runner/*.entitlements`) need network-client (Supabase/NVIDIA), audio-input (on-device speech), and user-selected file read-write (avatar upload / CSV export). New native capabilities require updating both entitlement files + a full rebuild.
