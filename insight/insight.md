# "INSIGHT"

In questo capitolo viene descritto in che modo si è arrivati alla decisione di sviluppare una web app (chiamata "INSIGHT") per il reparto di endoscopia. Vengono prima indicate le problematiche relative alla riprocessazione della strumentazione endoscopica e, per ognuna di esse, verrà descritto in che modo la web app sviluppata può essere d'aiuto nella razionalizzazione e nella successiva risoluzione delle stesse. Verrà inoltre trattata la strategia utilizzata per effettuare il _software deployment_ che ha reso disponibile l'applicazione sulla rete interna dell'ospedale, grazie al contributo dell'U.O.C. Sistemi Informativi Aziendali. Infine si evidenzieranno sia le criticità incontrate durante lo sviluppo del software, sia il riscontro all'utilizzo dell'app da parte del personale del reparto.


## Sviluppo

Parallelamente alla fase di modellizzazione descritta nel capitolo precedente, si è affrontato il problema di come rendere effettivamente utilizzabili le metodologie di analisi sviluppate. Tramite gli algoritmi per la conversione degli scontrini in tabelle, infatti, si hanno a disposizione dei metodi efficaci per tenere traccia di numerose informazioni relative ai cicli di lavaggio. Unitamente a ciò, si è sentita la necessità di fornire al reparto uno strumento che "digitalizzasse" tutte le attività di gestione legate alle lavaendoscopi, orbitanti intorno alla raccolta e alla conservazione degli scontrini in formato cartaceo, per poi essere consultati manualmente in fase di necessità.

Da queste considerazioni è nata l'idea di sviluppare un software che permettesse, tramite una dashboard altamente interattiva, di tenere sotto controllo diversi parametri relativi all'attività delle macchine sopracitate e che, tramite un'interfaccia user-friendly, fosse di facile utilizzo. Il software, più specificatamente una "web app", è stato sviluppato in R utilizzando il pacchetto "Shiny". Quest'ultimo racchiude diverse funzionalità utili per creare applicazioni interattive sfruttando il linguaggio di programmazione R.

La web app così sviluppata è stata chiamata "INSIGHT" proprio per la sua caratteristica di fornire all'utente una serie di informazioni numeriche circa le performance dei cicli di lavaggio effettuati, indicando quindi la situazione reale a partire dai dati di backup delle macchine. Oltre a ciò, "INSIGHT" è stata sviluppata integrando un modulo per la manutenzione predittiva, che verrà descritto più approfonditamente nei paragrafi successivi.

Dopo una fase di sviluppo preliminare, la web app è stata testata dalla responsabile di reparto e da una collaboratrice. Le osservazioni e le richieste del personale di reparto sono state cruciali per il miglioramento del software. In particolare, il reparto ha richiesto la possibilità di poter visualizzare:

- il numero e la tipologia di allarmi in relazione al tipo di dispositivo sottoposto a riprocessazione;
- il numero di cicli regolari e cicli irregolari per tipologia di dispositivo;
- il numero di cicli totali effettuati in un determinato periodo di tempo;
- gli operatori con il maggior numero di cicli irregolari;

Il software è quindi stato aggiornato aggiungendo, oltre alle features richieste, delle funzionalità aggiuntive per facilitarne l'utilizzo, come ad esempio un manuale utente [@ManualeUtenteINSIGHT] scritto sulla piattaforma di documentazione "gitbook".

## Funzionamento e interfaccia utente

L'interfaccia dell'applicazione è composta da due elementi principali: un menù di navigazione laterale chiamato "sidebar" e una parte centrale, chiamato "body", in cui vengono visualizzati i grafici e le tabelle relative ai vari menù selezionabili dalla sidebar.

\FloatBarrier

### Sidebar


Il primo elemento di interazione è rappresentato dal modulo di caricamento degli scontrini, posto in alto a sinistra nella sidebar. L'utente, tramite questo modulo, seleziona i file testuali (gli scontrini) che vuole analizzare e li carica nell'applicazione. Più nel dettaglio, il caricamento avviene in due fasi:

1. i file selezionati vengono copiati dalla cartella di origine in una cartella temporanea del pc in utilizzo;
2. si utilizza la cartella temporanea per effettuare il vero e proprio caricamento, che avviene in modo asincrono.

È stato riscontrato che i tempi di upload possono aumentare di molto se si utilizza un pc di fascia bassa. Questo perchè, come detto, la prima fase di caricamento consiste in una copiatura "interna" dei file tra una cartella e l'altra dello stesso computer, ininfluente quindi dalla qualità della connessione internet, che viene invece utilizzata per effettuare la seconda fase di caricamento.

Una volta completato l'upload dei file, gli algoritmi di trasformazione specificati nel capitolo precedente analizzano gli scontrini e all'utente viene chiesto di inserire un intervallo di date che si vuole indagare, tramite un date-picker. Il calendario è costruito in modo tale che siano selezionabili solamente effettivamentepresenti negli scontrini caricati

Selezionando un intervallo di date valido, all'utente viene poi richiesto di specificare, tramite un menù a tendina, il numero seriale della lavaendoscopi che si vuole analizzare. L'utente può selezionare diversi numeri seriali contemporaneamente, per avere una visione più generale. Una volta selezionate date e numero seriali, gli algoritmi interni all'applicazione filtrano tutti i dati secondo le specifiche indicate, permettendo all'utente di navigare tra i menù dell'applicazione.

Lo schema di funzionamento e gli elementi dell'interfaccia delle fasi sopracitate sono riportate nella figura seguente.
\FloatBarrier

![Sidebar, Date-picker e menù dei numeri seriali](insight/img/sidebar.pdf)


\FloatBarrier


Una volta seleionato un intervallo di date valido e un insieme di numeri seriali, l'utente può navigare tra le varie pagine dell'applicazione, visualizzando le diverse informazioni in modo dinamico rispetto alle scelte effettuate nella sidebar. Se infatti l'utente cambia la selezione del numero seriale, i grafici e le tabelle cambieranno in modo reattivo seguendo la scelta impostata dall'utente.

### Overview \label{over}
\FloatBarrier

![Overview \label{overview}](insight/img/overview.png)

Nella pagina chiamata "Overview" (figura \ref{overview}), l'utente ha a disposizione delle informazioni generiche sull'insieme di scontrini caricati. Nella parte superiore della pagina sono presenti 6 "info boxes" che presentano informazioni relative a:

1. giorni di attività analizzati;
2. numero di allarmi rilevati;
3. numero totale di cicli effettuati;
4. numero di cicli regolari e irregolari;
5. un box contenente il modulo di manutenzione predittiva;

I primi 4 box sono cliccabili e ogni box fornisce all'utente informazioni diverse. Cliccando ad esempio sul box corrispondente ai giorni di attività, l'applicazione restituisce una finestra "modale" (ovvero una finestra "figlia" che richiede all'utente di interagire con essa prima di ritornare alla finestra "madre") contenente una tabella interattiva (figura \ref{tab_mod_1}). Ogni riga di questa tabella corrisponde ad uno scontrino e ogni colonna corrisponde ad un campo relativo allo scontrino in esame. Inoltre, se l'utente clicca su una riga della tabella, a destra della stessa viene visualizzato il file testuale originario. La finestra modale è anche dotata di una funzione di ricerca di un termine all'interno di tutte le righe della tabella stessa e di pulsanti per il download della tabella in diversi formati (pdf, excel, csv e formato di stampa da browser Chrome).

![Tabella modale interattiva con visualizzazione print-out \label{tab_mod_1}](insight/img/tab_mod_1.png)

\FloatBarrier

Similmente, l'info box degli allarmi rilevati permette di essere cliccato per visualizzare una finestra modale in cui è presente una tabella che riporta solo gli scontrini in cui sono stati rilevati allarmi.

Una particolare nota va all'info box che riporta il numero totale dei cicli effettuati: cliccando su questo box è possibile visualizzare un diagramma di Sankey (figura \ref{sankey1}), uno specifico tipo di diagramma di flusso in cui la larghezza dei collegamenti tra un attore e l'altro del diagramma è direttamente proporzionale alla quantità in gioco nel flusso. In questo caso, il diagramma fornisce, per ogni numero seriale selezionato, il numero di cicli regolari e irregolari riscontrati suddivisi per categoria di strumento sottoposto a riprocessazione. Le quantità in gioco possono essere visualizzate passando il cursore del mouse sopra ad uno dei flussi rappresentati.

![Diagramma di Sankey dei cicli di lavaggio effettuati \label{sankey1}](insight/img/sankey1.png)

\FloatBarrier

Per quanto riguarda il modulo della manutenzione predittiva, invece, esso viene attivato una volta che viene cliccato dall'utente. In questo caso, all'utente viene presentato un grafico con l'andamento della probabilità di guasto nei successivi 7 giorni per ogni macchina selezionata nella sidebar. La probabilità di guasto viene calcolata utilizzando i modelli addestrati, descritti nel capitolo \ref{modeling}. Ogni modello infatti predice la probabilità, per un certo insieme di scontrini, di appartenere o meno ad uno dei già citati "giorni predittivi". Le predizioni dei vari modelli vengono poi mediate (secondo la logica del model averaging) per ottenere un'unica predizione che tenga conto sia dei punti di forza sia delle debolezze dei vari modelli utilizzati. Tuttavia, come visto nel capitolo precedente, i modelli sviluppati non presentano performance ottimali per essere considerati affidabili ed essere quindi utilizzati a livello professionale. Si è deciso comunque di implementare i modelli predittivi nella versione rilasciata presso l'ospedale, avvertendo preventivamente della loro inefficacia, a puro scopo dimostrativo.

Infine, la parte inferiore della schermata di overview permette di visualizzare l'andamento nel tempo del numero di cicli regolari e irregolari.

### Allarmi

\FloatBarrier

Questa pagina permette di indagare in modo più approfondito gli allarmi rilevati negli scontrini selezionati. È composta da una parte superiore in cui sono presenti dei grafici a barre orizzontali che mostrano, per ogni lavaendoscopi selezionata, il numero e la tipologia di allarmi divise per categoria di strumento, come indicato in figura \ref{allarmi1}.

![Allarmi per categoria di strumento \label{allarmi1}](insight/img/allarmi1.png)

\FloatBarrier

La parte inferiore è composta invece, a sinistra, da una serie di controlli con menù a tendina mentre a destra un visualizzatore per un diagramma di Sankey. L'utente, nel menù a sinistra, seleziona prima la categoria di strumento che si vuole analizzare, successivamente specifica i modelli dello strumento a disposizione e infine seleziona la tipologia di allarme di interesse. Considerando ad esempio l'immagine precedente (figura \ref{allarmi1}) si nota ad esempio che la categoria Gastroscope, nel periodo di tempo selezionato, è quella in cui sono comparsi più allarmi su diverse macchine. Il problema risiede in un particolare strumento, o gli allarmi sono distribuiti più o meno in modo uniforme tra tutti i modelli presenti? Come indicato in figura \ref{allarmi2}, per rispondere a queste domande si seleziona la categoria Gastroscope, si selezionano tutti i modelli presenti e tutte le categorie di allarme. Il diagramma di Sankey risultante sembrerebbe indicare che, dei 17 allarmi per la categoria Gastroscope, 6 di questi sono stati rilevati nel modello denominato GIF-XTQ160 e tutti e 6 corrispondenti alla categoria "Allarme canale 7 otturato". Gli allarmi fanno riferimento ad un unico strumento (di numero seriale 2000705) che ha fatto riscontrare diversi allarmi su 3 lavaendoscopi differenti (indicate con i numeri seriali a destra del diagramma).

![Diagramma di Sankey relativo alla categoria Gastroscope. Le quantità numeriche sono visualizzabili quando l'utente posiziona il cursore del mouse sui flussi del diagramma.\label{allarmi2}](insight/img/allarmi2.png)

\FloatBarrier

### Strumentazione

Anche questa sezione è stata divisa in una parte superiore (figura \ref{strum1}) e una inferiore (figura \ref{strum2}).

La parte superiore contiene un grafico a barre verticali che mostra il numero di cicli effettuati su ogni lavaendoscopi divisi per ogni categoria di strumento, evidenziando la distribuzione di cicli regolari e irregolari.

![Cicli eseguiti per categoria di strumento \label{strum1}](insight/img/strum1.png)

\FloatBarrier

Quella inferiore permette di selezionare una categoria di strumento per visualizzare, tramite una tabella del tutto simile a quelle presenti nella pagina "Overview" (paragrafo \ref{over}), i dettagli dei cicli (selezionabili tra regolari e irregolari grazie a delle sezioni sopra la tabella) riferiti alla categoria di strumento scelta.

![Tabella dei cicli regolari/irregolari per la categoria di strumento scelta \label{strum2}](insight/img/strum2.png)

\FloatBarrier

### Operatori

L'ultima sezione dell'app è composta, a sinistra, di una finestra di controlli in cui l'utente seleziona, da un menù a tendina, uno o più operatori e specifica di quale cicli vuole avere il conteggio (regolari o irregolari o entrambi) mentre, a destra, si ha un grafico a barre verticali in cui viene presentato il conteggio dei cicli per ciascun operatore selezionato. L'utente può inoltre scegliere se visualizzare il totale dei conteggi oppure separare il numero di cicli per ciascuna delle lavaendoscopi selezionate nella sidebar.

![Numero di cicli per operatore. Vista Totale \label{op}](insight/img/op.png)

Con questo strumento, è facile ad esempio determinare se un operatore ha ottenuto un numero di cicli irregolari troppo alto rispetto ai colleghi, nello stesso intervallo di tempo, in modo tale da poter indagare in modo mirato la radice del problema e provare quindi a risolverlo. Come evidenziato in figura \ref{op}, i grafici forniscono informazioni anche sulla tipologia di strumento che ha generato i cicli (regolari o irregolari), in modo da dare ulteriori informazioni numeriche, cosa che può essere di aiuto nel comprendere in maniera più dettagliata se il problema sia riferito effettivamente all'operatore o al singolo strumento.

Anche per i grafici di questa sezione viene specificato che l'utente può visualizzare ulteriori informazioni sui dati della singola osservazione spostando il cursore del mouse nel punto desiderato.

## Software deployment

Una volta ottenuta una versione semi-definitiva dell'applicazione, si è pensato a come poterla rendere accessibile al reparto di endoscopia. Applicazioni web di questo tipo, create con il pacchetto Shiny, possono essere gratuitamente "hostate" su internet grazie al servizio chiamato "Shinyapps.io" grazie al quale, previa registrazione, è possibile caricare un numero illimitato di applicazioni Shiny scegliendo tra diversi piani tariffari. Quello gratuito presenta delle limitazioni per quanto riguarda le ore di accesso ad e Upstart script will also ensure that shiny-server is respawned if the process is terminated unexpectedly. However, in the event that there is an issue that consistently prevents Shiny Server from being able to start (such as a bad configuration file), Upstart will give up on restarting the service after approximately 5 failed attempts within a few seconds. For this reason, you may see multiple repetitions of a bad Shiny Server startup attempt before it transitions to the stopped state.
una applicazione. In particolare, con questa opzione è possibile utilizzare una applicazione per non più di 25 ore mensili, allo scadere delle quali il server risponde con una pagina di reindirizzamento e impedendo l'accesso al servizio. Per ovviare a questo (piccolo) inconveniente e contemporaneamente per offrire all'ospedale un servizio completamente gratuito e senza limiti di utilizzo, si è richiesto il supporto dell'U.O.C Sistemi Informativi. Si è quindi indagata la possibilità di usufruire di un server (interno all'opsedale) su cui, previa configurazione delle porte di accesso e di varie impostazioni necessarie al corretto funzionamento dell'applicazione, è stato caricato il software.

Il server messo a disposizione è dotato di sistema operativo CentOS 7 (una distribuzione di Linux) e l'accesso all'applicazione è riservato solamente ai computer della rete ospedaliera. Il vantaggio di questa configurazione sta sicuramente nel fatto di avere a disposizione, per un numero illimitato di ore, l'applicazione sviluppata. Uno dei lati negativi sta tuttavia negli eventuali crash di sistema che possono incorrere durante l'utilizzo del software. In questo caso, l'applicazione deve essere riavviata tramite console di comando accedendo al server da una postazione abilitata.


## Criticità incontrate

La modalità di upload degli scontrini necessaria all'utilizzo dell'applicazione rimane problematica per quanto riguarda il caricamento di un alto numero di scontrini (situazione che può verificarsi spesso soprattutto se si decide di utilizzare l'applicazione a cadenza mensile o trimestrale).

La soluzione a questo problema è relativamente semplice: sfruttando la possibilità di collegare le lavaendoscopi alla rete dell'ospedale (tramite degli attacchi di rete presenti sulle macchine stesse) e configurando le stesse macchine per far sì che eseguano i backup su una cartella interna alla rete informatica dell'ospedale, i file degli scontrini potrebbero essere salvati direttamente sul server dove attualmente è installata "INSIGHT". La stessa applicazione dovrà quindi essere modificata in modo da eliminare definitivamente il passaggio obbligato di "caricamento", in quanto gli algoritmi di analisi degli stessi potrebbero essere eseguiti ogniqualvolta una lavaendoscopi esegua un ciclo di lavaggio. Così facendo, si avrebbe un monitoraggio quasi in real-time delle performance dei dispositivi. Una soluzione di questo tipo si presta bene anche a sviluppi futuri quali la progettazione e l'implementazione di un database nel quale poter inserire, di volta in volta, gli scontrini di lavaggio per avere a disposizione una struttura dati altamente organizzata e sicura sulla quale poter svolgere, secondo necessità, altre tipologie di analisi.
Tuttavia,l'applicazione di tale soluzione non è stata possibile in quanto la configurazione dei sopracitati attacchi di rete non è stata ancora eseguita.

La seconda critictà incontrata durante lo sviluppo riguarda la fase di software deployment e in particolare la necessità di dover riavviare manualmente il server di "INSIGHT" tramite console di comando nel caso di crash imprevisti.
Una soluzione a questo problema risiede in una modalità di sicurezza chiamata "Upstart" normalmente presente tra le configurazioni possibili di una applicazione Shiny. Con questa modalità è infatti possibile fare in modo che qualsiasi interruzione imprevista del servizio venga identificata e risolta tramite un riavvio del server. Di conseguenza, con questa modalità, un eventuale crash non determinerebbe la necessità di intervenire manualmente per riavviare il servizio. Purtroppo però questa modalità è attivabile solo su Ubuntu 14.04 e RedHat 6, quindi il sistema attualmente in uso può essere riavviato solo manualmente. La soluzione più semplice sarebbe quella di cambiare sistema operativo e ripetere l'installazione del software con il nuovo sistema.

## Feedback da parte del reparto di Endoscopia

Terminato lo sviluppo, è stato chiesto alla responsabile di reparto di testare l'applicazione e di riportare eventuali osservazioni e giudizi circa la sua utilità. "INSIGHT" è stata ritenuta una applicazione molto utile ed efficace per diversi aspetti:

- l'applicazione sviluppata presenta un menù laterale chiaro e lineare la cui navigazione procede dall'alto verso il basso, aiutando quindi l'utente a selezionare di volta in volta i campi necessari e guidandolo nell'esplorazione dei dati;
- l'applicazione non necessita di dischi di installazione o di licenze a pagamento. Per utilizzarla è sufficiente collegarsi ad uno specifico url e l'utilizzo della stessa è gratuito e illimitato;
- la possibilità di visualizzare l'andamento nel tempo del numero di cicli regolari e irregolari è uno strumento che, oltre ad un notevole risparmio di tempo rispetto al precedente calcolo eseguito analizzando uno ad uno gli scontrini cartacei, permette di tenere sotto controllo le prestazioni generali dei cicli di lavaggio in seguito ad interventi come ore di training aggiuntive o ad interventi di manutenzione sugli strumenti.
- i grafici a barre, gli info boxes e i diagrammi di flusso sono chiari e, grazie all'interattività, permettono di ottenere informazioni in modo rapido e preciso senza dover operare con fogli di calcolo o altri strumenti.

In generale, quindi, il software sviluppato si è dimostrato uno strumento utile per poter gestire le problematiche relative alla riprocessazione degli strumenti endoscopici su più livelli (analisi degli allarmi, strumentazione endoscopica e operatori).
