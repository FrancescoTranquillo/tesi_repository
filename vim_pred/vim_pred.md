# La manutenzione predittiva in Ospedale: l'esperienza di Vimercate

In questo capitolo si parlerà dell'applicabilità di una strategia di manutenzione predittiva nell'ambito dell'Ospedale di Vimercate. In questi termini, verrà indicata innanzitutto la modalità di ricerca intrapresa al fine di identificare la classe di dispositivi di maggiore interesse e quella più adatta per essere analizzata con l'obiettivo di progettare e applicare un programma di manutenzione predittiva.
Si indagheranno quindi i requisiti necessari per l'applicabilità di questa tipologia di manutenzione, andando poi a valutare il parco macchine presente in ospedale dal punto di vista dell'applicabilità stessa. Nella seconda metà del capitolo verrà quindi riportato il risultato della ricerca preliminare e si evidenzieranno, oltre ai risultati ottenuti dal punto di vista di algoritmi sviluppati, le criticità e le limitazioni incontrate.

## Indagine preliminare
Come visto nel capitolo precedente, la previsione dell'insorgenza di un guasto in un macchinario è ottenibile avendo a disposizione dati ottenuti tramite monitoraggio costante (preferibilmente real time) di variabili fisiche di interesse. Le più comuni variabili sottoposte a monitoraggio, per cui risulta relativamente semplice l'applicazione dello stesso, sono:

- Temperatura: monitorata attraverso termometri dotati di unità di memoria per il salvataggio e la successiva comunicazione in remoto dei dati misurati.
- Pressione: monitorata attraverso sensori applicati alle parti meccaniche di interesse.
- Ampiezza, fase e spettrometria delle vibrazioni meccaniche: variabili, queste, che risultano molto adatte ad essere studiate per il monitoraggio e la previsione dello stato di salute di un dispositivo meccanico sottoposto a movimenti ciclici, o di un componente dello stesso. L'analisi dello spettro delle frequenze si è dimostrato, in letteratura, una buona metodologia di indagine (ref).
- Tensioni e correnti: misurate, manualmente, attraverso amperometri e voltmetri e automaticamente attraverso letture "interne" effettuate dai software stessi dei macchinari.

Per l'individuazione di una classe di dispositivi adeguata per essere trattata e analizzata nell'ottica di manutenzione predittiva, ci si è avvalsi della consultazione sia del Global Service, sia del personale del SIC. I risultati di queste consultazioni possono essere sintetizzati nei seguenti punti:

- L'interesse comune rispetto all'applicazione di una strategia di manutenzione predittiva è indirizzato verso la minimizzazione del fermo macchina in tutte quelle apparecchiature elettromedicali considerati "ad alta incidenza", ovvero il cui guasto comporta importanti rallentamenti nell'erogazione dei servizi sanitari e l'applicazione clinica per il quale sono utilizzati interessa una grande parte del bacino di utenza della popolazione. Fanno parte di questa famiglia: TAC, Risonanze magnetiche, Mammografi, ecografi, defibrillatori etc.(**esiste una definizione specifica?**)
- Esiste, nel software attualmente utilizzato per la gestione delle apparecchiature elettromedicali (Coswin8i), una funzionalità che permetterebbe di monitorare le prestazioni di alcuni dispositivi ed effettuare quindi una sorta di manutenzione predittiva, ma questa risulta inutilizzata e la documentazione relativa a questa funzionalità risulta del tutto assente.
- Esistono molti dispositivi, in ospedale, che hanno una connessione internet per il collegamento alla rete dell'ospedale, ma nessuno di questi comunica dati fisici utili ad un'analisi di tipo predittivo sullo stato di salute del macchinario. Questa è la maggiore criticità incontrata.
- L'eventuale modifica di un apparecchio elettromedicale, anche se di proprietà dell'ospedale, al fine dell'inserimento di sensori utili alla raccolta di dati fisici (come un semplice termometro) risulterebbe in una invalidazione della certificazione CE, garanzia della sicurezza del dispositivo, innalzando quindi il rischio (sia per il paziente, sia per l'operatore) relativo all'utilizzazione dello stesso.

Si ha quindi una situazione generale dove risulta difficile, per l'Azienda Ospedaliera in generale e per Ingegneria Clinica in particolare, pensare di poter applicare una metodologia di manutenzione così avanzata. Tuttavia, il sistema informativo presente in Ospedale ha, come si vedrà più avanti nel capitolo \ref{insight} relativo allo sviluppo del software , tutti i requisiti per poter, in futuro, ospitare un sistema di manutenzione di questo tipo.

## L'analisi dei log macchina

A fronte della situazione delineata, si è quindi cercato, tramite un processo di ingegneria inversa, di sfruttare sistemi e risorse attualmente disponibili in Azienda, per ottenere dei risultati che, sebbene non siano paragonabili alla "manutenzione predittiva" eseguita in altri settori (come quello manifatturiero), dimostrano l'esistenza di possibilità pratiche, per l'Ospedale, di indirizzarsi su un percorso di profondo sviluppo tecnologico dove la digitalizzazione, la data engineering, l'IoT e applicazioni di intelligenza artificiale hanno e avranno un ruolo predominante.

In questo contesto, è necessario fare riferimento alle variabili fisiche precedentemente descritte e ai sensori responsabili delle loro misurazioni. In realtà, tutte le variabili citate possono essere soggette a monitoraggio automatico "interno" in quei macchinari dotati di un sistema computerizzato. Queste e molte altre letture ed analisi sui processi svolti vengono condotte dai computer, installati all'interno dei macchinari, in modo automatico e a frequenza variabile (impostata dal produttore) per poi essere salvate in file di memoria chiamati _"log"_ (o più comunemente log macchina). I log macchina, nei sistemi progettati per produrli, rappresentano un sistema di autodiagnostica utile ai fini del controllo del normale funzionamento del dispositivo da parte del personale tecnico. Si pensi infatti al caso di manutenzione correttiva effettuata sulla risonanza magnetica Philips Achieva (d'ora in avanti chiamata Achieva per brevità) descritto nel capitolo \ref{es_prog}. In quel frangente, il personale tecnico di Philips ha estratto e caricato i log macchina generati dalla Achieva in un software proprietario in grado di riassumere i log e di fornire al tecnico un rapido riassunto di tutti gli eventi (interni) che hanno interessato la macchina.

La ricerca si è quindi indirizzata, a fronte delle criticità incontrate, nell'analisi dei log macchina al fine di costruire dei modelli predittivi sullo stato di salute del dispositivo che li ha generati.

In particolare, per l'attività si è fatto principalmente riferimento allo studio condotto da Sipos et al. [@siposLogbasedPredictiveMaintenance2014] nel quale ci si è avvalsi di diversi Terabytes di log macchina estratti da diverse migliaia di risonanze magnetiche prodotte da Siemens \textregistered. La quantità di dati a disposizione, come si vedrà, rappresenta una dei principali requisiti per la modellizzazione di algoritmi di machine learning perchè, dalla stessa, dipendono fortemente le capacità di apprendimento del modello che si vuole sviluppare.

In questo studio, gli autori evidenziano tre principali problematiche relativo all'utilizzo dei log macchina per la predizione dei guasti. Esse possono essere così riassunte:

1. I log macchina, essendo progettati per supportare personale tecnico nella risoluzione di problemi di tipo informatico (attività di _debugging_), raramente contengono informazioni esplicite per la predizione di un guasto del macchinario.
2. I log contengono dati di tipo eterogeneo tra cui: sequenze simboliche, serie temporali numeriche, testi non strutturati e variabili categoriche. Questa particolarità aggiunge uno strato di complessità all'analisi di questo tipo di dati.
3. I log contengono una grande quantità di dati, il che pone delle sfide dal punto di vista dell'efficienza computazionale.

Elemento imprescindibile per poter effettuare delle analisi predittive è la disponibilità di dati relativi ad interventi di manutenzione passati effettuati sulla macchina in esame. Grazie a questi, infatti, è possibile correlare ogni guasto avvenuto (noto) con il corrispondente insieme di log macchina.

Partendo da questi presupposti si è cercato, in un primo tentativo, di utilizzare i log macchina derivanti dalla Achieva estratti in concomitanza con l'intervento di manutenzione correttiva descritto nel capitolo (REF). Tuttavia, i dati a disposizione estratti facevano riferimento a pochi giorni di attività della macchina. Non sufficienti, quindi, ad essere utilizzati per condurre un'analisi che desse buoni risultati. Si è presentata quindi la necessità di reperire dalla macchina stessa altri log. Tuttavia sono state incontrate diverse difficoltà legate alla modalità di ottenimento di tali dati. Sinteticamente, per accedere ai log macchina è necessario, infatti, accedere dal terminale della risonanza magnetica tramite le credenziali di accesso in dotazione esclusiva ai tecnici e ai field engineers autorizzati (di Philips).

## Le lavaendoscopi MEDIVATORS \textregistered ISA \textregistered

\FloatBarrier

A seguito di tali limitazioni, si è quindi spostata l'attenzione su un sistema più semplice rispetto ad una risonanza magnetica, ma caratterizzata da una modalità di generazione e salvataggio di log macchina utili ai fini predittivi. Su suggerimento di uno degli ingegneri biomedici del SIC, è stata individuata una famiglia di dispositivi medici chiamate lavaendoscopi, su cui poi è stato sviluppato un software di monitoraggio comprensivo di un modulo di manutenzione predittiva. In figura \ref{isa} è riportata una fotografia del dispositivo in questione.

![Lava-Sterilizzatrice MEDIVATORS\textregistered ISA\textregistered \label{isa}](vim_pred/img/isa.jpg){width="50%"}

Nello specifico, la Lava-Sterilizzatrice MEDIVATORS® ISA® è un dispositivo medico progettato per il lavaggio e la sterilizzazione chimica a freddo degli endoscopi rigidi e flessibili e degli accessori endoscopici.

In sintesi, il processo di utilizzo della macchina consiste in diverse fasi:

1. Accensione della macchina
2. Carico endoscopi nella vasca
3. Chiusura della vasca e selezione del ciclo di riprocessazione desiderato
4. Prelievo dell'endoscopio dalla vasca

In concomitanza con la fine di un ciclo di lavaggio, il dispositivo registra nel proprio hard disk tutte le informazioni relative a tutti ai cicli eseguiti creando un archivio elettronico consultabile in qualsiasi momento. Inoltre, è dotato di una stampante integrata che, al termine di ogni ciclo, stampa in automatico un report del ciclo. Il report è un documento essenziale per la convalida del ciclo e deve essere sempre conservato.

L'attenzione è stata posta proprio su questi report di stampa chiamati per brevità "scontrini". In figura \ref{scontrino} viene riportato un esempio di scontrino in formato digitale.

![Report stampato dalla lava-sterilizzatrice MEDIVATORS \textregistered ISA \textregistered \label{scontrino}](vim_pred/img/scont.png){height="70%"}

Sempre in riferimento alla figura \ref{scontrino}, i parametri inseriti in stampa sono:

- Data ed ora di inizio ciclo
- Dati strumento (categoria-s/n)
- Medico (opzionale)
- Paziente (opzionale)
- Tipo di ciclo eseguito
- Numero progressivo del ciclo
- Fasi del ciclo con relativi tempi di contatto e temperatura
- Esito del ciclo

Gli scontrini, quindi, rappresentano una buona fonte di dati per quanto riguarda lo stato di funzionamentio della macchina in quanto, come visto, essi riportano sia gli attori coinvolti nello specifico ciclo di lavaggio, sia gli eventuali allarmi registrati durante il lavaggio. Essi riportano inoltre variabili numeriche quali temperatura e tempi delle varie fasi del ciclo selezionato.

Con questi dati a disposizione si è indagata quindi la possibilità di prevedere, con un anticipo di 7 giorni, l'insorgenza di guasti tali da indurre il personale del reparto a richiedere un intervento di manutenzione correttiva al Global Service.

L'attività svolta si è articolata in diverse fasi, descritte nel dettaglio nei successivi paragrafi. Lo schema delle operazioni eseguite è riassunto nella figura \ref{schema}.

![Schema di lavoro \label{schema}](vim_pred/img/schema.pdf)

\FloatBarrier

## Raccolta Dati
La prima fase operativa è stata quella di raccolta ed estrapolazione degli scontrini dalle macchine in questione. Grazie alla responsabile del reparto di endoscopia e ad uno dei collaboratori tecnici del SIC, è stato possibile estrarre da una MEDIVATORS\textregistered ISA\textregistered, l'intero storico dei report di lavaggio conservati nell'hard disk della macchina per un totale di 5441 scontrini (pari a 3 anni di attività). I dati estratti sono stati salvati su una chiavetta USB e l'estrazione ha impiegato circa 20 minuti.

## Conversione dei file di backup
Per utilizzare le informazioni contenute negli scontrini estratti dalla memoria della macchina, sono stati scritti ed utilizzati diversi script utilizzando il linguaggio di programmazione R. Il primo tra questi ad essere progettato è stato quello responsabile della trasformazione dei 5441 file di testo in un unico file tabulare attraverso diverse funzioni scritte ad hoc. Questo script, chiamato "Analyzer.R" individua gli scontrini e riorganizza le informazioni estraibli da questi in un formato a righe e colonne (questo tipo di dato viene chiamato "dataframe" in R). In particolare, ogni riga corrisponde ad uno scontrino e ogni colonna rappresenta una "feature" identificabile nello scontrino stesso. Questo passaggio è stato necessario al fine di disporre di una struttura dati ben organizzata e coerente, indispensabile per le successive fasi di modellizzazione. La vera e propria conversione del dato avviene per mezzo di particolari pattern di ricerca chiamate "espressioni regolari" o "Regex" (Regular expression). Si è scelto di usare questo tipo di espressioni in quanto, sebbene tutti e i 5441 scontrini fossero file di testo diversi l'uno dall'altro, si basano sul concetto di sfruttare delle regolarità presenti in un dato testo ed estrapolarne informazioni di interesse. In sintesi, per la conversione degli scontrini si è organizzata la struttura degli stessi in 3 parti, per le quali sono state scritte funzioni di estrazione utilizzando le Regex citate precedentemente. La struttura degli scontrini è stata così separata:

1. **Intro**: parte introduttiva dello scontrino che reca il nome della macchina (Medivators ISA), il nome della ASST e il reparto di ubicazione della macchina. Queste righe, comuni a tutti gli scontrini, non apportano contenuto informativo utile ai fini predittivi e sono quindi stati scartati.
2. **Header**: questa parte di testo contiene alcune delle informazioni precedentemente elencate in riferimento alla figura \ref{scontrino}. Queste informazioni sono presentate (in tutti gli scontrini) con la stessa "struttura" ovvero: `NOME CAMPO: VALORE CAMPO`.
Di conseguenza sono state utilizzate due espressioni regolari per "estrarre" rispettivamente il NOME e il VALORE del campo:

    - NOME CAMPO: per estrarre il nome del campo si è utilizzata la seguente regex: `.*(?=: )`. I simboli utilizzati in una regex vengono chiamati "metacaratteri" e, nel caso della regex precedente, essi possono essere tradotti con la seguente istruzione: "Seleziona tutti i caratteri (tramite i metacaratteri `.*`) che precedono un carattere di due punti e spazio (tramite la metaistruzione chiamata 'positive lookahead' `(?=: )` )".
    - VALORE CAMPO: per estrarre invece il valore del campo si è utilizzata la seguente regex: `(?<=: ).*` che è esattamente speculare alla prima. In questa infatti vengono selezionati i caratteri che seguono il carattere ":" e lo spazio.
3. **Footer**: in questa parte sono elencate le varie fasi di lavaggio il cui nome è anteposto ad un timestamp corrispondente all'orario di inizio della fase stessa. Anche in questo caso, per estrarre il nome delle fasi di lavaggio, sono state utilizzate delle regex in modo tale da "estrarre" i caratteri che si trovavano in seguito ad un timestamp. In particolare, si è utilizzata la regex: `\\d\\d:\\d\\d:\\d\\d .*`

In figura \ref{header} sono riportati due scontrini ed evidenziate le tre parti descritte.

![Divisione degli scontrini nelle parti di Intro, Header e Footer \label{header}](vim_pred/img/header.pdf)

\FloatBarrier
Con operazioni simili a quelle descritte, ovvero analizzando il testo degli scontrini per trovare e sfruttare le regolarità presenti nel testo, si è costruita una funzione che ottenesse come input un file di testo, rappresentante lo scontrino, e che restituisse in uscita un dataframe composto da una sola riga. La funzione è stata poi fatta ciclare su tutto l'insieme di scontrini a disposizione ottenendo un'unica tabella da 5441 righe e 12 colonne (feature). È importante sottolineare il fatto che, tra le feature selezionate, ne è stata creata una che contenesse il testo dello scontrino "pulito" dai caratteri di punteggiatura e caratteri non alfanumerici. Il motivo di questa scelta sta nella decisione di sfruttare la natura "testuale" di questi log macchina utilizzando tecniche di text mining per costruire dei modelli predittivi basandosi esclusivamente sulle parole contenute nei diversi file testuali, andando a sfruttare quindi la struttura originaria del log macchina.

## Modellizzazione
La fase di modellizzazione è stata sicuramente quella su cui sono state incontrate più difficoltà.
5. **Scelta del modello ottimale**

Nei capitoli successivi verranno descritti gli algoritmi utilizzati nelle fasi di
