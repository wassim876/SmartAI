-- Admin dashboard aggregates. One SECURITY DEFINER RPC (admin-guarded) returns
-- every metric the admin dashboard / AI-services / analytics screens need, so
-- the client makes a single call instead of many cross-user count queries.
create or replace function public.admin_dashboard_stats()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  result jsonb;
begin
  if not public.is_admin() then
    raise exception 'Admin access required' using errcode = 'insufficient_privilege';
  end if;

  with all_requests as (
    select created_at from public.chat_messages
    union all select created_at from public.image_analyses
    union all select created_at from public.speech_transcriptions
    union all select created_at from public.translations
  )
  select jsonb_build_object(
    -- Headline user counts.
    'total_users',        (select count(*) from public.profiles),
    'premium_users',      (select count(*) from public.profiles where is_premium),
    'active_users',       (select count(*) from public.profiles where is_active),
    'admin_users',        (select count(*) from public.profiles where is_admin),
    'active_users_7d',    (select count(distinct user_id) from public.user_activities where created_at >= now() - interval '7 days'),
    'new_users_today',    (select count(*) from public.profiles where created_at >= date_trunc('day', now())),
    'new_users_7d',       (select count(*) from public.profiles where created_at >= now() - interval '7 days'),
    -- Month-over-month deltas (client computes the %).
    'users_this_month',   (select count(*) from public.profiles where created_at >= date_trunc('month', now())),
    'users_prev_month',   (select count(*) from public.profiles where created_at >= date_trunc('month', now()) - interval '1 month' and created_at < date_trunc('month', now())),
    'requests_this_month',(select count(*) from all_requests where created_at >= date_trunc('month', now())),
    'requests_prev_month',(select count(*) from all_requests where created_at >= date_trunc('month', now()) - interval '1 month' and created_at < date_trunc('month', now())),
    -- AI usage totals.
    'total_conversations',(select count(*) from public.chat_messages),
    'total_images',       (select count(*) from public.image_analyses),
    'total_speech',       (select count(*) from public.speech_transcriptions),
    'total_translations', (select count(*) from public.translations),
    'reviews_count',      (select count(*) from public.reviews),
    'avg_rating',         coalesce((select round(avg(rating)::numeric, 1) from public.reviews), 0),
    -- Per-service usage counts.
    'service_breakdown', jsonb_build_array(
      jsonb_build_object('label', 'Chat',        'count', (select count(*) from public.chat_messages)),
      jsonb_build_object('label', 'Images',      'count', (select count(*) from public.image_analyses)),
      jsonb_build_object('label', 'Speech',      'count', (select count(*) from public.speech_transcriptions)),
      jsonb_build_object('label', 'Translation', 'count', (select count(*) from public.translations))
    ),
    -- AI requests per day, last 14 days (activity trend).
    'activity_14d', (
      select coalesce(jsonb_agg(jsonb_build_object('day', d, 'count', c) order by d), '[]'::jsonb)
      from (
        select to_char(date_trunc('day', created_at), 'YYYY-MM-DD') as d, count(*) as c
        from all_requests
        where created_at >= date_trunc('day', now()) - interval '13 days'
        group by 1
      ) a
    ),
    -- New users per month, last 6 months.
    'user_growth', (
      select coalesce(jsonb_agg(jsonb_build_object('month', m, 'count', c) order by m), '[]'::jsonb)
      from (
        select to_char(date_trunc('month', created_at), 'YYYY-MM') as m, count(*) as c
        from public.profiles
        where created_at >= date_trunc('month', now()) - interval '5 months'
        group by 1
      ) g
    ),
    -- Latest activity feed.
    'recent_activity', (
      select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc), '[]'::jsonb)
      from (
        select ua.action, ua.created_at, p.email, p.display_name
        from public.user_activities ua
        left join public.profiles p on p.id = ua.user_id
        order by ua.created_at desc
        limit 8
      ) x
    ),
    -- Most active users by message volume.
    'top_users', (
      select coalesce(jsonb_agg(to_jsonb(t) order by t.message_count desc), '[]'::jsonb)
      from (
        select p.email, p.display_name, p.is_premium, count(cm.id) as message_count
        from public.profiles p
        left join public.chat_messages cm on cm.user_id = p.id
        group by p.id
        order by count(cm.id) desc, p.created_at asc
        limit 5
      ) t
    ),
    -- Latest reviews.
    'recent_reviews', (
      select coalesce(jsonb_agg(to_jsonb(rv) order by rv.created_at desc), '[]'::jsonb)
      from (
        select r.rating, r.comment, r.created_at, p.email, p.display_name
        from public.reviews r
        left join public.profiles p on p.id = r.user_id
        order by r.created_at desc
        limit 5
      ) rv
    )
  ) into result;

  return result;
end;
$$;

grant execute on function public.admin_dashboard_stats() to authenticated;
