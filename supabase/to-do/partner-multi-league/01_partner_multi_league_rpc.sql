BEGIN;

-- Permette allo stesso utente di creare piu leghe partner per lo stesso
-- turno/destinazione. La firma resta invariata per evitare overload PostgREST.
CREATE OR REPLACE FUNCTION public.create_partner_league(
  p_user_name       text,
  p_destination_id  uuid,
  p_name            text,
  p_password        text,
  p_description     text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, extensions
AS $$
DECLARE
  user_id          uuid;
  v_partner        public.partners%ROWTYPE;
  v_dest           public.partner_destinations%ROWTYPE;
  v_round_id       uuid;
  v_scope_pw       text;
  v_league_id      uuid := gen_random_uuid();
  v_invite_code    text;
  v_initial_part   jsonb;
  league_json      jsonb;
BEGIN
  user_id := auth.uid();
  IF user_id IS NULL THEN
    RAISE EXCEPTION 'Utente non autenticato';
  END IF;

  SELECT * INTO v_dest
  FROM public.partner_destinations
  WHERE id = p_destination_id AND is_active = true;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Destinazione non trovata o non attiva';
  END IF;

  SELECT * INTO v_partner
  FROM public.partners
  WHERE id = v_dest.partner_id AND is_active = true;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Partner non trovato o non attivo';
  END IF;

  IF v_partner.kind = 'travel' THEN
    v_round_id := public.get_active_partner_round(p_destination_id);
    IF v_round_id IS NULL THEN
      RAISE EXCEPTION 'Nessun turno disponibile per questa destinazione';
    END IF;
  ELSE
    v_round_id := NULL;
  END IF;

  IF v_round_id IS NOT NULL THEN
    SELECT join_password INTO v_scope_pw
    FROM public.partner_rounds
    WHERE id = v_round_id;
  ELSE
    v_scope_pw := v_dest.join_password;
  END IF;

  IF v_scope_pw IS NOT NULL AND p_password IS DISTINCT FROM v_scope_pw THEN
    RAISE EXCEPTION 'Parola d''ordine errata';
  END IF;

  LOOP
    v_invite_code := v_partner.code_prefix || substr(md5(gen_random_uuid()::text), 1, 8);
    EXIT WHEN NOT EXISTS (
      SELECT 1 FROM public.individual_leagues WHERE invite_code = v_invite_code
    );
  END LOOP;

  v_initial_part := jsonb_build_object(
    'type',       'individual',
    'userId',     user_id,
    'name',       p_user_name,
    'points',     0,
    'malusTotal', 0,
    'bonusTotal', 0
  );

  INSERT INTO public.individual_leagues (
    id, name, description, invite_code, admins,
    rules, participants, events, memories,
    partner, partner_destination_id, partner_round_id,
    created_at, updated_at
  ) VALUES (
    v_league_id, p_name, p_description, v_invite_code, ARRAY[user_id::text],
    v_dest.rules, jsonb_build_array(v_initial_part), '[]'::jsonb, '[]'::jsonb,
    v_partner.slug, p_destination_id, v_round_id,
    now(), now()
  )
  RETURNING row_to_json(individual_leagues.*)::jsonb INTO league_json;

  RETURN jsonb_build_object(
    'status', 'created',
    'league', league_json || jsonb_build_object('league_type', 'individual')
  );
END;
$$;

-- Permette allo stesso utente di entrare in piu leghe partner dello stesso
-- turno/destinazione. L'idempotenza sulla stessa lega resta invariata.
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

  SELECT *
  INTO v_league
  FROM public.individual_leagues
  WHERE invite_code = p_invite_code
    AND partner IS NOT NULL
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Codice lega non valido';
  END IF;

  IF v_league.partner_round_id IS NOT NULL THEN
    SELECT join_password INTO v_scope_pw
    FROM public.partner_rounds
    WHERE id = v_league.partner_round_id;
  ELSE
    SELECT join_password INTO v_scope_pw
    FROM public.partner_destinations
    WHERE id = v_league.partner_destination_id;
  END IF;

  IF v_scope_pw IS NOT NULL AND p_password IS DISTINCT FROM v_scope_pw THEN
    RAISE EXCEPTION 'Parola d''ordine errata';
  END IF;

  updated_participants := COALESCE(v_league.participants, '[]'::jsonb);

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

COMMIT;
