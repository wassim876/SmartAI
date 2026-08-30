// nim-models — lists the chat models the client may pick from.
// The allowlist lives server-side (see _shared/nvidia.ts) so retiring or
// adding a model is a function deploy, not an app release.
import { corsHeaders, json } from '../_shared/cors.ts';
import {
  CHAT_MODELS,
  DEFAULT_CHAT_MODEL,
  DEFAULT_VISION_MODEL,
  userClient,
} from '../_shared/nvidia.ts';

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

    return json({
      models: CHAT_MODELS,
      defaultModel: DEFAULT_CHAT_MODEL,
      visionModel: DEFAULT_VISION_MODEL,
    });
  } catch (e) {
    return json({ error: 'internal', message: String(e) }, 500);
  }
});
