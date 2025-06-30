# Fantavacanze

Fantavacanze è un’app in Flutter pensata per competere in modo divertente mentre si è in vacanza o, semplicemente, durante una serata in discoteca 🪩 ♥️.

## Tecnologie Utilizzate

Il progetto è implementato usando la **CLEAN Architecture**. Per riferimento guardare l'introduzione (circa 1 ora) del seguente [VIDEO](https://www.youtube.com/watch?v=ELFORM9fmss).

- 💾 Il database usato per l'autenticazione e come storage è **Supabase**. Tramite un cubit (**flutter_bloc**) si verifica se nella corrente sessione esiste un utente (quindi c’è un token di accesso attivo) e, in tal caso, si reindirizza direttamente alla home page. Altrimenti bisgna effettuare il login.

- 🚀 Utilizzato il package di flutter **get_it** per la _"dependency injection"_

- 📦 Utilizzato **hive** per la creazione di _"box"_ per il salvataggio locale dei dati (**caching**). Il tutto assieme al package **internet_connection_checker_plus** per la verifica della connessione internet sul dispositivo e per scegliere da dove caricare i dati.

- Utilizzato **fpdart** per la _"programmazione funzionale"_.

## Il concept

L'idea è quella di creare un gioco per stimolare le interazioni sociali nella vita reale. L'app è così strutturata:

- ✅ **Leghe personalizzabili**: Possibilità di creare una lega con i propri amici o unirsi ad una già esistente.

- ✅ **Bonus e malus**: Ogni azione conta! Si possono guadagnare punti bonus per le conquiste amorose e perdere punti attraverso i malus. Si può usare un set di regole predefinite e personalizzate, oppure utilizzare solamente le proprie regole.

- ✅ **Sezione Ricordi**: Ogni foto-ricordo sarà una testimonianza di un momento indimenticabile, inseribile all'interno di cartelle personalizzate.

- ✅ **Giochi alcolici**: Sfide e passatempi UNICI che renderanno ogni momento ancora più speciale.

## Copyright e utilizzo del codice

Il codice sorgente di questo progetto è protetto dal diritto d'autore ai sensi della normativa vigente.  
**È vietata la copia, la distribuzione, la modifica o l'utilizzo non autorizzato del codice, anche parziale, senza il consenso esplicito dell'autore.**

Chi viola il copyright può incorrere in conseguenze legali, tra cui:

- Richiesta di rimozione del materiale copiato (take-down)
- Richiesta di risarcimento danni
- Azioni civili e, nei casi più gravi, penali

Per richieste di utilizzo, collaborazione o licenza, contattare l'autore del progetto (alexspideydev@gmail.com).

## Conclusione

L'app è uscita ufficialmente a Giugno 2025, per vivere a pieno i due mesi d'Estate rimanenti!
