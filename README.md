# SmartAI

A cross-platform AI assistant app — Flutter frontend, **Supabase** backend (Postgres + Auth + Storage + Realtime), and **NVIDIA NIM** hosted models for AI. Includes a full admin panel with real analytics.

## Features

**User app**
- Email / password authentication (Supabase Auth)
- AI chat with conversation history
- Image understanding (vision)
- Speech-to-text (voice input) and text-to-speech (voice output)
- Translation
- Per-user daily usage limits, premium tier, profile with avatar upload

**Admin panel**
- Real-time dashboard: KPIs with month-over-month deltas, 14-day activity trend, AI-service usage, user growth, top users, recent reviews/activity
- User management, chat logs, notifications, reviews
- AI-services usage metrics and analytics
- CSV report exports (users, AI usage, reviews, activity log)

## Architecture

```
Flutter app ──► Supabase (Postgres + Auth + Storage + Realtime)
     │                 ▲
     │                 │ JWT
     └──► Supabase Edge Functions (Deno) ──► NVIDIA NIM
                 (hold the NVIDIA key,        (integrate.api.nvidia.com,
                  enforce usage quota)         Speech NIM)
```

- **No API keys on the client.** All AI calls go through Supabase Edge Functions (`nim-chat`, `nim-translate`, `nim-transcribe`, `nim-tts`) which hold `NVIDIA_API_KEY` server-side and enforce the per-user quota via a Postgres RPC.
- **Firebase** is retained **only** for push notifications (FCM). Auth/database/storage are entirely Supabase.
- Row-Level Security scopes every table to its owner; admins get cross-user read access via an `is_admin()` policy helper.

## Tech stack

| Layer | Tech |
|---|---|
| App | Flutter (Dart), Provider, fl_chart |
| Backend | Supabase (Postgres, GoTrue, Storage, Realtime, Edge Functions/Deno) |
| AI | NVIDIA NIM — chat/vision `meta/llama-3.x`, Speech NIM (ASR/TTS) |
| Push | Firebase Cloud Messaging |

## Repository layout

```
frontend/            Flutter app
  lib/
    core/            Supabase config + client
    models/          data models
    providers/       state management (auth, user, theme, language)
    services/        auth, data (PostgREST/Realtime), AI (Edge Functions)
    screens/         user/ and admin/ screens
    widgets/         shared + admin widgets
supabase/
  migrations/        schema, RLS, functions, admin stats RPC
  functions/         Edge Functions (nim-*, admin-*) + .env (gitignored)
```

## Local development

Requires the **Supabase CLI**, a container runtime, and **Flutter**. This project is developed against a local Supabase stack.

### 1. Container runtime (Podman example)

The Supabase stack runs in containers. On macOS with rootless **Podman**, containers must be on a network whose DNS forwards externally, otherwise the Edge Functions can't reach NVIDIA:

```bash
brew install supabase/tap/supabase podman
podman machine init --cpus 4 --memory 6144   # uses the applehv provider
podman machine start
podman network create --dns 8.8.8.8 --dns 1.1.1.1 smartai_net
export DOCKER_HOST="unix://$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}')"
```

> Docker Desktop / Colima also work; the `smartai_net` DNS step is a Podman-rootless workaround.

### 2. Start Supabase + Edge Functions

```bash
supabase start --network-id smartai_net
supabase functions serve --network-id smartai_net --env-file supabase/functions/.env
```

`supabase status` prints the local API URL, keys, and Studio URL. `analytics` is disabled in `config.toml` (it hangs the stack under Podman).

### 3. Configure the NVIDIA key

Create `supabase/functions/.env` (gitignored) with a key from [build.nvidia.com](https://build.nvidia.com/settings/api-keys):

```
NVIDIA_API_KEY=nvapi-...
# optional overrides:
# NIM_CHAT_MODEL=meta/llama-3.1-8b-instruct
# NIM_VISION_MODEL=meta/llama-3.2-11b-vision-instruct
```

### 4. Run the app

```bash
cd frontend
flutter pub get
flutter run          # or: flutter run -d macos / -d chrome
```

The app points at the local Supabase URL (`127.0.0.1:54321`, `10.0.2.2` on the Android emulator). To create an admin, set `is_admin = true` on a row in the `profiles` table.

## Common commands

```bash
# app
cd frontend && flutter analyze && flutter test
flutter build macos --debug

# database
supabase db reset --network-id smartai_net    # replays migrations locally
supabase migration new <name>

# edge functions
supabase functions deploy <name>
```

## Notes

- Speech-to-text / text-to-speech use NVIDIA's hosted Speech NIM endpoints; confirm the exact model IDs at build.nvidia.com.
- The macOS build needs the network-client, microphone, and user-selected-file entitlements (already configured in `macos/Runner/*.entitlements`).
