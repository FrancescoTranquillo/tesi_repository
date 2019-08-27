---
output:
  html_document: default
  pdf_document: default
---
# La manutenzione predittiva presso Vimercate \label {vim_pred}

In questo capitolo si parlerà dell'applicabilità di una strategia di manutenzione predittiva nell'ambito dell'Ospedale di Vimercate. In questi termini, verrà indicata innanzitutto la modalità di ricerca intrapresa al fine di identificare la classe di dispositivi di maggiore interesse e quella più adatta per essere analizzata con l'obiettivo di progettare e applicare un programma di manutenzione predittiva.
Si indagheranno quindi i requisiti necessari per l'applicabilità di questa tipologia di manutenzione, andando poi a valutare il parco macchine presente in ospedale dal punto di vista dell'applicabilità stessa. Nella seconda metà del capitolo verrà riportato il risultato della ricerca preliminare e si evidenzieranno, oltre ai risultati ottenuti dal punto di vista di algoritmi sviluppati, le criticità e le limitazioni incontrate.

## Indagine preliminare
Come visto nel capitolo precedente, la previsione dell'insorgenza di un guasto in un macchinario è ottenibile avendo a disposizione dati ottenuti tramite monitoraggio costante (preferibilmente real time) di variabili fisiche di interesse. Le più comuni variabili sottoposte a monitoraggio, per cui risulta relativamente semplice l'applicazione dello stesso, sono:

- Temperatura: monitorata attraverso termometri dotati di unità di memoria per il salvataggio e la successiva comunicazione in remoto dei dati misurati.
- Pressione: monitorata attraverso sensori applicati alle parti meccaniche di interesse.
- Ampiezza, fase e spettrometria delle vibrazioni meccaniche: variabili, queste, che risultano molto adatte ad essere studiate per il monitoraggio e la previsione dello stato di salute di un dispositivo meccanico sottoposto a movimenti ciclici, o di un componente dello stesso. L'analisi dello spettro delle frequenze si è dimostrato, in letteratura, una buona metodologia di indagine (ref).
- Tensioni e correnti: misurate, manualmente, attraverso amperometri e voltmetri e automaticamente attraverso letture "interne" effettuate dai software stessi dei macchinari.

Per l'individuazione di una classe di dispositivi adeguata per essere trattata e analizzata nell'ottica di manutenzione predittiva, ci si è avvalsi della consultazione sia del Global Service, sia del personale del SIC. I risultati di queste consultazioni possono essere sintetizzati nei seguenti punti:

- L'interesse comune rispetto all'applicazione di una strategia di manutenzione predittiva è indirizzato verso la minimizzazione del fermo macchina in tutte quelle apparecchiature elettromedicali considerati "ad alta incidenza", ovvero il cui guasto comporta importanti rallentamenti nell'erogazione dei servizi sanitari e l'applicazione clinica per il quale sono utilizzati interessa una grande parte del bacino di utenza della popolazione. Fanno parte di questa famiglia: TAC, Risonanze Magnetiche, Mammografi, ecografi, defibrillatori etc.
- Esiste, nel software attualmente utilizzato per la gestione delle apparecchiature elettromedicali (Coswin8i), una funzionalità che permetterebbe di monitorare le prestazioni di alcuni dispositivi per effettuare una sorta di manutenzione predittiva, ma quest'ultima risulta inutilizzata e la documentazione relativa risulta del tutto assente.
- Esistono molti dispositivi, in ospedale, che hanno una connessione internet per il collegamento alla rete dell'ospedale, ma nessuno di questi comunica dati fisici utili ad un'analisi di tipo predittivo sullo stato di salute del macchinario. Questa è la maggiore criticità incontrata.
- L'eventuale modifica di un apparecchio elettromedicale, anche se di proprietà dell'ospedale, al fine dell'inserimento di sensori utili alla raccolta di dati fisici (come un semplice termometro) risulterebbe in una invalidazione della certificazione CE, garanzia della sicurezza del dispositivo, innalzando il rischio (sia per il paziente, sia per l'operatore) relativo all'utilizzazione dello stesso.

Si ha quindi una situazione generale dove risulta difficile, per l'Azienda Ospedaliera in generale e per Ingegneria Clinica in particolare, pensare di poter applicare una metodologia di manutenzione così avanzata. Tuttavia, il sistema informativo presente in Ospedale ha, come si vedrà più avanti nel capitolo \ref{insight} relativo allo sviluppo del software , tutti i requisiti per poter, in futuro, ospitare un sistema di manutenzione di questo tipo.

## L'analisi dei log macchina \label{logs}

A fronte della situazione delineata si è cercato di sfruttare sistemi e risorse attualmente disponibili in Azienda, per ottenere dei risultati che, sebbene non paragonabili alla "manutenzione predittiva" eseguita in altri settori (come quello manifatturiero), dimostrano l'esistenza di possibilità pratiche, per l'Ospedale, di indirizzarsi su un percorso di profondo sviluppo tecnologico dove la digitalizzazione, la data engineering, l'IoT e applicazioni di intelligenza artificiale hanno e avranno un ruolo predominante.

In questo contesto, è necessario fare riferimento alle variabili fisiche precedentemente descritte e ai sensori responsabili delle loro misurazioni. In realtà, tutte le variabili citate possono essere soggette a monitoraggio automatico "interno" in quei macchinari dotati di un sistema computerizzato. Queste e molte altre letture ed analisi sui processi svolti vengono condotte dai computer, installati all'interno dei macchinari, in modo automatico e a frequenza variabile (impostata dal produttore) per poi essere salvate in file di memoria chiamati _"log"_ (o più comunemente log macchina). I log macchina, nei sistemi progettati per produrli, rappresentano un sistema di autodiagnostica utile ai fini del controllo del normale funzionamento del dispositivo da parte del personale tecnico. Si pensi infatti al caso di manutenzione correttiva effettuata sulla risonanza magnetica Philips Achieva (d'ora in avanti chiamata Achieva per brevità) descritto nel capitolo \ref{es_corr}. In quel frangente, il personale tecnico di Philips ha estratto e caricato i log macchina generati dalla Achieva in un software proprietario in grado di riassumere i log e di fornire al tecnico un rapido riassunto di tutti gli eventi (interni) che hanno interessato la macchina.

La ricerca si è indirizzata, a fronte delle criticità incontrate, nell'analisi dei log macchina al fine di costruire dei modelli predittivi sullo stato di salute del dispositivo che li ha generati.

In particolare, per l'attività si è fatto principalmente riferimento allo studio condotto da Sipos et al. [@siposLogbasedPredictiveMaintenance2014] nel quale ci si è avvalsi di diversi Terabytes di log macchina estratti da diverse migliaia di risonanze magnetiche prodotte da Siemens \textregistered. La quantità di dati a disposizione, come si vedrà, rappresenta una dei principali requisiti per la modellizzazione di algoritmi di machine learning perchè, dalla stessa, dipendono fortemente le capacità di apprendimento del modello che si vuole sviluppare.

In questo studio, gli autori evidenziano tre principali problematiche relativo all'utilizzo dei log macchina per la predizione dei guasti. Esse possono essere così riassunte:

1. I log macchina, essendo progettati per supportare personale tecnico nella risoluzione di problemi di tipo informatico (attività di _debugging_), raramente contengono informazioni esplicite per la predizione di un guasto del macchinario.
2. I log contengono dati di tipo eterogeneo tra cui: sequenze simboliche, serie temporali numeriche, testi non strutturati e variabili categoriche. Questa particolarità aggiunge uno strato di complessità all'analisi di questo tipo di dati.
3. I log contengono una grande quantità di dati, il che pone delle sfide dal punto di vista dell'efficienza computazionale.

Elemento imprescindibile per poter effettuare delle analisi predittive è la disponibilità di dati relativi ad interventi di manutenzione passati effettuati sulla macchina in esame. Grazie a questi, infatti, è possibile correlare ogni guasto avvenuto (noto) con il corrispondente insieme di log macchina.

Partendo da questi presupposti si è cercato, in un primo tentativo, di utilizzare i log macchina derivanti dalla Achieva estratti in concomitanza con l'intervento di manutenzione correttiva descritto nel capitolo \ref{es_corr}. Tuttavia, i dati a disposizione estratti facevano riferimento a pochi giorni di attività della macchina, insufficienti ad essere utilizzati per condurre un'analisi che desse buoni risultati. Si è presentata quindi la necessità di reperire dalla macchina stessa altri log. Tuttavia, come evidenziato capitolo sopracitato, le modalità di acquisizione dei log non hanno reso possibile la copia e l'utilizzo di altri dati.

## Le lavaendoscopi MEDIVATORS \textregistered ISA \textregistered \label{ivamed}

\FloatBarrier

A seguito di tali limitazioni, si è spostata l'attenzione su un sistema più semplice rispetto ad una risonanza magnetica, ma caratterizzata da una modalità di generazione e salvataggio di log macchina utili ai fini predittivi. Su suggerimento di uno degli ingegneri biomedici del SIC, è stata individuata una famiglia di dispositivi medici chiamate lavaendoscopi, su cui poi è stato sviluppato un software di monitoraggio comprensivo di un modulo di manutenzione predittiva. In figura \ref{isa} è riportata una fotografia del dispositivo in questione.

![Lava-Sterilizzatrice MEDIVATORS\textregistered ISA\textregistered \label{isa}](vim_pred/img/isa.jpg){width=36%}

Nello specifico, la Lava-Sterilizzatrice MEDIVATORS® ISA® è un dispositivo medico progettato per il lavaggio e la sterilizzazione chimica a freddo degli endoscopi rigidi e flessibili e degli accessori endoscopici.

In sintesi, il processo di utilizzo della macchina consiste in diverse fasi:

1. accensione della macchina;
2. carico endoscopi nella vasca;
3. chiusura della vasca e selezione del ciclo di riprocessazione desiderato;
4. prelievo dell'endoscopio dalla vasca;

In concomitanza con la fine di un ciclo di lavaggio, il dispositivo registra nel proprio hard disk tutte le informazioni relative a tutti ai cicli eseguiti creando un archivio elettronico consultabile in qualsiasi momento. Inoltre, è dotato di una stampante integrata che, al termine di ogni ciclo, stampa in automatico un report del ciclo. Il report è un documento essenziale per la convalida del ciclo e deve essere sempre conservato.

L'attenzione è stata posta proprio su questi report di stampa chiamati per brevità "scontrini". In figura \ref{scontrino} viene riportato un esempio di scontrino in formato digitale.

![Report stampato dalla lava-sterilizzatrice MEDIVATORS \textregistered ISA \textregistered \label{scontrino}](vim_pred/img/scont.PNG){width=40%}

Sempre in riferimento alla figura \ref{scontrino}, i parametri inseriti in stampa sono:

- data ed ora di inizio ciclo;
- dati strumento (categoria-s/n);
- medico (opzionale);
- paziente (opzionale);
- tipo di ciclo eseguito;
- numero progressivo del ciclo;
- fasi del ciclo con relativi tempi di contatto e temperatura;
- esito del ciclo;

Gli scontrini rappresentano una buona fonte di dati per quanto riguarda lo stato di funzionamentio della macchina in quanto, come visto, essi riportano sia gli attori coinvolti nello specifico ciclo di lavaggio, sia gli eventuali allarmi registrati durante il lavaggio. Essi riportano inoltre variabili numeriche quali temperatura e tempi delle varie fasi del ciclo selezionato.

Con questi dati a disposizione si è indagata quindi la possibilità di prevedere, con un anticipo di 7 giorni, l'insorgenza di guasti tali da indurre il personale del reparto a richiedere un intervento di manutenzione correttiva al Global Service.

L'attività svolta si è articolata in diverse fasi, descritte nel dettaglio nei successivi paragrafi.

\FloatBarrier

## Raccolta Dati
La prima fase operativa è stata quella di raccolta ed estrapolazione degli scontrini dalle macchine in questione. Grazie alla responsabile del reparto di endoscopia e ad uno dei collaboratori tecnici del SIC, è stato possibile estrarre da una MEDIVATORS\textregistered ISA\textregistered, l'intero storico dei report di lavaggio conservati nell'hard disk della macchina per un totale di 5441 scontrini (pari a 3 anni di attività). I dati estratti sono stati salvati su una chiavetta USB e l'estrazione ha impiegato circa 20 minuti.

## Conversione dei file di backup \label{preprocessing}
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
Con operazioni simili a quelle descritte, ovvero analizzando il testo degli scontrini per trovare e sfruttare le regolarità presenti nel testo, si è costruita una funzione che ricevesse come input un file in formato .txt, rappresentante lo scontrino, e che restituisse in uscita un dataframe composto da una sola riga. La funzione è stata poi fatta ciclare su tutto l'insieme di scontrini a disposizione ottenendo un'unica tabella da 5441 righe e 12 colonne (features). Un esempio del dataframe generabile dalla funzione descritta è riportato in figura \ref{tab.fun}.

![Tabella ottenuta dalla conversione dei file testuali degli scontrini. \label{tab.fun}](vim_pred/img/tab.PNG)

\FloatBarrier

È importante sottolineare il fatto che, tra le feature selezionate, ne è stata creata una che contenesse il testo dello scontrino "pulito" dai caratteri di punteggiatura e caratteri non alfanumerici. Il motivo di questa scelta sta nella decisione di sfruttare la natura "testuale" di questi log macchina utilizzando tecniche di text mining per costruire dei modelli predittivi basandosi esclusivamente sulle parole contenute nei diversi file testuali, andando a sfruttare quindi la struttura originaria del log macchina.

## Modellizzazione \label{modeling}
La fase di modellizzazione è stata sicuramente quella in cui sono state incontrate più difficoltà, principalmente dovute, come si vedrà, ad un non sufficiente numero di dati a disposizione. Innanzitutto, è stato necessario estrarre dal software di manutenzione "Coswin8i" utilizzato in ospedale, lo storico delle manutenzioni effettuate sulla macchina da cui sono stati estratti gli scontrini. Sono state, quindi, incrociate le date presenti sugli scontrini con quelle riportate dal servizio di manutenzione, così da avere la possibilità di studiare gli scontrini corrispondenti a 7 giorni precedenti all'effettiva chiamata al Global Service (d'ora in avanti chiamati per brevità "giorni predittivi"). Tentativo di questo lavoro è stato quello di correlare i guasti della lavaendoscopi alle informazioni contenute negli scontrini dei giorni predittivi, al fine di ottenere un modello di predizione in grado di calcolare probabilità di guasto delle lavaendoscopi utilizzando, per l'apprendimento del modello, i file di backup corrispondenti a 3 anni di attività raccolti dalla macchina stessa.


### Apprendimento ad istanza multipla \label{mil}

Per costruire tale modello è stato prima indagato l'approccio di apprendimento migliore, in riferimento al capitolo \ref{digital}, ed è stato scelto, sulla base di un precedente lavoro trovato in letteratura, una tipologia di apprendimento supervisionato chiamato "Apprendimento ad Istanza Multipla" (Multiple instance learning, MIL). In questa metodologia, il classificatore non riceve una serie di esempi indipendenti $x_{i}$ caratterizzati da una etichetta (l'output desiderato $t_{i}$) come avviene nel classico apprendimento supervisionato, ma riceve un insieme di "borse" o "contenitori" a cui viene associata un'etichetta che rappresenta l'output che dovrà imparare a produrre. Ogni "borsa" può contenere più istanze, corrispondenti in questo caso agli scontrini di un giorno di attività, e, nello specifico, una "borsa" viene etichettata come "positiva" se contiene al suo interno scontrini appartenenti ad un "giorno predittivo" e "negativa" altrimenti. Di conseguenza, il classificatore desiderato è stato progettato per classificare una borsa di scontrini come positiva o negativa, a seconda delle informazioni contenute negli scontrini di un singolo giorno. Uno schema riassuntivo dell'approccio descritto è riportato in figura \ref{mil-schema}.

\FloatBarrier

![Apprendimento ad istanza multipla. La prima borsa è associata ad una etichetta "negativa" in quanto al di fuori dell'intervallo di predizione dei 7 giorni. \label{mil-schema}](vim_pred/img/mil.pdf)

\FloatBarrier

Successivamente al raggruppamento degli scontrini in "borse", si è cercato di risolvere il problema di classificazione riducendo la complessità generale passando cioè dall'approccio MIL a quello più standard di apprendimento supervisionato. Questo è stato reso possibile grazie alla trasformazione di tutti gli scontrini presenti in una singola borsa in un unico "metascontrino", detto specificatamente "metaesempio", consistente un'unica osservazione generata tramite la sintetizzazione delle informazioni presenti in tutti gli scontrini della stessa borsa. Così facendo non si hanno più degli insiemi di scontrini contenenti diverse osservazioni, ma, allineandosi al più tradizionale approccio di apprendimento supervisionato, si ha una serie di osservazioni (i metascontrini) caratterizzate da un'etichetta unica. Quest'ultima struttura così ottenuta, associabile ad una tabella, risulta più semplice da gestire per quanto riguarda la modellizzazione di un algoritmo di predizione in quanto le librerie utilizzate per l'apprendimento dei modelli di predizione richiedono spesso una struttura dati di questo tipo.

### Text mining: creazione del Corpus

Per creare questi "metascontrini" sono state utilizzate diverse tecniche di Text Mining sfruttando le capacità della libreria R chiamata "tm", diminutivo, appunto, di "text mining".

Il Text Mining consiste nell'applicazione di tecniche di Data Mining a testi non strutturati (agenzie stampa, pagine web, e-mail, ecc.) e più in generale a qualsiasi "corpus" di documenti, allo scopo di:

- individuare i principali gruppi tematici;
- classificare i documenti in categorie predefinite;
- scoprire associazioni nascoste (legami tra argomenti, o tra autori, trend temporali, ...);
- estrarre informazioni specifiche (es: nomi di geni, nomi di aziende, ...);
- addestrare motori di ricerca;
- estrarre concetti per la creazione di ontologie (ontology learning).

Vista la natura prettamente testuale degli scontrini, si è deciso di utilizzare alcune delle metodiche proprie del Text Mining al fine di trasformare il testo di ogni scontrino in un insieme di features da utilizzare per la creazione di un modello di predizione. Questa scelta rappresenta un approccio innovativo al tema della manutenzione predittiva. Infatti, oltre all'utilizzo del Text Mining nel lavoro di Sipos et al. [@siposLogbasedPredictiveMaintenance2014], attualmente non esistono in letteratura casi riportati di utilizzo di queste tecniche applicate al tema della manutenzione predittiva che, infatti, si basa più comunemente sull'analisi numerica di variabili fisiche misurate per via diretta o derivata.

A partire dalla feature chiamata "testo", creata dalla funzione descritta nel paragrafo \ref{preprocessing}, è stato quindi creato un "corpus", ovvero una collezione di documenti, per ognuna delle "borse" di scontrini. Esplorando i primi 5 documenti di un corpus, per esempio, si ottiene:

\newpage

\begin{lstlisting}[frame=single]
<<VCorpus>>
Metadata:  corpus specific: 0, document level (indexed): 0
Content:  documents: 5

[[1]]
<<PlainTextDocument>>
Metadata:  7
Content:  chars: 115

[[2]]
<<PlainTextDocument>>
Metadata:  7
Content:  chars: 90

[[3]]
<<PlainTextDocument>>
Metadata:  7
Content:  chars: 55

[[4]]
<<PlainTextDocument>>
Metadata:  7
Content:  chars: 290

[[5]]
<<PlainTextDocument>>
Metadata:  7
Content:  chars: 115

\end{lstlisting}
\newpage
Nell'output precedente è intuibile la struttura del corpus: ogni elemento dello stesso viene identificato come un "PlainTextDocument" il cui contenuto è dato da un variabile numero di caratteri testuali. Esplorando il primo documento è possibile leggere il testo del relativo scontrino, pulito precedentemente da eventuali caratteri speciali, punteggiatura e numeri:

\begin{lstlisting}[frame=single]
<<PlainTextDocument>>
Metadata:  7
Content:  chars: 115

tipo ciclo complete disinfection test di tenuta allarme pressione minima test di tenuta fine ciclo ciclo irregolare
\end{lstlisting}

### Text mining: Document Term Matrix

Il passo successivo è stato quello di convertire i corpora creati in una struttura a matrice tipicamente utilizzata in applicazioni di text mining chiamata "Document Term Matrix". Questo tipo di matrice è composta da un numero di righe pari al numero di documenti presenti in un corpus e da tante colonne quanti sono i termini presenti in tutti i documenti dello stesso, presi una sola volta. Il valore all'incrocio di una riga e di una colonna determina la tipologia di "peso" che viene assegnato ad ogni termine rispetto ad ogni documento. Tra le "pesature" possibili, si riportano quelle più comunemente utilizzate in questo tipo di applicazioni:

 1. **Term Frequency (tf)**: indicata con $tf(t,d) = f_{t,d}$ rappresenta il conteggio delle volte in cui è presente un termine $t$ in un documento $d$.
 2. **Term Frequency - Inverse Document Frequency (tf-idf)**: definita come il prodotto tra la Term Frequency ed la Inverse Document Frequency. Quest'ultima è una misura del quantitativo informativo che una parola apporta rispetto alla sua frequenza in un set di documenti. Matematicamente è definita come:

 \begin{equation}
 \sf idf(t,D) = \log(\frac{N}{n_{t}})
 \label{eq:idf}
 \end{equation}

 dove:

  - $N$ rappresenta il numero di documenti nel corpus
  - $n_{t}$ è il numero di documenti in cui compare il termine t


Di conseguenza, la tf-idf è definita come:

\begin{equation}
\sf tfidf(t,d,D) = \sf tf(t,d)\cdot \sf idf(t,D) = \sf f_{t,d}\cdot\log(\frac{N}{n_{t}})
\label{eq:tfidf}
\end{equation}

In figura \ref{tfidf_plot} viene riportato un esempio di come la pesatura tramite tf-idf tenda ad agire come un "filtro" per i termini più comuni, prendendo come esempio due termini presenti in uno stesso documento con la stessa frequenza. Si osserva, infatti, che a pari frequenza corrisponde un punteggio che è maggiore per i termini che compaiono meno frequentemente nel corpus.


```{r,echo=FALSE,warning=FALSE ,message=FALSE,fig.align='center',fig.cap="\\label{tfidf_plot}Valore dato dalla tf-idf per due termini generici $t_{1}$ e $t_{2}$, ipotizzando la stessa frequenza ($f_{d,t_{1,2}}=3$) all'interno di un generico documento $d$. $t_{1}$ compare in meno documenti del corpus ($n_{t_{1}}=4$), di conseguenza il suo peso risulta maggiore."}

library("ggplot2",verbose = F,quietly = T)
library("viridis",verbose = F,quietly = T)
library("hrbrthemes",verbose = F,quietly = T)
library("tidyverse",verbose = F,quietly = T)
library("ggthemes",verbose = F,quietly = T)


eq = function(x){3*log(50/x)}


col <- "#A50104"
df = data.frame(x=c(4,40), y=eq(c(4,40)), name=c("t[1]", "t[2]"))
ggplot(data.frame(x=c(1, 50)), aes(x=x)) +
  stat_function(fun=eq,
                geom="line",
                size=0.7,
                colour="black") +
  labs(x=expression("n"[t]), y="TF-IDF")+
  geom_point(data=df,aes(x=x, y=y) ,fill=col,size=2.5, shape=21,stroke=0.8,colour="black")+
  geom_text(data=df,aes(x=x, y=y,label=name),vjust=-1.35,parse=T, hjust=-.13, colour="black")+
  theme_economist_white()+
  theme(panel.grid.major = element_blank(),panel.background = element_blank(),plot.background = element_blank())

```

Tra le due metodologie di pesatura elencate, è stata scelta la seconda. Questo perchè la natura degli scontrini può essere meglio caratterizzata dai termini relativi a guasti e allarmi, che sono infatti meno frequenti rispetto a quelli che indicano un comportamento normale dell'apparecchiatura.
È stato inoltre costruito un corpus "generale" utilizzando come documenti tutti gli scontrini a disposizione in modo tale da valutare la frequenza dei termini più comuni e di quelli "tipici" di uno scontrino "anomalo" è evidenziata nel grafico a barre in figura \ref{barplotfig}.

```{r, fig.height=6,echo=FALSE, message=F, fig.align='center',fig.cap="\\label{barplotfig}Frequenza dei 40 termini più comuni nel corpus generale degli scontrini."}
library("ggplot2",verbose = F,quietly = T)
library("viridis",verbose = F,quietly = T)
library(tidyverse,verbose = F,quietly = T)
library(tm,verbose = F,quietly = T)
library(magrittr,verbose = F,quietly = T)
library(viridis,verbose = F,quietly = T)
library(ggthemes,verbose = F,quietly = T)
library(hrbrthemes,verbose = F,quietly = T)
library(here,verbose = F,quietly = T)



df2 <- read.csv2(here::here("Data/ISA/tabella_scontrini_text.csv"),stringsAsFactors = F)


df2$testo <- iconv(df2$testo,"UTF-8", "UTF-8",sub='')

clean_corpus <- function(corpus) {
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeNumbers)

  # corpus <- tm_map(corpus, stemDocument)
}


corpus <- VCorpus(VectorSource(df2$testo)) %>%
    clean_corpus(.)
  bag_dtm <- as.data.frame(as.matrix(DocumentTermMatrix(
    corpus,
    control = list(weighting = function(x) weightTfIdf(x))
  )))
  tfidf <- summarise_all(bag_dtm, mean, na.rm = T)

  tdm <- TermDocumentMatrix(corpus)

wordFreq=data.frame(apply(tdm,1,sum))
names(wordFreq)="Frequency"
wordFreq$Terms=row.names(wordFreq)

col_termini <- "#A50104"

row.names(wordFreq)=NULL
wordFreq=wordFreq[,c(2,1)]

wordFreq %<>% mutate(irregolare=factor(ifelse(Terms%in%c("irregolare", "allarme", "scollegato", "otturato", "perdita"),yes = 1,no = 0))) %>%
  mutate(tick.color=ifelse(irregolare==1, col_termini,"grey30"))

subset <- subset(wordFreq, irregolare==1)

wordFreq <- top_n(n=40, wt=Frequency,x=wordFreq)
wordFreq$Terms <- factor(wordFreq$Terms)
colors <- wordFreq$tick.color[order(wordFreq$Frequency)]
ggplot(wordFreq,
       aes(x = reorder(Terms, Frequency), Frequency, fill = irregolare)) +
       geom_bar(stat = "identity", color = "black",alpha=1,size=0.3) +
       scale_fill_manual(values = c("0" = "#A2AEBB", "1" = col_termini)) +
       labs(x = "Termini nel corpus", y = "Frequenza nel corpus") +
       geom_text(
       data = subset,
       aes(
       x = reorder(Terms, Frequency),
       y = Frequency,
       label = Frequency

       ),
       inherit.aes = F,
       vjust = 0.28,
       hjust = -0.19,
       size =3 ,
       color=col_termini
       ) +  theme_economist_white()+
        coord_flip() + guides(fill = F) +
       theme(axis.text.y = element_text(color = colors,size=10),
             panel.grid.major = element_blank(),
             panel.background = element_blank(),
             plot.background = element_blank())

```



La rarità dei termini che riflettono un comportamento anomalo è diretta conseguenza della poca frequenza con cui si verificano eventi di guasto. Dal software di gestione della manutenzione, infatti, è stato riscontrato che la macchina in questione è stata interessata da 47 interventi di manutenzione correttiva. Su circa 800 giorni di attività della macchina i guasti sono da considerarsi come eventi estremamente rari, interessando infatti poco più del 5% dei giorni di attività totali.

È parso ragionevole, al fine di discriminare in modo ottimale un comportamento anomalo da uno nominale, assegnare un peso maggiore ai termini con una frequenza relativa minore tramite la tf-idf descritta sopra.

A seguito di queste considerazioni, si riportano, a solo scopo di esempio, le prime 5 righe di una Document Term Matrix ottenuta dalla trasformazione di uno dei corpora ottenuti.


```{r, fig.height=6,echo=FALSE, message=F}
library("ggplot2",verbose = F,quietly = T)
library("viridis",verbose = F,quietly = T)
library(tidyverse,verbose = F,quietly = T)
library(tm,verbose = F,quietly = T)
library(magrittr,verbose = F,quietly = T)
library(viridis,verbose = F,quietly = T)
library(ggthemes,verbose = F,quietly = T)
library(hrbrthemes,verbose = F,quietly = T)
library(here,verbose = F,quietly = T)



df2 <- read.csv2(here::here("Data/ISA/tabella_scontrini_text.csv"),stringsAsFactors = F)


df2$testo <- iconv(df2$testo,"UTF-8", "UTF-8",sub='')

clean_corpus <- function(corpus) {
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeNumbers)

  # corpus <- tm_map(corpus, stemDocument)
}


corpus <- VCorpus(VectorSource(df2$testo)) %>%
    clean_corpus(.)
  bag_dtm <- as.data.frame(as.matrix(DocumentTermMatrix(
    corpus,
    control = list(weighting = function(x) weightTfIdf(x))
  )),row.names = paste("Scontrino", c(1:5328)))
  tfidf <- summarise_all(bag_dtm, mean, na.rm = T)

  tdm <- TermDocumentMatrix(corpus)

  library(kableExtra)
  kable(bag_dtm[1:5,which(colnames(bag_dtm)%in%c("allarme", "regolare", "irregolare", "disinfezione", "ciclo","sterilizzante"))], "latex", align = "c", booktabs = T, caption = "Document Term Matrix")%>%
  kable_styling(latex_options = "HOLD_position")
```


\FloatBarrier

### Fase di training e testing

Una volta raggruppati gli scontrini in borse corrispondenti a 7 giorni di attività, ad ogni borsa è stata assegnata la label "positiva", se tra gli scontrini della borsa era presente almeno uno corrispondente ad uno dei giorni "predittivi", definiti nel paragrafo \ref{mil}, "negativa" altrimenti. Le borse sono poi state ridotte ad un'unica osservazione (metascontrino) mediando i valori della DTM per ogni termine presente al suo interno.

Successivamente, i dati sono stati divisi in gruppo di training e testing (chiamati d'ora in avanti training e test set), sui quali è stato costruito il modello di predizione. Per il processo di training è stato utilizzato un pacchetto di R chiamato "caret" (acronimo di "<strong>C</strong>lassification <strong>A</strong>nd <strong>RE</strong>gression <strong>T</strong>raining"), contenente un gruppo di funzioni che facilitano la creazione di modelli predittivi tramite strumenti per la divisione dei dati in gruppo di training e testing (data splitting), pre-processamento dei dati, ottimizzazione dei modelli (model tuning) e altre funzionalità.

Specificatamente, nella fase di training, le funzioni nel pacchetto caret si occupano di:

- valutare, ripetendo le operazioni di addestramento di un modello tramite ri-selezione dei dati (resampling), l'effetto dei parametri di ottimizzazione (ovvero i parametri specifici di un modello, come $\alpha$ e $\beta$ della di una regressione logistica, descritti nel capitolo \ref{logregcap}) sulle performance di predizione;
- scegliere il modello "ottimale" tra questi parametri;
- stimare le performance del modello dal training set.

In particolare, per agevolare la fase di training e test, è stata creata una funzione in grado di allenare diversi modelli, definiti da una lista scelta dall'utente, in modo sequenziale e di salvare le performance di predizione di ogni modello in una tabella consultabile a fine addestramento. Questo ha aiutato nella scelta del modello ottimale, in quanto è stato possibile confrontare diversi risultati di addestramento al variare di alcune opzioni di modellizzazione come ad esempio il metodo di resampling, la scelta dei modelli e la modalità di creazione dei metascontrini.

\newpage

## Scelta del modello ottimale

Prima di introdurre i risultati, si riportano di seguito le definizioni delle statistiche utilizzate per la valutazione delle performance dei modelli sviluppati. Si utilizza come riferimento una matrice di confusione, struttura spesso utilizzata per valutare le performance di un modello di classificazione binaria (anche se facilmente estendibile al caso di classificazione multipla) caratterizzata dalla seguente struttura:



```{r, echo=FALSE}

# 98 9 n 27 8
library(knitr)
library(kableExtra)
df <- data.frame("Previsione"=c("Previsione","Previsione"),
                 "Oss"=c("Negativi", "Positivi"),
                 "Negativi"=c(paste0("TN",footnote_marker_number(1,"latex")),paste0("FN",footnote_marker_number(2,"latex"))),
                 "Positivi"=c(paste0("FP",footnote_marker_number(3,"latex")),paste0("TP",footnote_marker_number(4,"latex")))
               )

kable(df, col.names=c(" "," ", "Negativi", "Positivi"),escape = F, caption = "Matrice di confusione",booktabs=T, format="latex",align = "c") %>%
  kable_styling(latex_options = "HOLD_position")%>%
  add_header_above(c(" "," ","Riferimento" = 2),line=F) %>%
  column_spec(1:2, bold = F) %>%
  collapse_rows(1:2,valign="middle", latex_hline="none") %>%
  footnote(number = c("True Negative: osservazioni classificate come negative, in modo corretto",
  "False Negative: osservazioni classificate come negative, erroneamente",
  "False Positive: osservazioni classificate come positive, in modo corretto",
  "True Positive: osservazioni classificate come positive, erroneamente"),threeparttable = F)

```

Dalla tabella è possibile definire le seguenti statistiche:

- **accuratezza**: rapporto tra le osservazioni classificate correttamente e il numero totale di osservazioni $$Accuracy = \frac{TP+TN}{TP+TN+FP+FN}$$
- **sensitività**: chiamata anche recall o true positive rate, è definita come il rapporto tra i veri positivi e i positivi totali
$$Sensitivity = \frac{TP}{TP+FN}$$
- **specificità**: definita come il rapporto tra i veri negativi e i negativi totali
$$Specificity = \frac{TN}{TN+FP}$$
- **precisione**: definita come il rapporto tra i veri positivi e la somma tra veri positivi e falsi positivi
$$Precision = \frac{TP}{TP+FP}$$


In un caso come questo di manutenzione predittiva, in cui gli eventi di guasto rappresentano la classe caratterizzata da una frequenza minore rispetto al normale comportamento del macchinario, la statistica di accuratezza non è un buon indice per valutare la bontà di un classificatore che ha come compito quello di identificare, appunto, comportamenti anomali. In casi come questi, in cui è presente uno sbilanciamento tra classi, è meglio fare affidamento su altre statistiche come sensitività, specificità e precisione, perchè esse tengono meglio conto della capacità del classificatore di discriminare tra eventi "positivi", di guasto, e "negativi".

Di seguito si riportano le performance di predizione dei modelli ottenuti.


\begin{table}[H]
\caption{\label{tab:performance}Performance dei modelli ottenuti}
\centering
\begin{tabular}{>{\raggedright\arraybackslash}p{14em}lllll}
\toprule
Model name & Accuracy & Sensitivity & Specificity & Precision\\
\midrule
Bayesian Generalized Linear Model & 0.75 & 0.23 & 0.92 & 0.47\\
Generalized Linear Model & 0.39 & 0.21 & 0.89 & 0.25\\
Naive Bayes & 0.73 & 0.11 & 0.93 & 0.36\\
Neural Network & 0.71 & 0.11 & 0.91 & 0.29\\
Support Vector Machine (Linear Kernel) & 0.73 & 0.20 & 0.91 & 0.4\\
\bottomrule
\end{tabular}
\end{table}


Sebbene l'accuratezza risulti buona, essa, come già detto, è inaffidabile in un caso come questo, dove la distribuzione delle classi da predire risulta "sbilanciata". L'elevato valore di specificità comune a tutti i modelli addestrati significa che essi si dimostrano buoni classificatori per quanto riguarda l'identificazione della classe "negativa". Tuttavia, come intuibile dai bassi valori di sensitività, essi non risultano essere in grado di discriminare la classe di interesse. Ciò è dovuto molto probabilmente al numero eccessivamente basso di osservazioni a disposizione per l'addestramento dei modelli.

Di per sé , infatti, lo sbilanciamento delle classi è un problema facilmente aggirabile tramite diversi approcci come ad esempio specificando al pacchetto caret di utilizzare un metodo di resampling che tenga conto del forte sbilanciamento di classi (downsampling). In questo modo, ad esempio, ad ogni iterazione vengono selezionate un pari numero di osservazioni positive e negative (utilizzando tutte quelle positive a disposizione), annullando quindi lo sbilanciamento.

In questo lavoro, tuttavia, accorgimenti di questo tipo non hanno migliorato in modo sufficiente le performance di classificazione, ottenendo comunque sensitività e precisione molto basse. Performance migliori possono essere ottenute aumentando il numero di dati a disposizione prelevando da altre macchine simili i file di backup. Elemento essenziale per poter meglio sviluppare questi modelli sarà, comunque, la presenza di dati relativi agli interventi manutentivi effettuati senza i quali, infatti, non si avrebbe la possibilità di etichettare i dati a disposizione, invalidando quindi il concetto di apprendimento supervisionato.

Il lavoro svolto è comunque un buon punto di partenza per eventuali sviluppi futuri, in quanto l'aggiunta di ulteriori dati non implicherebbe la modifica di tutte le fasi elencate precedentemente, ma semplicemente un maggiore tempo di elaborazione per l'addestramento dei modelli, in misura proporzionale alla quantità di nuove osservazioni.
