# API del backend CRPadel per l'app giocatore

Fonte: analisi del repository `../CrPadel` (API Fastify, `api/src/routes/*`, migrazioni `database/migrations/001–023`), ottobre 2026. In caso di dubbio fa fede il codice del backend.

## Convenzioni

- Base URL: `API_BASE_URL` (staging `https://test.crpadel.it/api/v1`).
- Circolo: header `X-Club-Slug` (default `crpadel`). Il ruolo nel circolo corrente si legge da `GET /tenancy/current` (`membership_role`), **non** da `user.club_role` di `/auth/me`, che si riferisce sempre al circolo di default.
- Risposte `{ data: ... }`; errori `{ error, details? }` con messaggi in italiano. Conflitto di slot → 409.
- Access token: JWT Bearer da 15 minuti, restituito da `POST /auth/login`. Refresh: solo tramite cookie `crpadel_refresh` (path `/api/v1/auth`), già gestito dall'`ApiClient`.
- Rate limit: login 5/min, registrazione 3/min per IP.

## Endpoint usati dall'app

| Schermata | Endpoint |
| --- | --- |
| Accesso | `POST /auth/login`, `/auth/register`, `/auth/forgot-password`, `/auth/resend-verification`, `/auth/refresh`, `/auth/logout`, `/auth/change-password`; `GET /auth/me` |
| Circolo | `GET /tenancy/current`, `GET /tenancy/clubs`, `GET /courts` |
| Pacchetti | `GET /subscriptions/mine` (con `matches_available`) |
| Le mie prenotazioni | `GET /bookings` (filtrato sull'utente); annullamento `PATCH /bookings/:id` con `{ "status": "cancelled" }` |
| Griglia campi | `GET /bookings/schedule?date=YYYY-MM-DD&opening_hour=7&closing_hour=23` → righe da 30', stato per campo `free` / `booked` / `match` / `lesson` / `training`, con `is_owner` e `can_use` |
| Campi liberi | `GET /bookings/availability?from=&days=&slot_minutes=90` (slot su più giorni) |
| Prenotare | `POST /bookings` con `court_id`, `date`, `time_slot` ("HH:MM-HH:MM"), `start_hour`, `end_hour` (decimali, es. 18.5), `booking_type` (`court` / `lesson` / `training`), `coach_id` (obbligatorio per lezione e allenamento), `notes` |
| Aprire una partita | `POST /matches` con `booking_id`, `date`, `court_id`, `time_slot` uguali alla prenotazione (che deve essere propria e `confirmed`), `match_type` (`ranking` / `friendly` / `tournament` / `other`, solo se attivo nel circolo), `activity_kind` (`match` predefinito, `lesson`, `technical`), `level`, `max_players`, giocatori (`club_player_id`, `name`) |
| Rubrica giocatori | `GET /players/directory` |
| Partite del giorno | `GET /matches?date=YYYY-MM-DD`; le mie: `GET /matches?organizer_email=<email>` |
| Partecipare / lasciare | `POST /matches/:id/join` con `team` (`A`/`B`), iscrizione immediata senza approvazione; `POST /matches/:id/leave` (non per l'organizzatore) |
| Aggiungere giocatori, risultato | `POST /matches/:id/participants` con `club_player_id` e `team` (organizzatore); `PATCH /matches/:id` con `score_team1`, `score_team2` (stesso punteggio, es. `6-4 3-6 TB 10-8`) e `status: completed` |
| Risultato | `PATCH /matches/:id` (organizzatore: punteggio + `status: completed`) |
| Profilo e ranking | `GET /rankings?player_email=`, `GET /ranking-bands` |
| Istruttori | `GET /coaches` |

## Regole di dominio

- **Slot**: partenze ogni 30', intervalli `[inizio, fine)`. Non si prenota un orario passato (è ammesso lo slot dell'ora corrente a ore intere).
- **Durate**: partita e allenamento 90', lezione 60'. `match-availability` accetta solo slot da 90'.
- **Partita**: nasce sempre da una prenotazione. Stato iniziale `open`; `max_players` 2–4, default 4. Posizioni 0–1 = squadra A, 2–3 = squadra B. Un guest nella partita la trasforma in amichevole.
- **Ciclo di vita** (calcolato dal server, fuso Europe/Rome): `open` → `in_progress` → `pending_result` → `completed`, oppure `not_played` / `cancelled`. Il passaggio a `in_progress` richiede 4 giocatori **e 4 pagamenti registrati dal desk**: senza, una partita piena finisce `not_played`.
- **Annullare** la prenotazione collegata annulla la partita se è ancora `open`.
- **Pacchetti** (`membership_plans`): `unlimited` (a tempo) oppure `package` (N partite), con fasce orarie per giorno della settimana (`weekday` 1–7, `start_time`, `latest_start_time` = ultimo inizio ammesso). La validità parte dalla **prima partita giocata**. Stati: `pending_activation`, `active`, `expired`, `exhausted`, `cancelled`, `refunded`. Valgono su tutti i circoli della stessa proprietà.

## Lacune note (da realizzare nel backend CrPadel)

Finché non esistono, l'app usa implementazioni fake (vedi `CLAUDE.md`).

| # | Lacuna | Serve per | Proposta |
| --- | --- | --- | --- |
| 1 | ~~Richiesta di partecipazione con approvazione~~ | — | **Non più necessaria**: dal 9 ottobre 2026 si entra nelle partite aperte senza approvazione, con `POST /matches/:id/join` |
| 2 | Dettaglio pacchetto: fasce orarie, tipi di partita ammessi, movimenti | Dettaglio abbonamento | Includere `windows` e `allowed_match_types` in `/subscriptions/mine`; `GET /subscriptions/mine/:id/movements` |
| 3 | Profilo modificabile e avatar | Profilo | `PATCH /me` (nome, telefono), upload avatar per l'utente |
| 4 | Orario preferito | Campi liberi | Campo sul profilo utente; nel frattempo salvarlo sul dispositivo |
| 5 | Registrazione token push e invio FCM | Notifiche | `POST /me/push-tokens`; invio lato server |
| 6 | Deep link verifica email / reset password | Accesso | App Link Android, Universal Link iOS |
| 7 | Refresh token via body | Robustezza mobile | Facoltativo: oggi il cookie jar funziona |
| 8 | Elenco pubblico dei circoli, configurazione del brand e testi per circolo | Multi-circolo (Fase 0b), Home | Vedi sotto. Da fare dopo che Edoardo chiude il lavoro in corso: non è bloccante, l'app usa il fake e i valori predefiniti |
| 9 | `GET /bookings` senza filtro "da data" | Home, "Le tue prenotazioni" | Facoltativo: parametro `from=YYYY-MM-DD`. Oggi l'app chiede le 100 più recenti e scarta le passate |
| 10 | Eliminazione del proprio account | Profilo, pubblicazione su App Store | Endpoint per l'utente autenticato (es. `DELETE /me` con conferma della password) che anonimizza o cancella i dati. Oggi il pulsante "Elimina Account" del sito chiama la funzione `deleteUserAccount`, non ancora migrata da Base44: risponde 501 e non funziona nemmeno sul sito |
| 11 | Tipi di partita attivi leggibili dai giocatori | Completa la prenotazione | Ogni circolo attiva i suoi tipi (`club_match_type_settings`), ma `GET /match-type-settings` è riservato agli admin. Proposta: `GET /match-types` per gli iscritti (solo attivi, codice ed etichetta), oppure i tipi dentro la configurazione del circolo (n. 8). Oggi l'app propone Ranking e Amichevole e mostra l'errore del server se il tipo non è attivo |

### Lacuna 8 – proposta

Oggi esistono `customers` (proprietario) → `clubs`, con `clubs.settings jsonb` non usato. `GET /tenancy/current` è pubblico, `GET /tenancy/clubs` richiede il login. `clubs` non ha città né logo.

- **Dati**: `customers.branding jsonb` (predefinito del proprietario) e `clubs.settings.branding` (sovrascrive per il singolo circolo). Su `clubs`: `city`, `province`, `is_listed` (aderente e visibile nell'app).
- **`GET /tenancy/directory?q=`** (pubblico): solo circoli attivi e `is_listed`; campi `slug`, `name`, `city`, `province`, `logo_url`. Ricerca per nome o città, senza distinzione di maiuscole e accenti.
- **`GET /tenancy/app-config`** (pubblico, circolo da `X-Club-Slug`, con `ETag`):
  - `club`: `id`, `slug`, `name`, `timezone`;
  - `brand`: `display_name`, `colors` (gli stessi token di `SPEC_SCHERMATE.md`: `primary`, `primary_text`, `navy`, `text`, `text_secondary`, `background`, `surface`, `border`, `divider`), `logo` e `splash` (`url`, `sha256`, colore di sfondo), `fonts` (`heading`, `body`, `mono`: famiglia, pesi, `url`, `sha256`);
  - `contacts`: email e telefono del circolo, link a privacy e termini;
  - `texts`: testi personalizzati (nome visualizzato, slogan, saluto della Home, messaggi degli stati vuoti, link al regolamento), ognuno facoltativo;
  - `home_modules`: elenco ordinato dei moduli facoltativi della Home (`news`, `tournaments`, `ranking_podium`);
  - `features`: interruttori per le sezioni facoltative;
  - `min_app_version`.
  I campi mancanti valgono "usa il predefinito CRPadel".
- **Webapp**: editor del brand per l'owner, con anteprima e controllo del contrasto; upload di logo e splash nello storage esistente.
- **Sito**: oggi logo, colori e testi di CR Padel sono scritti nel codice del sito. La stessa configurazione dovrebbe alimentare anche il sito, così app e sito restano allineati per ogni circolo.
- **Email**: il mittente resta `noreply@crpadel.it`. Personalizzare il nome visualizzato ("<Circolo> via CRPadel"), il `Reply-To` (email del circolo) e logo e nome nel modello dell'email.
