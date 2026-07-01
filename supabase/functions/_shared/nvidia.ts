// Shared NVIDIA NIM config + Supabase client helpers.
import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2';

export const NVIDIA_API_KEY = Deno.env.get('NVIDIA_API_KEY') ?? '';
export const NIM_BASE =
  Deno.env.get('NIM_BASE_URL') ?? 'https://integrate.api.nvidia.com/v1';

// Model ids are env-overridable — swapping a model is a one-line .env change.
// Verify current ids at build.nvidia.com; these are sensible defaults.
// Verified available on the free tier (2026-07). Swap to a larger model
// (e.g. meta/llama-3.3-70b-instruct) via NIM_CHAT_MODEL in functions/.env.
export const CHAT_MODEL =
  Deno.env.get('NIM_CHAT_MODEL') ?? 'meta/llama-3.1-8b-instruct';
export const VISION_MODEL =
  Deno.env.get('NIM_VISION_MODEL') ?? 'meta/llama-3.2-90b-vision-instruct';
export const ASR_MODEL = Deno.env.get('NIM_ASR_MODEL') ?? '';
export const TTS_MODEL =
  Deno.env.get('NIM_TTS_MODEL') ?? 'magpie-tts-multilingual';
export const TTS_VOICE = Deno.env.get('NIM_TTS_VOICE') ?? 'Magpie-Multilingual.EN-US.Sofia';

/// A Supabase client scoped to the CALLER's JWT, so RLS + auth.uid() apply
/// (needed for the quota RPC and admin checks).
export function userClient(authHeader: string): SupabaseClient {
  return createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    { global: { headers: { Authorization: authHeader } }, auth: { persistSession: false } },
  );
}

/// A service-role client that bypasses RLS — use ONLY after verifying the
/// caller is authorized (e.g. an admin).
export function adminClient(): SupabaseClient {
  return createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false } },
  );
}
