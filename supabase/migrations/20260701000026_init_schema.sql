-- SmartAI initial schema: replaces the Firebase Firestore collections.
-- All app tables live in `public`, every one has RLS enabled.
-- Owner model: rows are scoped to auth.uid() = user_id; admins (profiles.is_admin)
-- can read across users for the admin dashboards.

-- ============================================================
-- profiles  (replaces Firestore `users`, keyed to auth.users)
-- ============================================================
create table public.profiles (
  id                   uuid primary key references auth.users(id) on delete cascade,
  username             text,
  email                text,
  display_name         text,
  photo_url            text,
  is_premium           boolean     not null default false,
  is_active            boolean     not null default true,
  is_admin             boolean     not null default false,
  daily_messages_used  integer     not null default 0,
  daily_messages_limit integer     not null default 50,
  created_at           timestamptz not null default now(),
  last_login           timestamptz
);
alter table public.profiles enable row level security;

-- ============================================================
-- Helper: is_admin()  (SECURITY DEFINER to avoid RLS recursion on profiles)
-- Returns whether the CURRENT caller is an admin. Safe to expose: it only
-- ever reveals the caller's own admin bool (keyed on auth.uid()).
-- Defined after `profiles` because SQL function bodies are validated at
-- creation time (check_function_bodies).
-- ============================================================
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    (select p.is_admin from public.profiles p where p.id = (select auth.uid())),
    false
  );
$$;

-- Any authenticated user may read profiles (listing / search, mirrors old rules).
create policy "profiles: authenticated read"
  on public.profiles for select
  to authenticated
  using (true);

-- A user may update their own row; admins may update anyone.
-- (Privileged-field escalation is blocked by the trigger below, not here.)
create policy "profiles: self or admin update"
  on public.profiles for update
  to authenticated
  using  ((select auth.uid()) = id or public.is_admin())
  with check ((select auth.uid()) = id or public.is_admin());

-- Only admins may delete profiles.
create policy "profiles: admin delete"
  on public.profiles for delete
  to authenticated
  using (public.is_admin());

-- Prevent non-admins from escalating their own privileged fields on UPDATE.
create or replace function public.protect_privileged_profile_fields()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  -- Only guard genuine authenticated end-users (JWT role = 'authenticated').
  -- Trusted contexts — service_role (Edge Functions) and the postgres superuser
  -- (no/other JWT role) — may set privileged fields; they've already authorized
  -- the caller.
  if coalesce((select auth.jwt() ->> 'role'), '') = 'authenticated'
     and not public.is_admin() then
    new.is_admin            := old.is_admin;
    new.is_premium          := old.is_premium;
    new.is_active           := old.is_active;
    new.daily_messages_limit:= old.daily_messages_limit;
  end if;
  return new;
end;
$$;

create trigger trg_protect_privileged_profile_fields
  before update on public.profiles
  for each row execute function public.protect_privileged_profile_fields();

-- ============================================================
-- Auto-provision a profile row when a new auth user signs up.
-- ============================================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, username, email, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1), 'user'),
    new.email,
    coalesce(new.raw_user_meta_data->>'display_name',
             new.raw_user_meta_data->>'username',
             'User')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================
-- Server-side usage quota: atomically increment daily messages,
-- raising once the per-user limit is reached. Called by the nim-chat
-- Edge Function so the cap can't be bypassed client-side.
-- ============================================================
create or replace function public.increment_daily_messages()
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  uid   uuid := (select auth.uid());
  used  integer;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;

  update public.profiles
     set daily_messages_used = daily_messages_used + 1
   where id = uid
     and daily_messages_used < daily_messages_limit
  returning daily_messages_used into used;

  if used is null then
    raise exception 'daily message limit reached' using errcode = 'check_violation';
  end if;

  return used;
end;
$$;

-- ============================================================
-- Owned data tables (replace their like-named Firestore collections).
-- ============================================================
create table public.chat_sessions (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  title      text,
  messages   jsonb       not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.chat_messages (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  message    text,
  response   text,
  model      text,
  created_at timestamptz not null default now()
);

create table public.image_analyses (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references auth.users(id) on delete cascade,
  image_url       text,
  analysis_result text,
  image_type      text        not null default 'general',
  created_at      timestamptz not null default now()
);

create table public.speech_transcriptions (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users(id) on delete cascade,
  audio_url     text,
  transcription text,
  duration      numeric     not null default 0,
  created_at    timestamptz not null default now()
);

create table public.translations (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references auth.users(id) on delete cascade,
  original_text   text,
  translated_text text,
  source_lang     text,
  target_lang     text,
  created_at      timestamptz not null default now()
);

create table public.user_activities (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  action     text,
  details    jsonb       not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table public.reviews (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  rating     integer,
  comment    text,
  created_at timestamptz not null default now()
);

-- Helpful indexes for the per-user "where user_id = ? order by created_at desc" reads.
create index on public.chat_sessions         (user_id, created_at desc);
create index on public.chat_messages         (user_id, created_at desc);
create index on public.image_analyses        (user_id, created_at desc);
create index on public.speech_transcriptions (user_id, created_at desc);
create index on public.translations          (user_id, created_at desc);
create index on public.user_activities       (user_id, created_at desc);
create index on public.reviews               (user_id, created_at desc);

-- Owner + admin-read RLS for every owned table, applied uniformly.
do $$
declare t text;
begin
  foreach t in array array[
    'chat_sessions','chat_messages','image_analyses',
    'speech_transcriptions','translations','user_activities','reviews'
  ]
  loop
    execute format('alter table public.%I enable row level security;', t);

    execute format($f$
      create policy "%1$s: owner select" on public.%1$I for select
        to authenticated using ((select auth.uid()) = user_id);
    $f$, t);

    execute format($f$
      create policy "%1$s: admin select" on public.%1$I for select
        to authenticated using (public.is_admin());
    $f$, t);

    execute format($f$
      create policy "%1$s: owner insert" on public.%1$I for insert
        to authenticated with check ((select auth.uid()) = user_id);
    $f$, t);

    execute format($f$
      create policy "%1$s: owner update" on public.%1$I for update
        to authenticated
        using ((select auth.uid()) = user_id)
        with check ((select auth.uid()) = user_id);
    $f$, t);

    execute format($f$
      create policy "%1$s: owner or admin delete" on public.%1$I for delete
        to authenticated using ((select auth.uid()) = user_id or public.is_admin());
    $f$, t);
  end loop;
end $$;

-- ============================================================
-- notifications  (replaces Firestore `admin_notifications`)
-- Admin-facing alerts; user_id is the actor/target (nullable = broadcast).
-- ============================================================
create table public.notifications (
  id         uuid primary key default gen_random_uuid(),
  type       text,
  title      text,
  body       text,
  user_id    uuid references auth.users(id) on delete set null,
  read       boolean     not null default false,
  created_at timestamptz not null default now()
);
alter table public.notifications enable row level security;
create index on public.notifications (created_at desc);

-- Admins see all; a user can see notifications about themselves.
create policy "notifications: admin or self select"
  on public.notifications for select
  to authenticated
  using (public.is_admin() or (select auth.uid()) = user_id);

-- Any authenticated user may raise a notification (e.g. signup fires 'new_user'),
-- but only for themselves as the actor (or a broadcast).
create policy "notifications: authenticated insert"
  on public.notifications for insert
  to authenticated
  with check (user_id is null or (select auth.uid()) = user_id);

-- Only admins mark notifications read / update them.
create policy "notifications: admin update"
  on public.notifications for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- ============================================================
-- Table privileges for the Data API roles (RLS still governs rows).
-- anon gets nothing — the whole app requires authentication.
-- ============================================================
grant usage on schema public to authenticated;
grant select, insert, update, delete on all tables in schema public to authenticated;
grant execute on function public.is_admin(),
                        public.increment_daily_messages() to authenticated;

-- service_role (used by admin Edge Functions) needs table access too; it
-- bypasses RLS but still requires table privileges.
grant usage on schema public to service_role;
grant select, insert, update, delete on all tables in schema public to service_role;

-- ============================================================
-- Storage: avatars bucket (replaces Firebase Storage profile_pics/).
-- Path convention: avatars/{auth.uid()}/<file>. Upsert needs insert+select+update.
-- ============================================================
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

create policy "avatars: public read"
  on storage.objects for select
  using (bucket_id = 'avatars');

create policy "avatars: owner insert"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);

create policy "avatars: owner update"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);

create policy "avatars: owner delete"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);

-- ============================================================
-- Realtime: expose app tables so supabase_flutter `.stream()` receives live
-- updates (the client-side subscriptions in the providers/admin screens).
-- ============================================================
alter publication supabase_realtime add table
  public.profiles,
  public.chat_sessions,
  public.chat_messages,
  public.image_analyses,
  public.speech_transcriptions,
  public.translations,
  public.user_activities,
  public.reviews,
  public.notifications;
