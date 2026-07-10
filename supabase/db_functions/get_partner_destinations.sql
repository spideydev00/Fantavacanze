-- =====================================================================
-- get_partner_destinations
-- Elenco delle destinazioni attive di un partner (per la flow "CREA LEGA").
-- Per ogni destinazione include il regolamento (rules) e `rounds`: array dei
-- turni disponibili (end_date >= now), ognuno con requires_password. [] per package.
-- `requires_password` (booleano): indica se lo scope ha una parola d'ordine,
--   SENZA esporla. Serve al client per mostrare il campo password solo quando
--   necessario (travel -> round attivo; package -> destinazione).
-- Output: { status, partner: {slug,name,kind}, destinations: [ ... ] }
-- =====================================================================
CREATE OR REPLACE FUNCTION public.get_partner_destinations(
  p_partner_slug text
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, auth, extensions
AS $$
DECLARE
  v_partner       public.partners%ROWTYPE;
  v_destinations  jsonb;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Utente non autenticato';
  END IF;

  SELECT *
  INTO v_partner
  FROM public.partners
  WHERE slug = p_partner_slug
    AND is_active = true;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('status', 'not_found', 'destinations', '[]'::jsonb);
  END IF;

  SELECT COALESCE(jsonb_agg(d ORDER BY d_name), '[]'::jsonb)
  INTO v_destinations
  FROM (
    SELECT
      jsonb_build_object(
        'id',           dest.id,
        'name',         dest.name,
        'description',  dest.description,
        'rules',        dest.rules,
        'image_url',    dest.image_url,
        'rounds',
          CASE
            WHEN v_partner.kind = 'travel' THEN COALESCE((
              SELECT jsonb_agg(
                       (to_jsonb(r) - 'join_password')
                       || jsonb_build_object(
                            'requires_password', r.join_password IS NOT NULL
                          )
                       ORDER BY r.start_date ASC
                     )
              FROM public.partner_rounds r
              WHERE r.destination_id = dest.id
                AND (r.end_date >= now() OR r.end_date IS NULL)
            ), '[]'::jsonb)
            ELSE '[]'::jsonb
          END,
        'requires_password',
          CASE
            WHEN v_partner.kind = 'travel' THEN false
            ELSE (dest.join_password IS NOT NULL)
          END
      ) AS d,
      dest.name AS d_name
    FROM public.partner_destinations dest
    WHERE dest.partner_id = v_partner.id
      AND dest.is_active = true
  ) q;

  RETURN jsonb_build_object(
    'status', 'found',
    'partner', jsonb_build_object(
      'slug', v_partner.slug,
      'name', v_partner.name,
      'kind', v_partner.kind
    ),
    'destinations', v_destinations
  );
END;
$$;
