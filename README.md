# Fantavacanze
Fantavacanze è un’app in Flutter pensata per competere in modo divertente mentre si è in vacanza o, semplicemente, durante una serata in discoteca 🪩 ♥️. 

## Tecnologie Utilizzate 
Il progetto è implementato usando la **CLEAN Architecture**. Per riferimento guardare l'introduzione (circa 1 ora) del seguente [VIDEO](https://www.youtube.com/watch?v=ELFORM9fmss).

- 💾 Il database usato per l'autenticazione e come storage è **Supabase**. Tramite un cubit (**flutter_bloc**) si verifica se nella corrente sessione esiste un utente (quindi c’è un token di accesso attivo) e, in tal caso, si reindirizza direttamente alla home page. Altrimenti bisgna effettuare il login.

- 🚀 Utilizzato il package di flutter **get_it** per la *"dependency injection"*

- 📦 Utilizzato **hive** per la creazione di *"box"* per il salvataggio locale dei dati (**caching**). Il tutto assieme al package **internet_connection_checker_plus** per la verifica della connessione internet sul dispositivo e per scegliere da dove caricare i dati.

- Utilizzato **fpdart** per la *"programmazione funzionale"*.

## Il concept
L'idea è quella di creare un gioco per stimolare le interazioni sociali nella vita reale. L'app è così strutturata:

- ✅ **Leghe personalizzabili**: Possibilità di creare una lega con i propri amici o unirsi ad una già esistente.

- ✅ **Bonus e malus**: Ogni azione conta! Si possono guadagnare punti bonus per le conquiste amorose e perdere punti attraverso i malus. Si può usare un set di regole predefinite e personalizzate, oppure utilizzare solamente le proprie regole.

- ✅ **Sezione Ricordi**: Ogni foto-ricordo sarà una testimonianza di un momento indimenticabile, inseribile all'interno di cartelle personalizzate.

- ✅ **Modalità Sfida Veloce**: Con questa modalità si invitano altri partecipanti (tramite link d’invito) a pertecipare alla sfida. L’utente che la crea ne è admin, gli altri sono partercipanti. Qui gli utenti in modo randomico (uno alla volta) vengono estratti e devono eseguire delle azioni in un determinato lasso di tempo oppure tra tutti “il primo a fare qualcosa” guadagna dei punti (qui molti di più). Si sceglie tra una modalità più soft, in amicizia ed una più hard, in serata, dove si propongono quest più “estreme”.

- ✅ **Giochi alcolici**: Sfide e passatempi UNICI che renderanno ogni momento ancora più speciale.

## Conclusione
L'app mira ad uscire per i primi di Aprile. Be ready!💪🏻