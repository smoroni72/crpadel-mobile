# Piano di lavoro

Una fase alla volta, un branch e una Pull Request per fase. Una fase è chiusa quando i suoi criteri di accettazione sono veri e le verifiche di `CLAUDE.md` passano.

## Fase 0 – Fondamenta

Obiettivo: preparare la base prima delle funzionalità.

- [ ] Introdurre `go_router` con `StatefulShellRoute` (4 tab: Home, Prenota, Partite, Profilo) e redirect per l'autenticazione.
- [ ] Dividere `lib/app/authenticated_shell.dart` nelle feature `home`, `bookings`, `matches`, `profile`, `subscriptions`; widget comuni in `lib/core/widgets`.
- [ ] Spostare `apiClientProvider` e i provider infrastrutturali in `lib/core`. Creare l'`ApiClient` in `main()` e iniettarlo, invece di usare un `FutureProvider`.
- [ ] Aggiungere `put`, `patch` e `delete` all'`ApiClient`. Se il refresh fallisce: logout forzato e ritorno al login.
- [ ] Configurare `freezed`, `json_serializable`, `build_runner`.
- [ ] Localizzazione italiana (`flutter_localizations`, `intl`, locale `it_IT`).
- [ ] Font come asset locali; tema aggiornato con i token di `docs/SPEC_SCHERMATE.md`.
- [ ] Logo e icona dell'app (da chiedere a Stefano: oggi il logo è ospitato su Base44).

Accettazione: login, registrazione e recupero password funzionano come prima; le 4 tab navigano; `flutter analyze` e `flutter test` puliti.

## Fase 1 – Home in sola lettura

- [ ] Modelli e repository: prenotazioni, partite, pacchetti.
- [ ] Riferimento pacchetto (visibile solo se presente).
- [ ] "Le tue prenotazioni" con le prossime prenotazioni.
- [ ] "Partite del giorno" con selettore giorni avanti/indietro e card per stato.
- [ ] Stati vuoti, caricamento, errore; pull-to-refresh.

Accettazione: con un utente di staging la Home mostra i dati reali; cambiando giorno si aggiornano le partite; test dei repository e widget test della Home.

## Fase 2 – Prenotazione

- [ ] Griglia un campo alla volta (`/bookings/schedule`) con tab, frecce, indicatore e swipe.
- [ ] Schermata "Solo campi liberi" e orario preferito salvato sul dispositivo.
- [ ] "Completa la prenotazione": tipo, istruttore, giocatori facoltativi, tipo di partita.
- [ ] Conferma: `POST /bookings` + `POST /matches`; gestione del 409.
- [ ] Annullamento di una propria prenotazione.

Accettazione: si prenota un campo libero su staging e compare in Home; uno slot occupato nel frattempo dà un messaggio chiaro; test del flusso con i fake.

## Fase 3 – Partite

- [ ] Tab Partite a tutta pagina, filtro "Le mie", dettaglio partita.
- [ ] **Richiesta di partecipazione con approvazione** (lacuna backend n. 1): interfaccia repository + fake (`FAKE_MATCH_REQUESTS=true`).
- [ ] Per l'organizzatore: richieste in attesa, approva / rifiuta.
- [ ] Abbandona partita; inserisci risultato (fino a 3 set).

Accettazione: flusso completo di richiesta e approvazione verificabile con i fake; abbandono e risultato funzionano su staging.

## Fase 4 – Profilo e abbonamenti

- [ ] Profilo: fascia, posizione, statistiche (`/rankings?player_email=`, `/ranking-bands`).
- [ ] Card pacchetti e lista se più di uno.
- [ ] Dettaglio abbonamento: fasce, tipi ammessi, movimenti (lacuna n. 2: fake finché il backend non li espone).
- [ ] Cambia password; Esci.

## Fase 5 – Notifiche e deep link

Dipende dalle lacune n. 5 e n. 6. Da pianificare quando il backend è pronto.

## Lacune backend da seguire

Elenco completo in `docs/API_BACKEND.md`. Le modifiche al backend si fanno nel repository CrPadel, con una sessione e una PR separate.
