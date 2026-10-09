# Specifica delle schermate (mockup approvato "A · Club")

Il mockup è sul canvas "CRPadel App – mockup approvato" su claude.ai (pagina "App approvata"; le alternative scartate sono nella pagina "Proposte scartate"). Le schermate sono copiate in `docs/mockup/`, numerate nell'ordine del percorso; `01-dashboard-scuro.html` e `07-partite-scuro.html` mostrano il tema scuro. Nomi, orari e numeri nel mockup sono dati di esempio.

## Rapporto con il sito (decisione del 9 ottobre 2026)

Il sito (https://test.crpadel.it) e l'app condividono font (Space Grotesk, Inter, JetBrains Mono), colore rosso, raggi e il tema chiaro. L'app **non** ne copia la grafica 1:1:

- restano la barra in basso "a incavo" e i colori dell'app, compreso il tema scuro blu notte (il sito usa un nero neutro);
- la Home resta quella personale dell'app, non la pagina vetrina del sito (hero, "Tutto in un'unica piattaforma", "Pronto a giocare?"), che è pensata per i visitatori ed è legata a un solo cliente;
- dal sito si riprendono alcune sezioni come moduli facoltativi della Home (vedi Home) e la struttura del Profilo.

Testi, colori, logo e moduli della Home sono personalizzabili per circolo dalla configurazione del backend (lacuna n. 8).

## Stile

| Token | Valore |
| --- | --- |
| Rosso azione (primary) | `#E6392D`; testo rosso su chiaro `#C42B20` |
| Navy brand | `#1B2A4A` (card in evidenza, elementi "tuoi") |
| Testo | `#1C2840`; testo secondario `#5C6884` |
| Sfondo pagina | `#F9FAFB`; superfici `#FFFFFF` |
| Bordi | `#DADEE7`; divisori `#EDEFF3` |
| Stati partita | aperta blu `#1D5FB8`, conclusa grigio, tua navy |
| Griglia | libero `#EEF7F1`; partita `#FBE3E1`; prenotato `#FBEFD5`; lezione `#E1ECFA`; allenamento `#E6E4F8` |
| Font | Space Grotesk 600–700 titoli; Inter 400–600 testo; JetBrains Mono per orari, numeri, punteggi |
| Raggi | card 16–20, pulsanti e chip 12, pill 999 |
| Tocco | target minimi 44×44 |

Tema chiaro e scuro: l'app segue l'impostazione del sistema. I colori sono token (`AppColors` in `lib/core/theme`); quelli del tema scuro sono una proposta con gli stessi ruoli e contrasto del testo almeno 4,5:1.

## Navigazione

Barra in basso con 4 tab: **Home**, **Prenota**, **Partite**, **Profilo**. Stile "a incavo" (template B scelto): la tab attiva sale in un cerchio rosso che galleggia sopra un incavo della barra, con il nome sotto; le altre mostrano icona e nome. Chat, galleria, lezioni e contatti del sito restano fuori dalla prima versione; news e tornei entrano solo come moduli della Home.

## 1. Home (`01-dashboard.html`)

- Intestazione: data di oggi e "Ciao, <nome>". Campanella notifiche (per ora senza funzione).
- **Riferimento pacchetto**, piccolo: anello di avanzamento, "6/10 partite nel pacchetto", fascia e scadenza. Visibile **solo** se l'utente ha almeno un pacchetto o abbonamento attivo; tocco → Dettaglio abbonamento. Per un abbonamento a tempo (`unlimited`) mostra la scadenza al posto del conteggio.
- **Le tue prenotazioni**: prossime prenotazioni future, card con riquadro data (giorno della settimana e numero), campo, orario e stato della partita collegata (giocatori). Link "Prenota" → tab Prenota.
- **Partite del giorno**: selettore del giorno con frecce ‹ › e 5 giorni visibili; si può andare avanti e indietro senza limiti. Card per partita con riquadro orario:
  - passata/conclusa: squadre e punteggio;
  - aperta con meno di 4 giocatori: "Aperta · n/4 · livello" e pulsante **Partecipa** (si entra subito nella prima squadra con posto, senza approvazione);
  - piena o non disponibile: solo stato.
- Pull-to-refresh.
- **Moduli facoltativi**, sotto le sezioni personali, attivati e ordinati per circolo dalla configurazione (lacuna n. 8), con lo stile delle sezioni del sito: **News in evidenza** (titolo, categoria, riassunto), **Prossimi tornei**, **Podio del ranking** (primi tre). Senza configurazione non compaiono.
- Testi personalizzabili per circolo: saluto, messaggi degli stati vuoti, contatti. Ogni testo mancante usa quello predefinito.

## 2. Prenota – un campo alla volta (`02-prenota.html`)

- Intestazione "Prenota" con selettore del giorno ‹ Gio 8 ott ›.
- Chip filtro "Solo campi liberi alle <orario preferito>" → schermata 3.
- **Tab dei campi** scorrevoli orizzontalmente; il campo selezionato è navy. Sotto: "‹ Campo precedente", indicatore a pallini "n di N", "Campo successivo ›". Anche lo swipe orizzontale sulla griglia cambia campo.
- Griglia verticale del giorno per il campo selezionato: colonna orari a sinistra (passi da 30'), blocchi colorati per gli impegni (legenda sotto). Gli impegni dell'utente sono navy; le partite aperte si aprono nel dettaglio da Partite.
- Tocco su uno spazio libero → schermata 4 con campo e orario precompilati. Se lo spazio non basta per la durata scelta, messaggio chiaro.
- Dati: `GET /bookings/schedule`.

## 3. Solo campi liberi (`03-campi-liberi.html`)

- Indietro alla griglia. Sottotitolo: giorno e durata.
- Chip degli orari di inizio; quelli nell'orario preferito sono marcati ★ e il primo è selezionato di default. Link "Modifica" → impostazione in Profilo.
- Lista dei campi liberi a quell'ora (nome, tipo, superficie, fascia) con pulsante **Prenota** → schermata 4.
- Sezione "Oppure, poco dopo": il primo campo che si libera entro 60'.
- Se l'utente non ha un orario preferito, la schermata parte dall'ora intera successiva.

## 4. Completa la prenotazione (`04-completa-prenotazione.html`)

Pagina modale a schermo intero con chiusura ✕.

- **Tipo di impegno**: segmentato Partita 90' / Lezione 60' / Allenamento. Lezione e allenamento richiedono la scelta dell'istruttore (`GET /coaches`).
- Riepilogo: campo, giorno e orario (modificabili tornando indietro), **Prenotato da** = utente corrente (non modificabile).
- **Giocatori** (facoltativo, solo per Partita): interruttore "Gioco anch'io" **spento di default**; griglia Squadra A / Squadra B con 4 posti "+ Aggiungi" (ricerca da `GET /players/directory`). Contatore n/4. Nota: con meno di 4 giocatori la partita resta aperta e le richieste le approva chi prenota.
- **Tipo di partita**: Ranking / Amichevole.
- Pulsante **Conferma prenotazione**: `POST /bookings`, poi, se è una partita, `POST /matches` con i giocatori indicati. In caso di 409 (slot occupato nel frattempo) torna alla griglia aggiornata con un messaggio.

## 5. Profilo (`05-profilo.html`, `05b-profilo-abbonamenti.html`)

**Uguale al Profilo del sito** (decisione del 9 ottobre 2026), con i colori e la barra dell'app.

- In alto: titolo "Profilo" e pulsante ingranaggio → Impostazioni.
- Card: avatar (icona su fondo rosso tenue), nome, email, badge della fascia di ranking (o "Fuori fascia").
- 4 riquadri: **Posizione** (es. "12°", "—" se non in classifica), **Partite**, **Vittorie**, **Win rate**. Dati da `/rankings?player_email=` e dalla classifica del circolo.
- Schede: **Prenotazioni**, **Partite**, **Lezioni**, **Abbonamenti**.
  - Prenotazioni e Lezioni: campo o istruttore, data e fascia oraria, stato (Confermata / Cancellata / Completata) e **Cancella** sulle confermate future.
  - Partite: data, orario, numero di giocatori e stato **in italiano** (il sito oggi mostra il codice dello stato, es. `pending_result`).
  - Abbonamenti: nome del piano, "Acquistato presso <circolo>", stato, attivazione ("Al primo utilizzo" se non attivo), scadenza, disponibili e utilizzate (solo per i pacchetti); tocco → Dettaglio abbonamento. **La scheda compare solo se l'utente ha almeno un pacchetto o abbonamento** (regola dell'app; il sito la mostra sempre).
- In fondo: **Esci** e **Elimina account** con finestra di conferma (cosa viene cancellato, azione irreversibile). Obbligatorio per la pubblicazione su App Store (linea guida Apple 5.1.1); dipende dalla lacuna n. 10.

## 5c. Impostazioni (`05c-impostazioni.html`)

Voci presenti solo nell'app, fuori dal Profilo per tenerlo uguale al sito: **Circolo** (cambio circolo), **Orario preferito** (salvato sul dispositivo finché manca la lacuna n. 4), **Notifiche**, **Cambia password**.

## 6. Dettaglio abbonamento (`06-dettaglio-abbonamento.html`)

- Nome del pacchetto e stato.
- Tre numeri: disponibili, riservate, giocate.
- Attivato, scadenza, "Valido in tutti i circoli del gruppo".
- **Quando puoi usarlo**: fasce per giorno con l'ultimo orario di inizio ammesso; tipi di partita ammessi.
- **Movimenti**: acquisto, riserva, consumo, rilascio, con data e variazione.
- Si arriva qui dalla scheda Abbonamenti del Profilo o dal riferimento al pacchetto in Home.

## 7. Partite (`07-partite.html`)

- Titolo "Partite", filtro segmentato **Tutte / Le mie**, selettore del giorno come in Home.
- Card per stato come in Home. Sulle partite aperte altrui: **Partecipa**. Le partite dell'utente hanno il riquadro navy. Ogni card porta al dettaglio.
- "Le mie": le partite dell'utente da oggi in avanti, raggruppate per giorno (senza selettore del giorno).

## 8. Dettaglio partita (`08-dettaglio-partita.html` organizzatore, `08b-dettaglio-partita-giocatore.html` giocatore)

- Campo, tipo, giorno, orario, livello; stato ("Aperta · 3/4") e "Organizzi tu" se è il caso.
- Squadra A / Squadra B con i posti liberi.
- Per chi non partecipa, se c'è posto: **Partecipa** (con posto in entrambe le squadre: **Partecipa in squadra A / B**). Nessuna approvazione.
- Per l'organizzatore: **Aggiungi giocatore** dalla rubrica, **Annulla prenotazione** (annulla anche la partita se è ancora aperta).
- Per un partecipante: **Abbandona partita**. Dopo la partita, per l'organizzatore: **Inserisci risultato** (fino a 3 set).

## 0. Scegli il circolo (`00-scegli-circolo.html`)

Primo avvio, solo se il backend espone più circoli (Fase 0b). Ricerca per nome o città, elenco dei circoli aderenti con logo e città. La scelta si cambia dal Profilo.
