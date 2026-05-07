-- Aggiorna la RPC reject_daily_challenge per popolare is_rejected = true
-- su user_daily_challenges. is_pending_approval resta true per impedire
-- all'utente di rieseguire la sfida (la riga sara rimossa dal cleanup 7AM).

CREATE OR REPLACE FUNCTION public.reject_daily_challenge(p_notification_id text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_project_ref       text := 'afbnmosmovvcsnxpflyi';
  v_url               text := 'https://' || v_project_ref ||
                              '.functions.supabase.co/functions/v1/daily-challenge-rejected';
  v_service_role_key  text;
  v_headers           jsonb;
  v_body              jsonb;

  v_league_id         uuid;
  v_challenge_id      uuid;
  v_user_id           uuid;
  v_challenge_name    text;
  v_challenge_points  numeric;
  v_caller            uuid := auth.uid();
  v_is_admin          boolean := false;
BEGIN
  -- 1) Recupero info dalla notifica admin
  SELECT
    league_id::uuid,
    challenge_id::uuid,
    user_id::uuid,
    challenge_name,
    challenge_points
  INTO
    v_league_id,
    v_challenge_id,
    v_user_id,
    v_challenge_name,
    v_challenge_points
  FROM public.daily_challenges_notifications
  WHERE id::text = p_notification_id::text;

  IF v_league_id IS NULL THEN
    RAISE EXCEPTION 'Notifica giornaliera % non trovata', p_notification_id;
  END IF;

  -- 2) Auth check
  IF v_caller IS NULL THEN
    RAISE EXCEPTION 'Utente non autenticato' USING ERRCODE = '42501';
  END IF;

  SELECT
    EXISTS (
      SELECT 1 FROM public.individual_leagues il
      WHERE il.id = v_league_id AND v_caller::text = ANY (il.admins)
    )
    OR EXISTS (
      SELECT 1 FROM public.team_leagues tl
      WHERE tl.id = v_league_id AND v_caller::text = ANY (tl.admins)
    )
  INTO v_is_admin;

  IF NOT v_is_admin THEN
    RAISE EXCEPTION 'Non sei admin della lega %', v_league_id USING ERRCODE = '42501';
  END IF;

  -- 3) Marca la challenge come rejected. is_pending_approval resta true
  --    cosi l'utente non puo rieseguirla (la riga sara cancellata dal cleanup 7AM).
  --    NB: v_challenge_id arriva da daily_challenges_notifications.challenge_id,
  --    che e' FK a daily_challenges_winter.id, quindi confronto con
  --    user_daily_challenges.challenge_id (non con il PK id).
  UPDATE public.user_daily_challenges
  SET is_rejected = true, is_pending_approval = false
  WHERE user_id::text = v_user_id::text
    AND id::text = v_challenge_id::text
    AND league_id::text = v_league_id::text;

  -- 4) Cancello la notifica admin
  DELETE FROM public.daily_challenges_notifications
  WHERE id::text = p_notification_id::text;

  -- 5) Recupero il service role key dal vault
  SELECT ds.decrypted_secret
  INTO v_service_role_key
  FROM vault.decrypted_secrets ds
  WHERE ds.name = 'SUPABASE_SERVICE_ROLE_KEY'
  LIMIT 1;

  IF v_service_role_key IS NULL OR length(v_service_role_key) < 20 THEN
    RAISE EXCEPTION 'Vault secret SUPABASE_SERVICE_ROLE_KEY mancante o non valido';
  END IF;

  v_headers := jsonb_build_object(
    'Content-Type', 'application/json',
    'Authorization', 'Bearer ' || v_service_role_key,
    'apikey', v_service_role_key
  );

  v_body := jsonb_build_object(
    'user_id',          v_user_id,
    'league_id',        v_league_id,
    'challenge_name',   v_challenge_name,
    'challenge_points', v_challenge_points
  );

  -- 6) Push all'utente attore via Edge Function
  PERFORM net.http_post(
    url     := v_url,
    headers := v_headers,
    body    := v_body
  );
END;
$$;
