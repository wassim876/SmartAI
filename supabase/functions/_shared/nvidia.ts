// Shared NVIDIA NIM config + Supabase client helpers.
import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2';

export const NVIDIA_API_KEY = Deno.env.get('NVIDIA_API_KEY') ?? '';
export const NIM_BASE =
  Deno.env.get('NIM_BASE_URL') ?? 'https://integrate.api.nvidia.com/v1';

export interface ChatModel {
  /** NVIDIA NIM model id, sent verbatim as `model` in the completions call. */
  id: string;
  /** Human label for the in-app picker. */
  label: string;
  /** Can accept image_url content parts (i.e. usable for the vision path). */
  vision: boolean;
}

// The models the client is allowed to pick from. The client sends a `model`
// id; anything not on this list is rejected with 400 rather than forwarded to
// NVIDIA, so a caller can't bill arbitrary (or huge) models to our key.
//
// Every entry below was verified end-to-end against our own API key on
// 2026-08-30. Two things to know before editing this list:
//
//  1. NVIDIA retires models. A dead id returns HTTP 410 and every request
//     fails. `meta/llama-3.1-8b-instruct` (the old hardcoded default) died on
//     2026-08-26 and took chat + translation down with it.
//  2. The public catalog is NOT the same as what our account can call.
//     `curl https://integrate.api.nvidia.com/v1/models` lists ~83 models, but
//     most return 404 "Not found for account" for us. Always probe a candidate
//     with a real request before adding it here.
export const CHAT_MODELS: ChatModel[] = [
  {
    id: 'nvidia/nemotron-3.5-lightning-30b-a3b',
    label: 'Nemotron 3.5 Lightning',
    vision: false,
  },
  {
    id: 'nvidia/nemotron-3-super-120b-a12b',
    label: 'Nemotron 3 Super',
    vision: false,
  },
  {
    id: 'openai/gpt-oss-20b',
    label: 'GPT-OSS 20B',
    vision: false,
  },
  {
    id: 'meta/llama-3.2-90b-vision-instruct',
    label: 'Llama 3.2 90B Vision',
    vision: true,
  },
  {
    id: 'meta/llama-3.2-11b-vision-instruct',
    label: 'Llama 3.2 11B Vision',
    vision: true,
  },
];

/// Used when the caller doesn't pick a model. Env-overridable so a retirement
/// can be worked around without a redeploy.
///
/// The Nemotron models are reasoning-capable: with a tight `max_tokens` they
/// can get cut off mid-chain-of-thought and return raw "thinking" text. At the
/// 1024-token default below they answer cleanly — don't lower that much.
export const DEFAULT_CHAT_MODEL =
  Deno.env.get('NIM_CHAT_MODEL') ?? 'nvidia/nemotron-3.5-lightning-30b-a3b';

/// Used whenever the request carries an image, regardless of the picked model.
export const DEFAULT_VISION_MODEL =
  Deno.env.get('NIM_VISION_MODEL') ?? 'meta/llama-3.2-90b-vision-instruct';

/// Resolves the model to call.
///
/// Returns `null` when [requested] is set but not allowlisted — callers should
/// turn that into a 400. A requested text-only model combined with an image
/// silently falls back to [DEFAULT_VISION_MODEL] (the response reports which
/// model actually ran, so the UI can show it).
export function resolveChatModel(
  requested: string | undefined,
  wantsVision: boolean,
): ChatModel | null {
  if (requested) {
    const picked = CHAT_MODELS.find((m) => m.id === requested);
    if (!picked) return null;
    if (!wantsVision || picked.vision) return picked;
    // Picked model can't see images — fall through to the vision default.
  }

  const fallbackId = wantsVision ? DEFAULT_VISION_MODEL : DEFAULT_CHAT_MODEL;
  return (
    CHAT_MODELS.find((m) => m.id === fallbackId) ??
      // An env override may name a model that isn't on the list; honour it.
      { id: fallbackId, label: fallbackId, vision: wantsVision }
  );
}

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
