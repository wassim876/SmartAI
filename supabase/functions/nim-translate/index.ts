// nim-translate — translation via an NVIDIA NIM chat model (OpenAI-compatible).
import { corsHeaders, json } from '../_shared/cors.ts';
import { CHAT_MODEL, NIM_BASE, NVIDIA_API_KEY, userClient } from '../_shared/nvidia.ts';

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

    const sourceClause = sourceLang ? ` from ${sourceLang}` : '';
    const nvRes = await fetch(`${NIM_BASE}/chat/completions`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${NVIDIA_API_KEY}`,
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
      body: JSON.stringify({
        model: CHAT_MODEL,
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
    return json({ translation, targetLang });
  } catch (e) {
    return json({ error: 'internal', message: String(e) }, 500);
  }
});
