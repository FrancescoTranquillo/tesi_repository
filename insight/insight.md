# INSIGHT: IoT al servizio del reparto di endoscopia \label{insight}

In questo capitolo viene descritto in che modo si è arrivati alla decisione di sviluppare una web app (chiamata INSIGHT) per il reparto di endoscopia. Vengono prima indicate le problematiche relative alla riprocessazione della strumentazione endoscopica e, per ognuna di esse, verrà descritto in che modo la web app sviluppata può essere d'aiuto nella razionalizzazione e nella successiva risoluzione delle stesse. Verrà inoltre trattata la strategia utilizzata per effettuare il _software deployment_ che ha reso disponibile l'applicazione sulla rete interna dell'ospedale, grazie al contributo dell'U.O.C. Sistemi Informativi Aziendali. Infine si evidenzieranno sia le criticità incontrate durante lo sviluppo del software, sia il riscontro all'utilizzo dell'app da parte del personale del reparto.


# Sviluppo di Insight

Parallelamente alla fase di modellizzazione vista nel capitolo precedente, si è pensato a come poter utilizzare in modo pratico gli algoritmi di analisi degli scontrini e i modelli di predizione, in modo da renderli degli strumenti effettivamente a disposizione del reparto di endoscopia. 

Sì riporta qui di seguito lo schema di funzionamento che si è pensato per l'implementazione della strategia di manutenzione predittiva, di cui viene descritto ogni componente.

![schema per applicazione di manutenzione predittiva \label{schemapred}](insight/schemapredittiva.pdf)



Per continuità con le metodiche utilizzate in precedenza, si è scelto di sviluppare una applicazione


permette il caricamento dei print-out in formato .txt al fine di analizzarli. Cliccando su "Browse", verrà aperta una schermata in cui verrà chiesto all'utente di selezionare i file da caricare. I file possono essere caricati su INSIGHT tramite semplice drag and drop nello spazio apposito di fianco alla scritta "Browse".

INSIGHT permette il caricamento multiplo di print-out. Si consiglia di caricare tutti i file che si vogliono analizzare in una volta sola. Per facilitare la selezione di file multipli si ricorda che è possibile selezionare diversi file contemporaneamente cliccando tra il primo e l'ultimo file desiderato tenendo premuto il tasto SHIFT.

Date-picker

Una volta terminata la fase di caricamento degli scontrini, comparirà un selezionatore di date in cui verrà richiesto all'utente di selezionare i giorni da analizzare. L'utente può selezionare una singola data, oppure un intervallo di date.

L'utente viene guidato in fase di selezione delle date, in quanto le uniche date selezionabili saranno quelle definite da un tratto più scuro (vedi figura in basso) mentre le altre date, meno marcate, non potranno essere selezionate nemmeno se l'utente ci cliccherà sopra.

￼

Date-picker. In evidenza l'intervallo di date selezionabili (dall'8 all'11 marzo 2019)

Analisi

Elemento contenente diversi sotto-elementi:

Selezionatore di macchina

Overview

Allarmi

Strumentazione

Operatori

Selezionatore di macchina

Menù a tendina in cui l'utente è tenuto a selezionare uno o più numeri seriali corrispondenti alle lavaendoscopi che si vogliono analizzare. 

Il menù ha un'influenza globale sul funzionamento di INSIGHT : le viste successive mostreranno, in modo dinamico, informazioni relative all'insieme di numeri seriali selezionati.

￼

Selezionatore di macchina. In questo caso l'utente ha selezionato tutte le macchine tranne la 6-0538

Body

Overview

Vista primaria che contiene diverse informazioni sugli scontrini analizzati. I primi 4 pannelli orizzontali mostreranno un tooltip che suggerirà all'utente il contenuto del pannello, se cliccato.

￼

Allarmi

In questa sezione sono disponibili informazioni relative agli allarmi rilevati negli scontrini caricati. 

La pagina si divide in una sezione superiore e una inferiore. 

In quella superiore (in figura sottostante) è presente un grafico a barre orizzontali in cui viene presentato il numero di allarmi rilevati in ognuna delle macchine selezionate nel selezionatore di macchina, per ognuna delle categorie di strumentazione presenti negli scontrini analizzati. Il colore delle barre rappresenta invece la tipologia di allarme rilevato.

￼

In questo caso le macchine selezionate sono 2. Gli scontrini relativi a queste due lavaendoscopi hanno registrato in totale 4 allarmi di tipo "Allarme canale 2 otturato" e 1 allarme di tipo "Allarme canale 1 scollegato". La macchina 6-0539 ha registrato tre allarmi della prima tipologia mentre la macchina 6-0540 ne ha rilevati due di ogni tipo, sempre in riferimento alla categoria di strumentazione "Gastroscope" 

Tutti i grafici di INSIGHT sono interattivi. Per avere più informazioni su una parte di un grafico l'utente può semplicemente passare il cursore sopra la parte interessata. Così facendo, comparirà un tooltip informativo di supporto.

La parte inferiore contiene, a sinistra, una finestra con 3 menù a tendina da compilare per generare il diagramma di flusso, il quale comparirà alla destra dei menù di controllo.

￼

Sezione inferiore della pagina "Allarmi"

In questa sezione è possibile visualizzare in che modo gli allarmi rilevati si distribuiscono tra le macchine selezionate e tra la strumentazione utilizzata, specificando modello e numero seriale. Nel caso in figura, ad esempio, sono stati selezionate due categorie di strumento nel primo menù (Gastroscope e Ultrasound Gastroscope). Successivamente, nel menù secondario sono stati selezionati tutti i modelli disponibili per queste categorie. Infine, nell'ultimo menù sono stati selezionati tutti gli allarmi rilevati per queste categorie di strumenti. 

Il diagramma di flusso risultante rappresenta in modo chiaro quali e quanti allarmi hanno generato gli strumenti selezionati, nelle macchine scelte.

Si ricorda che all'utente basta spostare il cursore sopra uno dei flussi del diagramma per visualizzare le quantità in gioco.

Strumentazione

In questa pagina si trovano due elementi. Il primo è un grafico a barre verticali che permette di confrontare il numero di cicli regolari e irregolari ottenuto da ogni macchina, in relazione alla categoria di strumentazione.

￼

La seconda parte permette di selezionare una categoria di strumento e visualizzare una tabella con il riassunto dei cicli per la categoria di strumentazione scelta.

￼

Sezione inferiore della pagina Strumentazione.

In questo caso si è scelta la categoria "Colonscope". Tre pannelli laterali indicano, rispettivamente, il numero di cicli regolari, irregolari e numero di allarmi relativamente alle lavaendoscopi precedentemente selezionate. Nello spazio sottostante è possibile selezionare la vista relativa ai soli cicli regolari, oppure quella relativa ai soli cicli irregolari. 

Ogni tabella generata da INSIGHT è dotata di un set di pulsanti che permettono l'esportazione della stessa in diversi formati.

Operatori

In questa sezione il focus è spostato sugli operatori. La pagina presenta dei controlli a sinistra e una tab da cui è possibile visualizzare due grafici a barre verticali.

￼

Vista operatore

I controlli sono costituiti da:

Un menù a tendina in cui l'utente è tenuto a selezionare uno o più operatori da una lista. 

Due pulsanti che permettono all'utente di visualizzare il conteggio dei cicli per la tipologia di ciclo scelta. 

La tab a destra è divisa in due sezioni (selezionabili tramite i nomi a in alto a sinistra rispetto alla scritta "Numero di cicli per operatore". Nella prima vista è possibile visualizzare quanti cicli regolari (o irregolari) un operatore ha ottenuto per ogni macchina selezionata nella sidebar. Nella seconda, invece, viene visualizzato un grafico a barre con il conteggio totale dei cicli regolari (o irregolari).

