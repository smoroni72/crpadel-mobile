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
- [x] Logo e icona dell'app: il logo del sito CRPadel (`assets/brand/crpadel_logo.png`); icone generate con `dart run tool/make_launcher_icon.dart` e `dart run flutter_launcher_icons`.

Accettazione: login, registrazione e recupero password funzionano come prima; le 4 tab navigano; `flutter analyze` e `flutter test` puliti.

## Fase 0b – Multi-circolo e brand

**Sospesa (12 ottobre 2026):** ogni cliente ha la sua app verticale, quindi l'app CRPadel non sceglie il circolo. Resta valida come riferimento per l'app standard Plenyo.

Dipende dalla lacuna n. 8. Si sviluppa con il fake (`FAKE_APP_CONFIG=true`) e si collega al backend quando l'endpoint esiste.

- [ ] All'avvio: se c'è un circolo salvato, si usa subito il tema in cache e si aggiorna la configurazione in background (`If-None-Match`).
- [ ] Primo avvio: si legge l'elenco dei circoli aderenti.
  - Elenco vuoto o endpoint non disponibile (404): l'app parte con i valori predefiniti CRPadel e il circolo `CLUB_SLUG`, come oggi.
  - Uno o più circoli: schermata "Scegli il circolo" con la lista e una ricerca per nome o città; la scelta si salva sul dispositivo.
  - Errore di rete: messaggio e "Riprova", senza ripiegare in silenzio sul circolo predefinito.
- [ ] Applicazione del brand: colori (con ripiego sul predefinito se un valore manca o ha contrasto insufficiente), logo, immagine della splash Flutter, font scaricati e verificati.
- [ ] Cambio circolo dal Profilo, senza nuovo login (gli utenti sono globali, le iscrizioni per circolo).
- [ ] Testi personalizzati per circolo e moduli facoltativi della Home (News in evidenza, Prossimi tornei, Podio del ranking) dalla configurazione.

Accettazione: con il fake si verifica il flusso con zero, uno e più circoli; un brand personalizzato cambia colori, logo e font; senza rete al riavvio l'app usa la configurazione in cache.

## Fase 1 – Home in sola lettura

- [x] Modelli e repository: prenotazioni, partite, pacchetti.
- [x] Riferimento pacchetto (visibile solo se presente). Mostra il nome del piano al posto della fascia oraria finché manca la lacuna n. 2.
- [x] "Le tue prenotazioni" con le prossime prenotazioni.
- [x] "Partite del giorno" con selettore giorni avanti/indietro e card per stato. Il pulsante **Partecipa** arriva nella Fase 3.
- [x] Stati vuoti, caricamento, errore; pull-to-refresh.

Accettazione: con un utente di staging la Home mostra i dati reali; cambiando giorno si aggiornano le partite; test dei repository e widget test della Home.

## Fase 2 – Prenotazione

- [x] Griglia un campo alla volta (`/bookings/schedule`) con tab, frecce, indicatore e swipe.
- [x] Schermata "Solo campi liberi" e orario preferito salvato sul dispositivo.
- [x] "Completa la prenotazione": tipo, istruttore, giocatori facoltativi, tipo di partita (tipi predefiniti finché manca la lacuna n. 11).
- [x] Conferma: `POST /bookings` + `POST /matches`; gestione del 409.
- [x] Annullamento di una propria prenotazione (dalla Home e dalla griglia).

Accettazione: si prenota un campo libero su staging e compare in Home; uno slot occupato nel frattempo dà un messaggio chiaro; test del flusso con i fake.

## Fase 3 – Partite

- [x] Tab Partite a tutta pagina, filtro "Le mie", dettaglio partita (mockup `07-partite.html`, `08-dettaglio-partita.html`).
- [x] **Partecipa** senza approvazione (`POST /matches/:id/join`, decisione del 9 ottobre 2026), con scelta della squadra.
- [x] Per l'organizzatore: aggiungi giocatore dalla rubrica, annulla prenotazione.
- [x] Abbandona partita; inserisci risultato (fino a 3 set, stesse regole del sito).

Accettazione: partecipare, abbandonare e inserire il risultato funzionano su staging.

## Fase 4 – Profilo e abbonamenti

- [x] Profilo: fascia, posizione, statistiche (`/rankings`; la posizione dalla classifica completa, vedi lacuna n. 12).
- [x] Scheda Abbonamenti del Profilo (solo se ce n'è almeno uno), con tocco verso il dettaglio.
- [x] Dettaglio abbonamento: fasce, tipi ammessi, movimenti (lacuna n. 2: fake `FAKE_SUBSCRIPTION_DETAILS=true`; senza, solo i dati reali). Si apre anche dal riferimento al pacchetto in Home.
- [x] Profilo uguale al sito: 4 riquadri statistiche, schede Prenotazioni / Partite / Lezioni / Abbonamenti (mockup `05-profilo.html`, `05b-profilo-abbonamenti.html`).
- [x] Impostazioni (solo app): Circolo, Orario preferito, Notifiche, Cambia password (mockup `05c-impostazioni.html`).
- [x] Cambia password (poi si torna al login: il server chiude tutte le sessioni); Esci.
- [x] **Elimina account** con conferma (lacuna n. 10: fake `FAKE_ACCOUNT_DELETION=true`; senza, spiega che non è ancora disponibile). Obbligatorio prima della pubblicazione su App Store.

## Fase 5 – Notifiche push (FCM) e deep link

Progetto Firebase `crpadel-e82f1` (lo stesso delle notifiche web del sito).

- [x] App Android `it.crpadel.app` registrata nel progetto Firebase; `google-services.json` in `android/app/` (fuori da Git).
- [x] `firebase_core` + `firebase_messaging`: permesso dopo l'accesso, token, avviso con "Apri" in primo piano, tocco che apre la schermata giusta (anche ad app chiusa, dopo l'accesso). Stato in Impostazioni → Notifiche.
- [x] Registrazione del token del dispositivo, tolto all'uscita (lacuna n. 5: fake `FAKE_PUSH_TOKENS=true` finché manca l'endpoint).
- [x] Icona monocromatica per la barra delle notifiche Android: ricavata dallo stemma (`tool/make_launcher_icon.dart` → `drawable-*/ic_notification.png`), colore rosso CRPadel.
- [ ] iOS: servono account Apple Developer, chiave APNs caricata su Firebase e un Mac per la build.
- [ ] Sito e backend (repository CrPadel, sessione separata): endpoint per i token, invio dal server con FCM HTTP v1, pagina admin "Invia notifica", notifiche automatiche.
- [ ] Deep link per verifica email e reset password (lacuna n. 6).

## Lacune backend da seguire

Elenco completo in `docs/API_BACKEND.md`. Le modifiche al backend si fanno nel repository CrPadel, con una sessione e una PR separate.
