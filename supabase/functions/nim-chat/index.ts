// nim-chat — chat + image vision via NVIDIA NIM (OpenAI-compatible).
// Enforces the per-user daily message quota server-side before calling NVIDIA.
import { corsHeaders, json } from '../_shared/cors.ts';
import {
  CHAT_MODEL,
  NIM_BASE,
  NVIDIA_API_KEY,
  userClient,
  VISION_MODEL,
} from '../_shared/nvidia.ts';

interface ChatMessage {
  role: string;
  content: string;
}

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
    const messages: ChatMessage[] = body.messages ?? [];
    // Optional image as a data URI: "data:image/jpeg;base64,...."
    const image: string | undefined = body.image;

    // Server-side quota: atomically increment; raises when the cap is hit.
    const { error: quotaError } = await supabase.rpc('increment_daily_messages');
    if (quotaError) {
      return json(
        { error: 'daily_limit_reached', message: quotaError.message },
        429,
      );
    }

    const model = image ? VISION_MODEL : CHAT_MODEL;

    // Attach the image to the final user turn using the OpenAI vision shape.
    const outMessages = messages.map((m) => ({ role: m.role, content: m.content as unknown }));
    if (image && outMessages.length > 0) {
      const last = outMessages[outMessages.length - 1];
      const text = typeof last.content === 'string' ? last.content : '';
      last.content = [
        { type: 'text', text: text || 'Describe this image.' },
        { type: 'image_url', image_url: { url: image } },
      ];
    }

    const nvRes = await fetch(`${NIM_BASE}/chat/completions`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${NVIDIA_API_KEY}`,
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
      body: JSON.stringify({
        model,
        messages: outMessages,
        temperature: body.temperature ?? 0.7,
        max_tokens: body.max_tokens ?? 1024,
        stream: false,
      }),
    });

    if (!nvRes.ok) {
      const detail = await nvRes.text();
      const status = nvRes.status === 429 ? 429 : 502;
      return json({ error: 'nvidia_error', status: nvRes.status, detail }, status);
    }

    const data = await nvRes.json();
    const reply = data.choices?.[0]?.message?.content ?? '';
    return json({ reply, model });
  } catch (e) {
    return json({ error: 'internal', message: String(e) }, 500);
  }
});
