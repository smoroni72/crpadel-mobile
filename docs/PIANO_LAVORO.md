# Piano di lavoro

Una fase alla volta, un branch e una Pull Request per fase. Una fase è chiusa quando i suoi criteri di accettazione sono veri e le verifiche di `CLAUDE.md` passano.

## Fase 0 – Fondamenta

Obiettivo: preparare la base prima delle funzionalità.

- [x] Introdurre `go_router` con `StatefulShellRoute` (4 tab: Home, Prenota, Partite, Profilo) e redirect per l'autenticazione.
- [x] Dividere `lib/app/authenticated_shell.dart` nelle feature `home`, `bookings`, `matches`, `profile`, `subscriptions`; widget comuni in `lib/core/widgets`.
- [x] Spostare `apiClientProvider` e i provider infrastrutturali in `lib/core`. Creare l'`ApiClient` in `main()` e iniettarlo, invece di usare un `FutureProvider`.
- [x] Aggiungere `put`, `patch` e `delete` all'`ApiClient`. Se il refresh fallisce: logout forzato e ritorno al login.
- [x] Configurare `freezed`, `json_serializable`, `build_runner`.
- [x] Localizzazione italiana (`flutter_localizations`, `intl`, locale `it_IT`).
- [x] Font predefiniti come asset locali; tema chiaro e scuro con i token di `docs/SPEC_SCHERMATE.md`; barra in basso "a incavo".
- [x] Predisposizione multi-circolo (senza la funzione completa): tema costruito da un `BrandConfig` (per ora solo quello predefinito CRPadel) con i colori in una `ThemeExtension`; circolo corrente come provider letto dall'`ApiClient` per `X-Club-Slug`; nel redirect del router il controllo "circolo scelto", oggi sempre soddisfatto da `CLUB_SLUG`.
- [ ] Logo e icona dell'app: **in attesa**, li fornisce Stefano. Fino ad allora resta il segnaposto "CR".

Accettazione: login, registrazione e recupero password funzionano come prima; le 4 tab navigano; `flutter analyze` e `flutter test` puliti.

## Fase 0b – Multi-circolo e brand

Dipende dalla lacuna n. 8. Si sviluppa con il fake (`FAKE_APP_CONFIG=true`) e si collega al backend quando l'endpoint esiste.

- [ ] All'avvio: se c'è un circolo salvato, si usa subito il tema in cache e si aggiorna la configurazione in background (`If-None-Match`).
- [ ] Primo avvio: si legge l'elenco dei circoli aderenti.
  - Elenco vuoto o endpoint non disponibile (404): l'app parte con i valori predefiniti CRPadel e il circolo `CLUB_SLUG`, come oggi.
  - Uno o più circoli: schermata "Scegli il circolo" con la lista e una ricerca per nome o città; la scelta si salva sul dispositivo.
  - Errore di rete: messaggio e "Riprova", senza ripiegare in silenzio sul circolo predefinito.
- [ ] Applicazione del brand: colori (con ripiego sul predefinito se un valore manca o ha contrasto insufficiente), logo, immagine della splash Flutter, font scaricati e verificati.
- [ ] Cambio circolo dal Profilo, senza nuovo login (gli utenti sono globali, le iscrizioni per circolo).

Accettazione: con il fake si verifica il flusso con zero, uno e più circoli; un brand personalizzato cambia colori, logo e font; senza rete al riavvio l'app usa la configurazione in cache.

## Fase 1 – Home in sola lettura

- [x] Modelli e repository: prenotazioni, partite, pacchetti.
- [x] Riferimento pacchetto (visibile solo se presente). Mostra il nome del piano al posto della fascia oraria finché manca la lacuna n. 2.
- [x] "Le tue prenotazioni" con le prossime prenotazioni.
- [x] "Partite del giorno" con selettore giorni avanti/indietro e card per stato. Il pulsante **Chiedi** si collega nella Fase 3 (richieste di partecipazione).
- [x] Stati vuoti, caricamento, errore; pull-to-refresh.

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
