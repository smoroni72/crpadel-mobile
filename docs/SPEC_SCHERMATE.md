# Specifica delle schermate (mockup approvato "A · Club")

Il mockup completo, con le alternative scartate, è sul canvas "CrPadel Mobile – proposte template" su claude.ai. Le schermate scelte sono copiate in `docs/mockup/`. Nomi, orari e numeri nel mockup sono dati di esempio.

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

Solo tema chiaro nella prima versione; i colori vanno comunque definiti come token del `ThemeData` per poter aggiungere il tema scuro.

## Navigazione

Barra in basso con 4 tab: **Home**, **Prenota**, **Partite**, **Profilo**. La shell attuale ha 5 tab (c'è anche "Circolo"): va portata a 4. I contenuti del circolo (news, tornei, galleria) sono fuori dalla prima versione.

## 1. Home (`01-dashboard.html`)

- Intestazione: data di oggi e "Ciao, <nome>". Campanella notifiche (per ora senza funzione).
- **Riferimento pacchetto**, piccolo: anello di avanzamento, "6/10 partite nel pacchetto", fascia e scadenza. Visibile **solo** se l'utente ha almeno un pacchetto o abbonamento attivo; tocco → Dettaglio abbonamento. Per un abbonamento a tempo (`unlimited`) mostra la scadenza al posto del conteggio.
- **Le tue prenotazioni**: prossime prenotazioni future, card con riquadro data (giorno della settimana e numero), campo, orario e stato della partita collegata (giocatori, richieste in attesa). Link "Prenota" → tab Prenota.
- **Partite del giorno**: selettore del giorno con frecce ‹ › e 5 giorni visibili; si può andare avanti e indietro senza limiti. Card per partita con riquadro orario:
  - passata/conclusa: squadre e punteggio;
  - aperta con meno di 4 giocatori: "Aperta · n/4 · livello" e pulsante **Chiedi** (invia richiesta di partecipazione; dopo l'invio diventa "Richiesta inviata");
  - piena o non disponibile: solo stato.
- Pull-to-refresh.

## 2. Prenota – un campo alla volta (`02-prenota.html`)

- Intestazione "Prenota" con selettore del giorno ‹ Gio 8 ott ›.
- Chip filtro "Solo campi liberi alle <orario preferito>" → schermata 3.
- **Tab dei campi** scorrevoli orizzontalmente; il campo selezionato è navy. Sotto: "‹ Campo precedente", indicatore a pallini "n di N", "Campo successivo ›". Anche lo swipe orizzontale sulla griglia cambia campo.
- Griglia verticale del giorno per il campo selezionato: colonna orari a sinistra (passi da 30'), blocchi colorati per gli impegni (legenda sotto). Gli impegni dell'utente sono navy; le partite aperte mostrano "Chiedi".
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

## 5. Profilo (`05-profilo.html`)

- Avatar con iniziali, nome, fascia di ranking (pallino colorato) e posizione.
- Statistiche: partite, vittorie, win rate.
- **I tuoi pacchetti**: card navy completa (nome, stato, disponibili su totale, barra, scadenza, "Dettagli ›"). Sezione presente solo se ci sono pacchetti.
- Voci: Dati personali, **Orario preferito** (fascia oraria; salvata sul dispositivo finché il backend non la supporta), Storico partite, Notifiche, Cambia password. Pulsante Esci.

## 6. Dettaglio abbonamento (`06-dettaglio-abbonamento.html`)

- Nome del pacchetto e stato.
- Tre numeri: disponibili, riservate, giocate.
- Attivato, scadenza, "Valido in tutti i circoli del gruppo".
- **Quando puoi usarlo**: fasce per giorno con l'ultimo orario di inizio ammesso; tipi di partita ammessi.
- **Movimenti**: acquisto, riserva, consumo, rilascio, con data e variazione.
- Se l'utente ha più pacchetti, si arriva qui da una lista nel Profilo.

## Tab Partite

Non c'è un mockup dedicato: usa lo stesso schema delle "Partite del giorno" della Home a tutta pagina, con in più il filtro "Le mie partite" e il dettaglio partita (giocatori per squadra, richieste da approvare se sei l'organizzatore, abbandona, inserisci risultato).
