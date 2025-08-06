import 'package:fantavacanze_official/core/entities/video/tutorial_section.dart';

List<TutorialSection> tutorialSections = [
  TutorialSection(
    title: "Crea Lega Individuale",
    description:
        "Per creare una lega individuale vai su: \n1. \"Crea Lega\"\n2. Inserisci nome e motto\n3. Seleziona \"Lega Individuale\"\n4. Scegli il regolamento\n5. Conferma\n\nIn una lega individuale tutti gli utenti si sfidano l'uno contro l'altro.",
    videoUrl: 'assets/tutorials/create-league/create-individual-league.mp4',
    androidScreenshotPath:
        'assets/tutorials/android-screenshots/create-league.png',
  ),
  TutorialSection(
    title: "Crea Lega a Squadre",
    description:
        "Per creare una lega individuale vai su: \n1. \"Crea Lega\"\n2. Inserisci nome e motto\n3. Seleziona \"Lega A Squadre\"\n4. Scegli il regolamento\n5. Conferma\n\nIn una lega a squadre tutti gli utenti possono sfidarsi in squadre:\n1. Tutti i membri della squadra sono in vacanza\n2. Amiche/Amici che non sono potuti venire o sono impegnati fanno l'asta e creano il loro team!",
    videoUrl: 'assets/tutorials/create-league/create-team-league.mp4',
    androidScreenshotPath:
        'assets/tutorials/android-screenshots/create-league.png',
  ),
  TutorialSection(
    title: "Unisciti a Lega Individuale",
    description:
        "Per unirti ad una lega individuale vai su:\n1. \"Cerca Lega\"\n2. Inserisci il codice della lega\n3. Cerca ed unisciti!",
    videoUrl: 'assets/tutorials/join-league/join-individual-league.mp4',
    androidScreenshotPath:
        'assets/tutorials/android-screenshots/join-individual-league.png',
  ),
  TutorialSection(
    title: "Unisciti a Lega a Squadre",
    description:
        "Per unirti ad una lega a squadre vai su:\n1. \"Cerca Lega\"\n2. Inserisci il codice della lega\n3. Nella schermata seguente scegli se creare la tua squadra (ne sarai il capitano) o unirti ad una squadra già esistente!",
    videoUrl: 'assets/tutorials/join-league/join-team-league.mp4',
    androidScreenshotPath:
        'assets/tutorials/android-screenshots/join-team-league.png',
  ),
  TutorialSection(
    title: "Aggiungi Bonus/Malus",
    description:
        "Per aggiungere un bonus o un malus (ovvero un evento) vai su:\n1. \"Nuovo Evento\" (Che trovi sia nella home che nel menù laterale)\n.2. Scegli se appartiene al regolamento o meno\n3. Scegli a chi assegnarlo (in caso di lega a squadre puoi scegliere l'intero team o un membro del team)",
    videoUrl: 'assets/tutorials/add-event.mp4',
    androidScreenshotPath: 'assets/tutorials/android-screenshots/add-event.png',
  ),
  TutorialSection(
    title: "L'admin",
    description:
        "L'amministratore è colui che crea la lega, altri admin possono essere aggiunti dallo stesso dal menù laterale",
    videoUrl: 'assets/tutorials/admin.mp4',
    androidScreenshotPath: 'assets/tutorials/android-screenshots/admin.png',
  ),
  TutorialSection(
    title: "Sfide Giornaliere",
    description:
        "Le sfide giornaliere sono sfide \"EXTRA\" (estranee al regolamento) che danno punti maggiorati. Queste sono:\n1. Tre per gli utenti premium\n2. 2 (guardando un video ad) per gli utenti free\n\nPer approvare una sfida l'utente può scrollare verso destra e:\n1. Se l'utente è un admin i punti vengono assegnatti subito\n2. Se l'utente non è un admin verrà inviata una notifica all'admin che può approvare o meno\n3. In alternativa si può creare manualmente un evento",
    videoUrl: 'assets/tutorials/daily-challenge.mp4',
    androidScreenshotPath:
        'assets/tutorials/android-screenshots/daily-challenge.png',
  ),
  TutorialSection(
    title: "Giochi Alcolici",
    description:
        "Ti proponiamo tre giochi alcolici (IN MULTIPLAYER) tra cui scegliere:\n1. Truth Or Dare\n2. Non Ho Mai\n3. Drop Bomb (disponibile 1 free trial e successivamente solo per utenti premium). Per accedere alla sezione dovrai:\n1. Guardare una pubblicità e potrai accedere per 15 minuti\n2. Accesso libero con abbonamento premium",
    videoUrl: 'assets/tutorials/drink-games.mp4',
    androidScreenshotPath:
        'assets/tutorials/android-screenshots/giochi-alcolici.png',
  ),
  TutorialSection(
    title: "I Ricordi",
    description:
        "I ricordi della vacanza sono accessibili dal menù laterale. Si tratta di foto/video ricordo della vacanza, collegabili eventualmente ad un evento",
    videoUrl: 'assets/tutorials/memories.mp4',
    androidScreenshotPath: 'assets/tutorials/android-screenshots/memories.png',
  ),
];
