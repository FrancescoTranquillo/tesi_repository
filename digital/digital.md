# Industria 4.0: tra manutenzione predittiva e tecnologie digitali

In questo capitolo verrà data, dopo una breve introduzione storica, la definizione di "industria 4.0" e di "manutenzione predittiva". Verranno inoltre riportati i vantaggi nell'utilizzo delle tecnologie digitali a scopo predittivo nell'ottica della manutenzione e verranno descritti i principi teorici dell'analisi predittiva, specificando le principali tecniche di analisi e modelli di machine learning utilizzati attualmente.

## Industria 4.0 e tecnologie emergenti
La storia della manutenzione predittiva è intrinsecamente legata a quella della quarta rivoluzione industriale la quale, a sua volta, si configura come uno sviluppo della terza rivoluzione industriale, definita come rivoluzione digitale. Quest'ultima, iniziata negli anni 80 del secolo scorso, è caratterizzata dalle innovazioni tecnologiche che hanno permesso il "salto tecnologico" dalle tecnologie analogiche e dei dispositivi meccanici alle attuali tecnologie digitali, come ad esempio il pc (personal computer), internet e in generale la branca degli argomenti di interesse della ICT (information and communications technology). In questo contesto, la quarta rivoluzione industriale nasce proprio da queste innovazioni tecnologiche ed è caratterizzata dall'evoluzione di tecnologie emergenti il cui impatto sulla società e sulla qualità della vita non ha eguali in tutta la storia umana. Tra le tecnologie emergenti rientrano la robotica, la nanotecnologia, i computer quantistici, la medicina rigenerativa, l'Industrial Internet of Things, la domotica e l'intelligenza artificiale applicata in svariati campi (per esempio automazione industriale, diagnostica per immagini, buisness intelligence e analisi di big data).

Con questa premessa, si intuisce come la manutenzione predittiva sia diretta conseguenza di un' applicazione sinergica delle sopracitate tecnologie. Essa si appropria infatti di metodiche caratteristiche di diversi campi al fine di determinare lo stato di salute di una tecnologia per prevedere l'istante temporale ottimale in cui condurre le operazioni di manutenzione e quindi il tempo residuo prima di un guasto.

Tra queste metodiche rientra ad esempio l'utilizzo di tecnologie IoT: infatti la valutazione dello stato di salute di un ipotetico parco macchine viene effettuata tramite l'utilizzo di una rete di sensori in grado di comunicare l'andamento nel tempo di alcune variabili di interesse (monitoraggio online). Oppure ancora, come il nome stesso suggerisce, la componente "predittiva" è affidata a più o meno sofisticati, a seconda del contesto, algoritmi di artificial intelligence basati a loro volta sull'applicazione di tecniche di machine learning in grado, in questo caso, di analizzare e predire l'evoluzione di serie temporali sia in modo semi-automatico (apprendimento supervisionato) sia in modo totalmente automatico (apprendimento non supervisionato).

## Manutenzione predittiva: il contesto normativo
Dal punto di vista normativo, la definizione di manutenzione predittiva viene delineata, a livello europeo, nella EN 13306 dove, nella versione attualmente in vigore (EN 13306:2017) essa viene definita come:

_"Condition based maintenance carried out following a forecast derived from repeated analysis or known characteristics and evaluation of the significant parameters of the degradation of the item"[@schmidtNEXTGENERATIONCONDITION]._

La stessa viene recepita in Italia con la UNI EN 13306:2018, secondo la quale per "manutenzione predittiva" si intende:

_"Manutenzione su condizione eseguita in seguito a una previsione derivata dall’analisi ripetuta o da caratteristiche note e dalla valutazione dei parametri significativi afferenti il degrado dell’entità"[@maccarelliManutenzioneTutteDefinizioni]._

Dove, sempre secondo la stessa norma, la manutenzione su condizione è definita come:

_"Manutenzione preventiva che comprende la valutazione delle condizioni fisiche, l’analisi e le possibili azioni di manutenzione conseguenti"._

La "valutazione", sempre secondo la sopracitata norma, può avvenire mediante diverse modalità tra le quali:

- Osservazione dell'operatore
- Ispezione
- Collaudo
- Monitoraggio delle condizioni dei parametri del sistema

Tutte queste modalità vengono intese come "svolte secondo un programma, su richiesta o in continuo".

Riassumendo, quindi, la manutenzione predittiva si configura come un caso "avanzato" di manutenzione preventiva, che mira alla minimizzazione dei tempi di fermo macchina grazie all'applicazione di analisi predittive, con lo scopo di predire, con una certa accuratezza, il tempo rimanente prima di un successivo "guasto" della macchina in esame.

## Vantaggi della manutenzione predittiva
I vantaggi di questa strategia di manutenzione possono essere sintetizzati in quattro punti fondamentali:

1. **Riduzione del tempo di fermo macchina**: Sicuramente il più concreto dei vantaggi della manutenzione predittiva. Abbattendo le probabilità di guasto di un macchinario, si riducono ovviamente i tempi di fermo macchina. I vantaggi di questo risultato sono immediatamente chiari: da una parte si risparmia in tempo e denaro, dall'altra si ha la sicurezza di erogare un servizio in modo continuativo, riducendo quindi la _customer dissatisfaction_, che in sanità è legata alla qualità della cura clinica ricevuta, disponibilità dei servizi e tempi di attesa. La gravità di un fermo macchina è ben intuibile se si considera la quantità di esami che vengono effettuati per mezzo di quella famiglia di macchinari "ad alta incidenza" come TAC, risonanze ed in generale tutti i dispositivi di diagnostica per immagini. In figura \ref{mole} sono rappresentati le 15 prestazioni ambulatoriali con il maggior numero di erogazioni in un anno nella ASST di Vimercate in riferimento alle tecnologie sopracitate.

![Numero di prestazioni ambulatoriali in ASST Vimercate per tipologia di esame. \label{mole}](digital/img/mole_lavoro.png)

I dati utilizzati per questa rappresentazione sono stati estratti dal portale di Regione Lombardia adibito alla pubblicazione e consultazione di open data [@PrestazioniAmbulatorialiOpen]. Appare ben chiaro che i fermo macchina relativi ad apparecchiature di questo tipo, che svolgono mediamente più di dieci mila esami all'anno (si parla quindi di circa trenta esami al giorno), siano delle criticità notevoli ed è facile immaginare la difficoltà con cui un reparto debba provvedere alla riorganizzazione dei crono-programmi in seguito ad un fermo macchina. Obiettivo della manutenzione predittiva è proprio quello di minimizzare queste criticità e, conseguentemente, di ottimizzare la gestione delle tecnologie.

2. **Ottimizzazione delle risorse**: In termini di componenti di un macchinario, tramite applicazioni di manutenzione predittiva è possibile eseguire delle operazioni di sostituzione di componenti prima che questi si degradino oltre un certo stato, andando quindi ad allungare la vita utile dell'apparecchiatura di cui essi fanno parte.

3. **Controllo**: La raccolta di dati utili all'implementazione di un programma di manutenzione predittiva è un passaggio cruciale per l'ottenimento di un completo controllo del processo che si vuole monitorare. L'obiettivo è quindi quello di conoscere, in ogni momento, lo stato di funzionamento di un macchinario al fine di pianificare e gestire in anticipo situazioni critiche di infungibilità. In particolare, si fa riferimento a tre tipologie di dati:
  - Dati ambientali come temperatura, umidità, frequenza delle vibrazioni, ecc.
  - Dati storici come informazioni sui guasti passati e operazioni di manutenzione svolte.
  - Dati operativi come, ad esempio, informazioni circa l'effettivo utilizzo della macchina

4. **Sviluppo continuo e cultura "Data-driven"**: l'instaurazione di una strategia di manutenzione predittiva rappresenta, per il settore industriale, un vantaggio competitivo in quanto permette di sfruttare la raccolta dei dati, grazie a tecnologie di IoT, per la costruzione di una strategia a lungo termine improntata sull'abbattimento dei costi e l'ottimale utilizzo delle risorse disponibili. Ritroviamo questi importanti obiettivi anche nel settore Sanitario dove, a fronte di esigenze sanitarie sempre crescenti (dovute al progressivo invecchiamento della popolazione e al conseguente aumento dei malati cronici) è richiesta una continua evoluzione dei sistemi di cura tale da contenere le spese e rispondere a questi bisogni sanitari ottimizzando l'uso dei mezzi a disposizione. Integrando servizi di manutenzione predittiva, inoltre, si abbracciano quei cambiamenti organizzattivi propri della _"Data-driven culture"_, ovvero di tutto l'insieme di approcci, obiettivi, strumenti e _skills_ che orbitano intorno al concetto dell'utilizzo ottimale dei dati. Uno degli aspetti chiave di questa modalità di pensiero è proprio l'analisi dei dati generati da, ormai, qualsiasi macchinario, al fine di aumentare la conoscenza di un determinato processo e, in ultima analisi, ottenere su di esso un controllo completo.

Riassumendo quindi: la trasformazione digitale che sta interessando tutti i settori umani (compreso quello sanitario), ovvero la possibilità di raccogliere e conservare diversi tipi di dati in tempo reale, permette di conoscere meglio i problemi di un macchinario e di evitarne i fermo macchina andando così a migliorare sia, in ambito sanitario, la qualità del servizio offerto dalla macchina in questione sia la gestione della stessa.

## Metodi analitici di predizione
Nei paragrafi precedenti sono stati introdotti obiettivi e vantaggi della manutenzione predittiva. Nel senguente verranno invece descritti i metodi di machine learning sui quali essa si fonda.

Definiamo "Machine Learning" come lo studio o lo sviluppo di modelli e algoritmi che permettono ad un sistema (o un programma) di imparare dall'esperienza per aumentare le proprie performance durante l'esecuzione. Un sistema "impara" dall'esperienza E in riferimento a qualche tipo di task T e ad una misura di performance P, se le sue performance nell'eseguire il task T, come misurate da P, aumentano grazie all'esperienza. La fase di addestramento di un modello viene indicata come fase di _training_. Sistemi di questo tipo vengono chiamati "Modelli Adattativi". Un modello è tipicamente una funzione _f_ che riceve uno o più input (chiamati anche _features_, _variabili indipendenti_, _osservazioni_ o _esempi_) e genera uno o più output (chiamati anche _classi_ o _variabili dipendenti_). La definizione di questa funzione viene determinata, nell'approccio proprio del Machine Learning, attraverso un approccio "bottom-up". In questo caso, il sistema osserva un insieme di esempi e costruisce un modello basato su questi dati.


A seconda della tipologia di dati usati, si possono identificare tre paradigmi di training:

1. **Addestramento supervisionato** < x~i~, t~i~ >: per ogni input x~i~, dato l'output desiderato t~i~, al modello è richiesto di imparare a produrre l'output corretto y dato un input x (mai osservato dal modello in precedenza). Quest'ultimo aspetto determina la capacità di un modello di generalizzare, ovvero produrre output corretti a fronte di input mai incontrati. Tramite questo tipo di addestramento si cerca di risolvere due tipi di problemi:
    - **Classificazione**: Il programma è addestrato per classificare un oggetto in alcune classi (note). Un classico esempio è il problema di identificare quando una mail è classificabile come spam oppure no. Oppure, in ambito sanitario, recenti sono le applicazioni in cui vengono utilizzati algoritmi di machine learning per l'identificazione e la classificazione di una certa patologia in diverse situazioni[@manakLivecellPhenotypicbiomarkerMicrofluidic2018; @wangDevelopmentValidationDeeplearning2018].
    - **Regressione**: Il programma è addestrato per predire un valore numerico e quindi predire l'andamento di una determinata serie numerica. Esempi applicativi di questo tipo possono essere ritrovati in numerosissimi ambiti. Si riportano qui di seguito solo alcuni esempi di applicazioni di machine learning utilizzati in ambito finanziaro [@StockPerformanceModeling], astronomico [@nagemDeepLearningTechnology2018], turistico [@sunForecastingTouristArrivals2017] e sanitario [@levantesiApplicationMachineLearning2019].

2. **Addestramento non supervisionato** < x~i~ >: al modello è richiesto di identificare regolarità tra i dati a disposizione per costruire una rappresetazione utilizzabile per condurre analisi e predizioni. Attraverso l'addestramento non supervisionato si possono affrontare problemi di:
    - **Detezione di anomalie**: Il programma analizza i dati a disposizione e impara autonomamente ad identificare pattern anomali.
    - **Clustering**: Il programma identifica gruppi di esempi con caratteristiche simili

3.**Addestramento rinforzato** < x~i~ >, {a~1~, a~2~, ...}, $r_{i} \in R$: Al modello viene richiesto di imparare a produrre azioni a~1~, a~2~ in modo tale da massimizzare le ricompense ricevute r~i~.

Relativamente alla manutenzione predittiva, le applicazioni per cui essa viene applicata rientrano nelle categorie di problemi di Classificazione, di Regressione e di Detezione di anomalie. Nello specifico, a questi problemi può essere associata una domanda che esplicita l'obiettivo che si vuole ottenere tramite la manutenzione predittiva. Le tre domande (d'ora in avanti indicate con il nome di "Use Case") sono:

1. **Classificazione**: _"La macchina subirà un guasto?"_
2. **Regressione**:_"Tra quanto tempo la macchina subirà un guasto?"_
3. **Detezione di anomalie**:_"Il comportamento della macchina è anomalo?"_

Nei successivi paragrafi si espliciterà ognuno dei seguenti problemi, fornendo alcuni esempi di algoritmi utilizzabili in ognuno dei sopracitati casi.

### Classificazione: _"La macchina subirà un guasto?"_
In questo tipo di problema, come già visto, l'obiettivo è quello di fornire una classificazione per un determinato oggetto. L'"oggetto" in questione si configura come l'eventualità o meno della macchina di subire un guasto, a fronte di una serie di informazioni relative allo stato operativo della macchina stessa. A titolo di esempio, si rimanda al lavoro svolto da Battifarano et al. dal titolo "Predicting Future Machine Failure from Machine State Using Logistic Regression" [@battifaranoPredictingFutureMachine2018] nel quale, a partire da informazioni riguardanti lo stato operativo della macchina in un dato istante temporale, si è addestrato un modello di regressione logistica per predire lo stato di funzionamento del macchinario con 24 ore di anticipo.

La regressione logisitca è un metodo di classificazione comunemente utilizzato in applicazioni simili. Esso modellizza la probabilità di una variabile binaria target **Y** a partire da un vettore di features **X** trasportando una combinazione lineare delle features nell'intervallo (0,1) tramite una trasformazione non lineare data dalla \ref{eq:logreg}:

\begin{equation}
P(Y = 1 \mid X = x) = \pi(x) = \frac{e^{\alpha + \beta^{T}x}}{1+e^{\alpha + \beta^{T}x}}
\label{eq:logreg}
\end{equation}
