// admin-delete-user — hard-deletes another user's auth account (service role).
// Deleting the auth.users row cascades to profiles and all owned data
// (FK ... on delete cascade). Caller must be an admin.
import { corsHeaders, json } from '../_shared/cors.ts';
import { adminClient, userClient } from '../_shared/nvidia.ts';

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  const authHeader = req.headers.get('Authorization');
  if (!authHeader) return json({ error: 'Missing authorization' }, 401);

  try {
    const caller = userClient(authHeader);
    const { data: auth } = await caller.auth.getUser();
    if (!auth?.user) return json({ error: 'Unauthorized' }, 401);
    const { data: isAdmin } = await caller.rpc('is_admin');
    if (isAdmin !== true) return json({ error: 'Admin access required' }, 403);

    const body = await req.json();
    const userId: string = body.user_id;
    if (!userId) return json({ error: 'user_id is required' }, 400);
    if (userId === auth.user.id) {
      return json({ error: 'Cannot delete your own account here' }, 400);
    }

    const admin = adminClient();
    const { error } = await admin.auth.admin.deleteUser(userId);
    if (error) return json({ error: error.message }, 400);

    return json({ ok: true });
  } catch (e) {
    return json({ error: 'internal', message: String(e) }, 500);
  }
});
