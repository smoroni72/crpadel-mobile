# CRPadel Mobile

Applicazione Flutter dedicata ai giocatori CRPadel. Usa le API REST già disponibili sul backend CRPadel; non contiene credenziali o segreti.

## Stato iniziale

La base applicativa comprende:

- Android e iOS;
- tema coerente con il sito CRPadel;
- sessione con access token, refresh cookie persistente e archivio sicuro;
- login, registrazione, verifica email tramite messaggio del backend, recupero password e logout;
- navigazione `Home`, `Prenota`, `Partite`, `Circolo`, `Profilo`;
- configurazione centralizzata del circolo, pronta per la futura selezione multi-circolo.

Le viste dati di prenotazioni, partite, contenuti, ranking e abbonamenti sono la prossima fase di integrazione.

## Avvio

Ambiente di test predefinito:

```powershell
flutter pub get
flutter run
```

Configurazione esplicita:

```powershell
flutter run --dart-define=API_BASE_URL=https://test.crpadel.it/api/v1 --dart-define=CLUB_SLUG=crpadel
```

Per un altro ambiente cambiare i valori tramite `--dart-define`. Non salvare password, token o chiavi nel repository.

## Verifiche

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Roadmap mobile

1. Collegare la Home a prenotazioni, partite, avvisi e abbonamenti del giocatore.
2. Portare su mobile la griglia campi/orari e i flussi di prenotazione e cancellazione.
3. Portare apertura, partecipazione, inviti, abbandono e risultato delle partite.
4. Collegare ranking, fascia, posizione, statistiche e crediti nel Profilo.
5. Collegare news, eventi, tornei, galleria e dettagli del circolo.
6. Integrare deep link per verifica email e recupero password.
7. Aggiungere registrazione token dispositivo e FCM dopo la stabilizzazione dei flussi.
8. Eseguire test su dispositivi, preparare le build e successivamente consolidare il deployment Hetzner.
