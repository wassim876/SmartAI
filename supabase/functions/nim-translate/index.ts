// nim-translate — translation via an NVIDIA NIM chat model (OpenAI-compatible).
// Counts against the same per-user daily quota as nim-chat.
import { corsHeaders, json } from '../_shared/cors.ts';
import { NIM_BASE, NVIDIA_API_KEY, resolveChatModel, userClient } from '../_shared/nvidia.ts';

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  const authHeader = req.headers.get('Authorization');
  if (!authHeader) return json({ error: 'Missing authorization' }, 401);

  try {
    const supabase = userClient(authHeader);
    const { data: auth } = await supabase.auth.getUser();
    if (!auth?.user) return json({ error: 'Unauthorized' }, 401);

    const body = await req.json();
    const text: string = body.text ?? '';
    const targetLang: string = body.targetLang ?? 'English';
    const sourceLang: string | undefined = body.sourceLang;
    if (!text.trim()) return json({ error: 'text is required' }, 400);

    // Optional caller-picked model, validated against the allowlist. Resolved
    // before spending quota so a bad id doesn't cost the user a message.
    const model = resolveChatModel(body.model, false);
    if (!model) {
      return json(
        { error: 'unknown_model', message: `Unsupported model: ${body.model}` },
        400,
      );
    }

    // Same server-side quota as nim-chat — translation is a NIM call too, so
    // it must not be a free path around the daily cap.
    const { error: quotaError } = await supabase.rpc('increment_daily_messages');
    if (quotaError) {
      return json(
        { error: 'daily_limit_reached', message: quotaError.message },
        429,
      );
    }

    const sourceClause = sourceLang ? ` from ${sourceLang}` : '';
    const nvRes = await fetch(`${NIM_BASE}/chat/completions`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${NVIDIA_API_KEY}`,
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
      body: JSON.stringify({
        model: model.id,
        messages: [
          {
            role: 'system',
            content:
              `You are a professional translator. Translate the user's text${sourceClause} into ${targetLang}. ` +
              'Return ONLY the translated text, with no quotes, notes, or explanations.',
          },
          { role: 'user', content: text },
        ],
        temperature: 0.2,
        max_tokens: 1024,
        stream: false,
      }),
    });

    if (!nvRes.ok) {
      const detail = await nvRes.text();
      const status = nvRes.status === 429 ? 429 : 502;
      return json({ error: 'nvidia_error', status: nvRes.status, detail }, status);
    }

    const data = await nvRes.json();
    const translation = (data.choices?.[0]?.message?.content ?? '').trim();
    return json({ translation, targetLang, model: model.id });
  } catch (e) {
    return json({ error: 'internal', message: String(e) }, 500);
  }
});
