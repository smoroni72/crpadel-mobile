# CRPadel Mobile – istruzioni per Claude Code

App Flutter per i **giocatori** dei circoli CRPadel. Usa le API REST del backend CRPadel (`/api/v1`). Admin e superuser restano sulla webapp.

Prima di scrivere codice leggi:

1. `docs/PIANO_LAVORO.md`: fasi, ordine di lavoro e criteri di accettazione. Lavora una fase alla volta.
2. `docs/SPEC_SCHERMATE.md`: comportamento e dati di ogni schermata.
3. `docs/API_BACKEND.md`: endpoint, regole di dominio e lacune note del backend.
4. `docs/mockup/*.html`: il mockup approvato (stile "A · Club"). Le pagine vanno lette come riferimento di layout, colori e testi; non sono codice da convertire 1:1.

Il backend si trova in `../CrPadel` (repository `smoroni72/crpadel-base44`). **In questo progetto è solo in lettura**: puoi consultarlo per capire un endpoint, ma non modificarlo. Se manca qualcosa lato API, segui la regola "Backend mancante" qui sotto.

## Stack e decisioni prese

- Flutter ≥ 3.35, Dart ^3.9. Solo Android e iOS.
- Stato: `flutter_riverpod` 3, con provider scritti a mano (niente codegen di Riverpod).
- Navigazione: `go_router` con `StatefulShellRoute` per la barra in basso e un redirect basato sullo stato di autenticazione. Ogni schermata ha una route con nome.
- HTTP: il `ApiClient` esistente (`lib/core/network/api_client.dart`, Dio). Gestisce Bearer, cookie di refresh persistente, header `X-Club-Slug` e retry su 401. Non cambiare questa logica senza un motivo esplicito.
- Modelli: `freezed` + `json_serializable`.
- Lingua: solo italiano. `flutter_localizations` + `intl` con locale `it_IT`. Fuso orario dei dati: Europe/Rome.
- Font: Space Grotesk (titoli), Inter (testo), JetBrains Mono (orari, punteggi, numeri). Inseriti come asset locali, non scaricati a runtime.

## Struttura

```
lib/
  app/            avvio, router, shell con la barra in basso
  core/           config, network, theme, widgets comuni, utilità date/orari
  features/<nome>/
    data/         repository (interfaccia + implementazione API + implementazione fake)
    domain/       modelli freezed
    presentation/ schermate, widget, controller Riverpod
```

Feature previste: `auth` (esiste), `home`, `bookings`, `matches`, `profile`, `subscriptions`.

## Regole di dominio da rispettare

- Gli slot partono ogni 30 minuti. Gli intervalli sono semiaperti: `[inizio, fine)`.
- Durate fisse: partita e allenamento 90', lezione 60'.
- Il giocatore prenota sempre a proprio nome. Chi prenota **non** è automaticamente un partecipante: "Gioco anch'io" è disattivato di default.
- Una partita con meno di 4 giocatori è **aperta**. Chi vuole giocare invia una richiesta, che **l'organizzatore deve approvare** (decisione di prodotto presa).
- I pacchetti e gli abbonamenti si vedono solo se l'utente ne ha almeno uno.
- Gli stati partita arrivano dall'API (`open`, `in_progress`, `pending_result`, `completed`, `not_played`, `cancelled`): non ricalcolarli nel client.

## Backend mancante

Se una schermata richiede un endpoint che non esiste (vedi `docs/API_BACKEND.md`, sezione "Lacune"):

1. definisci l'interfaccia del repository come se l'endpoint esistesse;
2. usa un'implementazione fake, attivata con `--dart-define=FAKE_<NOME>=true`;
3. segna la lacuna in `docs/API_BACKEND.md` se non c'è già.

Non inventare endpoint chiamandoli come se fossero reali.

## Sicurezza

- Nessun segreto, token o password nel repository. URL e circolo arrivano da `--dart-define` (`API_BASE_URL`, `CLUB_SLUG`).
- Non loggare token o dati personali.

## Verifiche prima di ogni commit

```powershell
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Ogni repository e ogni controller nuovo ha i suoi test, usando i fake. Le schermate principali hanno almeno un widget test.

## Git

- Parti da `main` aggiornato e crea un branch per ogni fase o funzionalità: `git switch -c feat/<nome-breve>`.
- Commit piccoli, messaggi in inglese in stile conventional commits (`feat:`, `fix:`, `refactor:`).
- Apri una Pull Request verso `main`. Niente force-push su branch condivisi, non riscrivere `main`.
