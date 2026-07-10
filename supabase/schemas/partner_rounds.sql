-- =====================================================================
-- partner_rounds
-- Turno (edizione temporale) di una destinazione di un partner 'travel'.
-- NON popolata per partner 'package' (b-eazy): quelle leghe non hanno turni.
-- Il flow CREA LEGA mostra tutti i turni disponibili (end_date >= now());
-- l'utente sceglie il turno. get_active_partner_round() resta solo per
-- compatibilità finché esistono caller legacy.
-- =====================================================================
create table public.partner_rounds (
  id             uuid not null default gen_random_uuid(),
  destination_id uuid not null,
  name           text not null,
  start_date     timestamp with time zone not null,
  end_date       timestamp with time zone null,
  join_password  text null, -- parola d'ordine del turno (modello centralizzato); mai esposta al client
  created_at     timestamp with time zone null default now(),
  updated_at     timestamp with time zone null default now(),
  constraint partner_rounds_pkey primary key (id),
  constraint partner_rounds_destination_fkey
    foreign key (destination_id) references public.partner_destinations (id) on delete cascade,
  constraint partner_rounds_dates_check
    check (end_date is null or end_date >= start_date)
) TABLESPACE pg_default;

create index if not exists idx_partner_rounds_destination
  on public.partner_rounds (destination_id);

create index if not exists idx_partner_rounds_start_date
  on public.partner_rounds (destination_id, start_date);

alter table public.partner_rounds enable row level security;

create trigger set_updated_at_partner_rounds
before update on public.partner_rounds
for each row execute function set_updated_at ();
