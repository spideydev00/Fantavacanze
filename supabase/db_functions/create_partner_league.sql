-- =====================================================================
-- create_partner_league
-- Crea una lega INDIVIDUALE legata a un partner (InVibe, b-eazy, …).
--  - ricava il turno attivo se il partner è 'travel' (NULL se 'package')
--  - COPIA il regolamento dalla destinazione (rules non modificabili dal client)
--  - genera invite_code = <code_prefix> + 8 char esadecimali (univoco)
--  - imposta join_password (parola d'ordine in chiaro, mai esposta in lettura)
-- Ritorna { status: 'created', league: {...} } (senza join_password).
-- =====================================================================
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

  -- 1) destinazione + partner
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

  -- 2) turno attivo (solo travel)
  IF v_partner.kind = 'travel' THEN
    v_round_id := public.get_active_partner_round(p_destination_id);
    IF v_round_id IS NULL THEN
      RAISE EXCEPTION 'Nessun turno disponibile per questa destinazione';
    END IF;
  ELSE
    v_round_id := NULL;
  END IF;

  -- 2b) parola d'ordine dello scope (turno se travel, altrimenti destinazione).
  -- Impostata centralmente dal partner; se NULL la collaborazione è "aperta".
  IF v_round_id IS NOT NULL THEN
    SELECT join_password INTO v_scope_pw FROM public.partner_rounds WHERE id = v_round_id;
  ELSE
    v_scope_pw := v_dest.join_password;
  END IF;

  IF v_scope_pw IS NOT NULL AND p_password IS DISTINCT FROM v_scope_pw THEN
    RAISE EXCEPTION 'Parola d''ordine errata';
  END IF;

  -- 3) codice univoco <prefix> + 8 hex
  LOOP
    v_invite_code := v_partner.code_prefix || substr(md5(gen_random_uuid()::text), 1, 8);
    EXIT WHEN NOT EXISTS (
      SELECT 1 FROM public.individual_leagues WHERE invite_code = v_invite_code
    );
  END LOOP;

  -- 4) partecipante iniziale (creatore)
  v_initial_part := jsonb_build_object(
    'type',       'individual',
    'userId',     user_id,
    'name',       p_user_name,
    'points',     0,
    'malusTotal', 0,
    'bonusTotal', 0
  );

  -- 5) insert (rules COPIATE dalla destinazione)
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
