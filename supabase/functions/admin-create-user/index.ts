// admin-create-user — creates another user's auth account (service role).
// The caller must be an admin (verified via their own JWT + profiles.is_admin).
import { corsHeaders, json } from '../_shared/cors.ts';
import { adminClient, userClient } from '../_shared/nvidia.ts';

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  const authHeader = req.headers.get('Authorization');
  if (!authHeader) return json({ error: 'Missing authorization' }, 401);

  try {
    // 1) Verify the caller is an authenticated admin.
    const caller = userClient(authHeader);
    const { data: auth } = await caller.auth.getUser();
    if (!auth?.user) return json({ error: 'Unauthorized' }, 401);
    const { data: isAdmin } = await caller.rpc('is_admin');
    if (isAdmin !== true) return json({ error: 'Admin access required' }, 403);

    const body = await req.json();
    const email: string = body.email;
    const password: string = body.password;
    const username: string = body.username ?? email?.split('@')[0] ?? 'user';
    const wantAdmin: boolean = body.is_admin ?? false;
    const wantPremium: boolean = body.is_premium ?? false;
    if (!email || !password) {
      return json({ error: 'email and password are required' }, 400);
    }

    // 2) Create the auth user with the service role (fires handle_new_user).
    const admin = adminClient();
    const { data: created, error: createErr } = await admin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { username, display_name: username },
    });
    if (createErr || !created?.user) {
      return json({ error: createErr?.message ?? 'create failed' }, 400);
    }

    // 3) Apply admin/premium flags to the freshly-created profile.
    if (wantAdmin || wantPremium) {
      await admin
        .from('profiles')
        .update({ is_admin: wantAdmin, is_premium: wantPremium })
        .eq('id', created.user.id);
    }

    return json({ id: created.user.id });
  } catch (e) {
    return json({ error: 'internal', message: String(e) }, 500);
  }
});
