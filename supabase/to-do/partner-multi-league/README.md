# Partner Multi League

Esegui nel SQL editor Supabase:

```sql
-- contenuto di:
supabase/to-do/partner-multi-league/01_partner_multi_league_rpc.sql
```

Lo script aggiorna `create_partner_league` e `join_partner_league` senza
cambiare le firme RPC. Rimuove solo il vincolo errato "una lega per
turno/destinazione"; restano invariati parola d'ordine, invite code univoco e
join idempotente sulla stessa lega.
