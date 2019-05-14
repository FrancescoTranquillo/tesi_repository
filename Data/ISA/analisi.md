
Nell'ambito della manutenzione predittiva applicata a dispositivi medici, durante l'esperienza di tirocinio si è voluto provare a costruire un algoritmo di predizione in grado di predire un fermo macchina. La prima fase di questa sperimentazione è stata condotta con lo scopo di individuare quale dei dispositivi presenti in ospedale fosse il più adatto per essere sottoposto a manutenzione predittiva dove per "adatto" si intende in possesso di caratteristiche utili ai fini dell'estrazione e dell'analisi dei dati prodotti dalla macchina stessa.

La scelta è ricaduta su un gruppo di lavaendoscopi,  dispositivi utilizzati nei reparti di endoscopia e chirurgia per la disinfezione e la sterilizzazione di strumentazione endoscopica (il termine tecnico è "reprocessing" di strumenti endoscopici). In \ref{isa} una fotografia del macchinario.

![ISA test\label{isa}](../../img/ISA.jpg sda)

La decisione di sviluppare un algoritmo di predizione per questo tipo di lavaendoscopi è stata presa in base a due fattori chiave. Il primo riguarda la disponibilità dei dati a disposizione, mentre il secondo riguarda la tipologia di output presentato dalla macchina.

L'algoritmo di predizione è stato costruito in diversi passaggi e si fonda sull'avvio sequenziale di alcuni script scritti in linguaggio R.

1) "Analyzer.r" si occupa di selezionare tutti i file testuali che contengono gli output di un processo di lavaggio della lavaendoscopi ISA MEDIVATORS. Da qui in avanti, ci si riferirà agli stessi con il nome di "scontrini", considerata anche la modalità di stampa con cui vengono generati gli stessi. In particolare, "Analyzer.r" contiene al suo interno la definizione di diverse funzioni che hanno il compito di trasformare uno scontrino (un file di testo in formato .txt) in informazioni in formato tabulare. Queste funzioni vengono poi applicate a tutti gli scontrini presenti in uno specifico percorso (selezionabile dall'utilizzatore) al fine di ottenere un'unica tabella in formato .csv composta da tante righe quanti sono gli scontrini analizzati e tante colonne quante sono le informazioni estraibili da uno scontrino. Le colonne verranno d'ora in avanti chiamate features. Tra le features sono presenti, per esempio:
  - Il giorno in cui è stato stampato quello scontrino
  - La variabile dicotomica "scontrino regolare" che indica la regolarità del lavaggio
  - Una variabile chiamata "testo" che raccoglie, come il nome suggerisce, il testo estraibile dallo scontrino in considerazione, dal quale vengono rimossi i timestamp e altri caratteri non interessanti dal punto di vista dell'analisi di natural language processing.

  Si riporta a titolo esemplificativo una riga della tabella ottenuta dallo script "Analyzer.r"

giorno|testo|temp.1|temp.2|...|ciclo regolare|
------|-----|------|------|---|--------------|
12/03/2016|TIPO CICLO: COMPLETE DISINFECTION TEST DI TEN...|23|26|...|1|

2) Una volta ottenuta la tabella che rappresenta la tabulazione degli scontrini, è stato necessario estrapolare dal database delle manutenzioni, una tabella relativa a tutte le date in cui è stata eseguita una manutenzione alla lavaendoscopi in esame. Questo passaggio è stato facilitato dall'interfaccia e dalla funzionalità del CMMS Coswin, che permette la costruzione di filtri sull'intero database in modo facilitato e senza la necessità di scrivere queries. Lo script "data_preparation.r" si occupa di unire le informazioni delle due tabelle (quella degli scontrini ottenuta al punto 1 e quella ricavata da Coswin) in un'unica tabella aggiungendo una variabile dicotomica chiamata "flag" alla tabella degli scontrini. Questa feature assume il valore "1" in corrispondenza delle righe della tabella degli scontrini in cui il valore della variabile "giorno" corrisponde ad una data appartenente all'intervallo di predizione definito in precedenza. Ricordiamo quindi che l'intervallo di predizione è quell'intervallo di tempo in cui si è interessati a predire se avverrà un fallimento da parte della macchina in esame. In altre parole, viene assegnato il valore "1" se la riga in esame rientra in uno dei N giorni che hanno preceduto un fallimento.

3) "partitioning.r" si occupa di creare le "borse" di scontrini. Per "borsa" si intende un sottoinsieme di dimensionalità variabile della tabella degli scontrini creata al punto 1).

4) "preprocessing.r" esegue le operazioni preliminari necessari alla costruzione del modello di predizione. Queste ultime possono essere suddivise in due categorie:
  - Operazioni per analisi di text mining
  - Operazioni
