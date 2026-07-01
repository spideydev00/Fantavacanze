-- =====================================================================
-- join_partner_league
-- Unisce l'utente corrente a una lega partner individuale.
--   - richiede codice invito + parola d'ordine corretta
--   - se è già membro di QUESTA lega, ritorna 'joined' senza modifiche
-- Ritorna { status: 'joined', league: {...} } (senza join_password).
-- =====================================================================
CREATE OR REPLACE FUNCTION public.join_partner_league(
  p_user_name   text,
  p_invite_code text,
  p_password    text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, extensions
AS $$
DECLARE
  user_id              uuid;
  v_league             public.individual_leagues%ROWTYPE;
  v_scope_pw           text;
  updated_participants jsonb;
  league_json          jsonb;
BEGIN
  user_id := auth.uid();
  IF user_id IS NULL THEN
    RAISE EXCEPTION 'Utente non autenticato';
  END IF;

  -- 1) lega + lock
  SELECT *
  INTO v_league
  FROM public.individual_leagues
  WHERE invite_code = p_invite_code
    AND partner IS NOT NULL
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Codice lega non valido';
  END IF;

  -- 2) parola d'ordine dello scope (turno se travel, altrimenti destinazione)
  IF v_league.partner_round_id IS NOT NULL THEN
    SELECT join_password INTO v_scope_pw FROM public.partner_rounds WHERE id = v_league.partner_round_id;
  ELSE
    SELECT join_password INTO v_scope_pw FROM public.partner_destinations WHERE id = v_league.partner_destination_id;
  END IF;

  IF v_scope_pw IS NOT NULL AND p_password IS DISTINCT FROM v_scope_pw THEN
    RAISE EXCEPTION 'Parola d''ordine errata';
  END IF;

  updated_participants := COALESCE(v_league.participants, '[]'::jsonb);

  -- 3) già membro di questa lega -> ritorno senza modifiche
  IF EXISTS (
    SELECT 1 FROM jsonb_array_elements(updated_participants) AS p
    WHERE p->>'userId' = user_id::text
  ) THEN
    RETURN jsonb_build_object(
      'status', 'joined',
      'league', row_to_json(v_league)::jsonb
                  || jsonb_build_object('league_type', 'individual')
    );
  END IF;

  -- 4) aggiungo il partecipante
  updated_participants := updated_participants || jsonb_build_object(
    'type',       'individual',
    'userId',     user_id,
    'name',       p_user_name,
    'points',     0,
    'malusTotal', 0,
    'bonusTotal', 0
  );

  UPDATE public.individual_leagues
  SET participants = updated_participants,
      updated_at   = now()
  WHERE id = v_league.id
  RETURNING row_to_json(individual_leagues.*)::jsonb INTO league_json;

  RETURN jsonb_build_object(
    'status', 'joined',
    'league', league_json || jsonb_build_object('league_type', 'individual')
  );
END;
$$;
