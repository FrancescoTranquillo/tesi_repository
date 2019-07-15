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

## Metodi analitici di predizione \label{digital}
Nei paragrafi precedenti sono stati introdotti obiettivi e vantaggi della manutenzione predittiva. Nel seguente verranno invece descritti i metodi di machine learning sui quali essa si fonda.

Definiamo "Machine Learning" come lo studio o lo sviluppo di modelli e algoritmi che permettono ad un sistema (o un programma) di imparare dall'esperienza per aumentare le proprie performance durante l'esecuzione. Un sistema "impara" dall'esperienza E in riferimento a qualche tipo di task T e ad una misura di performance P, se le sue performance nell'eseguire il task T, come misurate da P, aumentano grazie all'esperienza. La fase di addestramento di un modello viene indicata come fase di _training_. Sistemi di questo tipo vengono chiamati "Modelli Adattativi".

Un modello è tipicamente una funzione "obiettivo" t~n~ (funzione "target") che riceve uno o più (_n_) input (chiamati anche _features_, _variabili indipendenti_, _osservazioni_ o _esempi_) e genera uno o più output (chiamati anche _classi_ o _variabili dipendenti_). La definizione di questa funzione viene determinata, nell'approccio proprio del Machine Learning, attraverso un approccio "bottom-up" nel quale il sistema osserva un insieme di esempi e costruisce un modello basato su questi.


A seconda della tipologia di dati usati, si possono identificare tre paradigmi di training:

1. **Addestramento supervisionato** < x~i~, t~i~ >: per ogni input x~i~, dato l'output desiderato t~i~, al modello è richiesto di imparare a produrre l'output corretto y dato un input x (mai osservato dal modello in precedenza). Quest'ultimo aspetto determina la capacità di un modello di generalizzare, ovvero produrre output corretti a fronte di input mai incontrati. Tramite questo tipo di addestramento si cerca di risolvere due tipi di problemi:
    - **Classificazione**: Il programma è addestrato per classificare un oggetto in alcune classi (note). Un classico esempio è il problema di identificare quando una mail è classificabile come spam oppure no. Oppure, in ambito sanitario, recenti sono le applicazioni in cui vengono utilizzati algoritmi di machine learning per l'identificazione e la classificazione di una certa patologia in diverse situazioni[@manakLivecellPhenotypicbiomarkerMicrofluidic2018; @wangDevelopmentValidationDeeplearning2018].
    - **Regressione**: Il programma è addestrato per predire un valore numerico e quindi predire l'andamento di una determinata serie numerica. Esempi applicativi di questo tipo possono essere ritrovati in numerosissimi ambiti. Si riportano qui di seguito solo alcuni esempi di applicazioni di machine learning utilizzati in ambito finanziaro [@StockPerformanceModeling], astronomico [@nagemDeepLearningTechnology2018], turistico [@sunForecastingTouristArrivals2017] e sanitario [@levantesiApplicationMachineLearning2019].

2. **Addestramento non supervisionato** < x~i~ >: al modello è richiesto di identificare regolarità tra i dati a disposizione per costruire una rappresetazione utilizzabile per condurre analisi e predizioni. Attraverso l'addestramento non supervisionato si possono affrontare problemi di:
    - **Detezione di anomalie**: Il programma analizza i dati a disposizione e impara autonomamente ad identificare pattern anomali.
    - **Clustering**: Il programma identifica gruppi di esempi con caratteristiche simili

3. **Addestramento rinforzato** < x~i~ >, {a~1~, a~2~, ...}, $r_{i} \in R$: Al modello viene richiesto di imparare a produrre azioni a~1~, a~2~ in modo tale da massimizzare le ricompense ricevute r~i~.

Relativamente alla manutenzione predittiva, le applicazioni per cui essa viene applicata rientrano nelle categorie di problemi di Classificazione, di Regressione e di Detezione di anomalie. Nello specifico, a questi problemi può essere associata una domanda che esplicita l'obiettivo che si vuole ottenere tramite la manutenzione predittiva. Le tre domande (d'ora in avanti indicate con il nome di "Use Case") sono:

1. **Classificazione**: _"La macchina subirà un guasto?"_
2. **Regressione**:_"Tra quanto tempo la macchina subirà un guasto?"_
3. **Detezione di anomalie**:_"Il comportamento della macchina è anomalo?"_

Nei successivi paragrafi si espliciterà ognuno dei seguenti problemi, fornendo alcuni esempi di algoritmi utilizzabili in ognuno dei sopracitati casi.

### Classificazione
In questo tipo di problema, come già visto, l'obiettivo è quello di fornire una classificazione per un determinato oggetto. L'"oggetto" in questione si configura come l'eventualità o meno della macchina di subire un guasto, a fronte di una serie di informazioni relative allo stato operativo della macchina stessa. A titolo di esempio, si rimanda al lavoro svolto da Battifarano et al. dal titolo "Predicting Future Machine Failure from Machine State Using Logistic Regression" [@battifaranoPredictingFutureMachine2018] nel quale, a partire da informazioni riguardanti lo stato operativo della macchina in un dato istante temporale, si è addestrato un modello di regressione logistica per predire lo stato di funzionamento del macchinario con 24 ore di anticipo.

La regressione logistica è un metodo di classificazione comunemente utilizzato in applicazioni simili. Esso modellizza la probabilità di una variabile binaria target **Y** (che nel caso sopracitato rappresenta lo stato di "salute" della macchina differenziandolo in "funzionante" e "non funzionante" ) a partire da un vettore di features **X** (le informazioni sullo stato operativo del macchinario) trasportando una combinazione lineare delle features nell'intervallo (0,1) tramite una trasformazione non lineare data dalla \ref{eq:logreg}:

\begin{equation}
P(Y = 1 \mid X = x) = \pi(x) = \frac{e^{\alpha + \beta^{T}x}}{1+e^{\alpha + \beta^{T}x}}
\label{eq:logreg}
\end{equation}

L'addestramento del modello, in questo caso, consiste nell'identificazione del migliore set di parametri $\alpha$ e $\beta$, ovvero i valori che aumentano la precisione del modello. Più nel dettaglio, la stima dei coefficienti di regressione della \autoref{eq:logreg} si realizza tramite la risoluzione di un problema di massimizzazione di una specifica funzione, chiamata "verosomiglianza" _L_ (chiamata anche funzione di _likelyhood_ in inglese). Questa funzione esprime la probabilità condizionata che un insieme di esempi ($t_{1},...,t_{N}$), ovvero i dati utilizzati per l'addestramento del modello, vengano determinati da uno specifico set di parametri $\theta$ (in questo caso i parametri sono $\alpha$ e $\beta$ citati precedentemente).

Prima di inoltrarci nella risoluzione matematica del problema, è importante sottolineare che questo approccio è chiamato frequentista, cioè che fa affidamento esclusivamente sull'esperienza. Una diversa strategia è data, come si vedrà, dall'approccio bayesiano nel quale, per la determinazione dei coefficienti del modello, si utilizza come informazione (mancante nell'approccio frequentista) anche una conoscenza a priori della possibile distribuzione dei parametri ricercati e l'esperienza viene utilizzata di volta in volta per correggere questa conoscenza a priori in modo da allinearsi con le evidenze generate dall'esperienza.

Definiamo quindi il problema di massimizzazione della funzione di likelyhood (chiamato _MLE_ ovvero **Maximum Likelyhood Estimation**) relativamente ad un problema di classificazione. La funzione obiettivo $t_{n}$, nel caso di un problema di classificazione binaria, è una funzione tale che:
<center>
\begin{align}
\begin{split}
t_{n} \in \{0,1\} ,
\\
t_{n} \sim {\sf Be}(y_{n})
\end{split}
\end{align}

dalla quale si deduce, per definizione di distribuzione di Bernoulli:

\begin{equation}
p(t_{n} \mid x) = y_{n}^{t_{n}}(1-y_{n})^{1-t_{n}}
\end{equation}

che, a sua volta, permette di definire la funzione di likelyhood:
\begin{equation}
\label{eq:L}
L(\theta) = p(t_{1},...,t_{N} \mid \theta) = \prod_{n}p(t_{n}\mid\theta) = \prod_{n=1}^{N}y_{n}^{t_{n}}(1-y_{n})^{1-t_{n}}
\end{equation}

nella quale:

- _N_ rappresenta il numero di osservazioni disponibili
- $y_{n}$ è la funzione sigmoide relativa al'equazione \ref{eq:logreg}, che può essere riscritta, raccogliendo l'esponenziale al denominatore e sostituendo l'argomento dell'esponenziale, come:
\begin{align}
\begin{split}
a_{n} = \alpha + \beta^{T}x,
\\
y_{n} = \frac{1}{1+e^{-a_{n}}}
\end{split}
\end{align}

Di conseguenza, per risolvere il problema di MLE (un problema di massimizzazione) bisogna derivare la funzione di likelyhood \ref{eq:L} rispetto ai parametri e annullarne la derivata così trovata. In riferimento a ciò, si procede applicando prima il logaritmo alla \ref{eq:L} ottenendo:
\begin{equation}
\L(a_{n}) = \log(L(\theta)) = \sum_{n = 1}^{N}t_{n}\log(y_{n})+(1-t_{n})\log(1-y_{n})
\end{equation}
La forma così ottenuta è chiamata log likelyhood. Il problema di massimizzazione di quest'ultima corrisponde al suo duale, ovvero alla minimizzazione della log likelyhood negativa:

\begin{align}
\begin{split}
\label{eq:crossentropy}
{\sf argmax}_{a_{n}}\L(a_{n}) &= {\sf argmin}_{a_{n}}-\L(a_{n}) \\
&={\sf argmin}_{a_{n}}-\left(\sum_{n = 1}^{N}t_{n}\log(y_{n})+(1-t_{n})\log(1-y_{n})\right)
\end{split}
\end{align}

L'ultima espressione è chiamata **cross entropia**. In statistica, la minimizzazione della cross entropia corrisponde alla minimizzazione della divergenza di Kullback-Leibler tra la distribuzione ottenuta e quella target [@kullbackInformationSufficiency1951] che, in sintesi, rappresenta una misura di quanto due distribuzioni di probabilità siano simili.

La risoluzione della \ref{eq:crossentropy} risulta complicata dal punto di vista analitico. Si procede quindi attraverso l'utilizzo di metodi numerici come ad esempio il metodo chiamato "discesa del gradiente". Con questo metodo, si cerca di minimizzare una funzione di costo in modo iterativo a partire da una soluzione iniziale scelta in modo casuale. Man mano che si procede con le iterazioni _k~n~_, i parametri (indicati nelle prossime equazioni con _w_) ricercati vengono aggiornati secondo la seguente formula di aggiornamento:
\begin{equation}
\label{eq:update}
w^{k+1}=w^{k}-\eta\left.\pdv{J}{w}\right|_ {k}
\end{equation}

dove il secondo termine rappresenta il prodotto tra $\eta$, chiamato _learning rate_, e la derivata di una funzione di costo _J_ rispetto ai parametri di interesse, che rappresenta il gradiente della funzione di costo. Nel caso di un problema di classificazione, la funzione di costo è la cross entropia dell'equazione \ref{eq:crossentropy}. Numericamente, il metodo della discesa del gradiente avviene in questi passaggi:

1. Viene inizializzata una possibile soluzione $w^{0}$ in modo casuale
2. Si calcola il gradiente della funzione di costo $\left.\pdv{J}{w}\right|_ {k}$
3. Si aggiorna la soluzione tramite l'equazione di aggiornamento data dall'equazione \ref{eq:update}
4. Si ripetono i passaggi 2 e 3 fino alla convergenza.

Tuttavia, il metodo del gradiente presenta delle criticità date dalla forma della funzione di costo e per la risoluzione si rimanda a testi specialistici.

Attualmente, questi metodi di ottimizzazione e di addestramento di modelli predittivi sono implementati in pacchetti e funzionalità di diversi linguaggi di programmazione (Python, R, Matlab) che spesso vengono utilizzati per la costruzione iniziale di questo tipo di applicazioni. Sta quindi all'utilizzatore selezionare il modello più appropriato per il caso in esame.

### Regressione
In un problema di regressione, gli output desiderati $t_{i}$ sono valori continui e l'obiettivo è di predire in modo accurato un nuovo output a partire da nuovi input. Diversamente da quanto accade in un problema di classificazione, quindi, in un problema di regressione si cerca di predire un valore numerico. Un esempio applicativo di manutenzione predittiva svolta tramite risoluzione di un problema di regressione è dato dal lavoro di Tian et al. [@tianArtificialNeuralNetwork2012] nel quale viene utilizzata una rete neurale di tipo feedforward per la stima della vita utile rimanente (in inglese _RUL_, Remaining Useful Life) di alcuni componenti di un macchinario rotante tramite l'analisi delle vibrazioni assorbite dai cuscinetti del macchinario. Le reti neurali sono una tipologia di modello non-lineare caratterizzate da:

- numero di neuroni
- tipologia della rete
- funzione di attivazione
- valori dei pesi sinaptici e dei _bias_

Ritroviamo questi elementi nell'unità funzionale di una rete neurale, ovvero una rete neurale dotata di un singolo neurone, con diversi input e un unico output, chiamata perceptrone. In generale, un neurone artificiale è modellizzato come in figura \ref{an} e il suo output dipende dal valore assunto dalla funzione di attivazione, indicata da $g()$.

![Modello di neurone artificiale.\label{an}](digital/img/an.pdf)

Ispirandosi proprio al neurone biologico e alla sua proprietà di generare un potenziale d'azione secondo la logica del "tutto o nulla", un neurone artificiale è in grado di replicare l'effetto di sommazione temporale dei potenziali d'azione e l'effetto di "sparo" grazie la definizione di una soglia di attivazione o bias _b_. L'output di un perceptrone è quindi dato da:
\begin{equation}
y=g\left(\sum_{0}^{I}w_{i}x_{i}\right)
\end{equation}
a sua volta, la funzione di attivazione può essere di diversi tipi (gradino, segno, lineare, sigmoide, iperbolica).

L'addestramento di un perceptrone è descritto dal seguente set di equazioni che prende il nome di **Apprendimento Hebbiano**, formulato nel 1949 dallo psicologo canadese Donald Olding Hebb che studiò il meccanismo di apprendimento delle cellule neuronali:
\begin{align}
\begin{split}
\label{eq:hebb}
{w}_{i}^{k+1} &= {w}_{i}^{k} + \Delta w_{i} \\
\Delta w_{i} &= \eta t x_{i}
\end{split}
\end{align}

dove:

- $\eta$ è il learning rate simile a quello dell'equazione \ref{eq:update}
- $x_{i}$ è l'i-esimo input del perceptrone
- t è l'output desiderato

I passaggi dell'apprendimento Hebbiano possono essere sintetizzati nel seguente modo:

1. I pesi vengono inizializzati in modo casuale
2. Si calcola l'output del perceptrone utilizzando i pesi così inizializzati
    2. Se l'output è diverso dall'output desiderato, si applica la regola di aggiornamento data dalla \ref{eq:hebb} ottenendo un nuovo set di pesi.
3. Si ripete il passaggio 2 fino ad ottenere il risultato corretto.

Tramite questo semplice metodo, un perceptrone è capace di apprendere semplici operazioni logiche quali AND, NOT, OR. Tuttavia, il perceptrone non è in grado di risolvere tutte le operazioni logiche. Infatti mostra limitazioni nell'apprendimento dell'operazione logica XOR. Per ovviare a questo problema, si combinano più neuroni artificiali generando nuovi modelli chiamati Perceptroni Multistrato o, più comunemente, reti neurali feedforward.

![Topologia di rete neurale feedforward.\label{ffnn}](digital/img/ffnn.pdf)

Nelle reti neurali feedforward (figura \ref{ffnn}), inoltre, sono presenti 1 o più strati nascosti, cosa che non succede nel perceptrone multistrato.

L'output di una rete neurale avente topologia simile a quella in figura \ref{ffnn} è:

\begin{equation}
y=g\left(\sum_{j=0}^{J}W_{j}h\left(\sum_{i=0}^{I}w_{ji}x_{i}\right)\right)
\end{equation}

Similmente a quanto espresso nel paragrafo precedente riguardante la classificazione, anche in un problema di regressione ci si pone l'obiettivo di minimizzare una funzione di costo (tramite il metodo della discesa del gradiente) che, nel caso di una rete neurale feedforward, è data dalla:

\begin{equation}
E = \sum_{n=0}{N}(t_{n}-y_{n})^2
\end{equation}

L'apprendimento in una rete neurale feedforward (chiamata così in quanto, per ottenere l'output della rete, l'informazione fluisce unidirezionalmente dallo strato di input a quello di output) avviene tramite un processo chiamato **Backpropagation** che, similmente con quanto visto nel paragrafo precedente, utilizza il metodo del gradiente per minimizzare iterativamente la funzione di errore della rete neurale.

Il processo di backpropagation è costituito da due fasi:

1. La prima fase, chiamata **passo in avanti** consiste nel calcolare, per ogni neurone, l'output dello stesso tramite una funzione non lineare che lega l'input ai pesi associati al neurone considerato.
2. La seconda fase, chiamata **passo indietro** consiste nel ricalcolare tutti i pesi neurali partendo da quelli più vicini allo strato di output fino agli strati di input, utilizzando la regola di aggiornamento data dal metodo del gradiente.

Altre topologie di reti neurali sono le reti neurali ricorrenti e gli autoencoder.

### Detezione di anomalie
In questo Use Case si utilizzano dei metodi che sintetizzano i casi di classificazione e regressione visti in precedenza, al fine di costruire dei modelli in grado di monitorare il comportamento di una certa variabile di interesse e stabilire, con una certa precisione, se il comportamento osservato rientra in alcuni gradi di accettabilità definiti a priori.

In estrema sintesi, la detezione di una anomalia può essere effettuata attraverso l'analisi di serie temporali relative ad una grandezza, effettuando delle previsioni sulla serie in esame e classificare quindi il risultato come "Anomalo" o "Normale". Un esempio di detezione di anomalia tramite analisi di serie temporali è dato dal lavoro svolto da Malhotra et al. [@malhotraLongShortTerm2015], nel quale è stata costruita una rete neurale ricorrente in grado di memorizzare delle sequenze numeriche al fine di individuare anomalie nell'andamento di un una certa variabile. Questo tipo di rete neurale viene chiamata Long Short Term Memory (LSTM) per la capacità di, appunto, ricordare sequenze numeriche di lunghezza variabile.

Le reti neurali ricorrenti sono una particolare topologia di rete neurale in cui è inserita una sotto topologia chiamata _"rete di contesto"_ in cui vengono aggiunti nuovi neuroni negli strati nascosti. Gli output di questi neuroni sono connessi sia allo strato di output, sia a agli strati di input implementando un ritardo temporale così come avviene in un sistema retroazionato. L' apprendimento di queste reti neurali viene svolto attraverso un' estensione del processo standard di backpropagation, chiamato _"backpropagation nel tempo"_. La differenza sostanziale con l'algoritmo standard consiste in una fase preliminare ai passaggi della backpropagation, nella quale la rete ricorrente viene trasformata in una rete neurale feedforward attraverso un procedimento chiamato _"network unfolding"_ che procede a "dispiegare" la rete secondo tutti gli istanti temporali dati in input.

![Topologia di una LSTM \label{lstmpdf}](digital/img/lstm.pdf)

Una rete di tipo LSTM, come già detto, è una rete neurale ricorrente capace di apprendere sequenze anche molto lunghe. In generale, le LSTM sono composte da sequenze di reti neurali, ognuna di queste caratterizzate da una specifica funzione. La topologia generale di una LSTM viene riportata in figura \ref{lstmpdf}.

Si differenziano i seguenti moduli:

- **Forget Gate**: Il risultato di questa rete è 0 o 1. Nel primo caso, quindi, il valore in memoria $h^{t-1}$ viene cancellato. In caso contrario, il valore passa al prossimo modulo in modo inalterato.
- **Input Gate**: Controlla il valore da riportare allo stato $h^{t}$.
- **Constant Error Carousel (CEC)**: Rete neurale utilizzata per contrastare un problema tipico dell'apprendimento delle reti neurali ricorrenti chiamato "scomparsa del gradiente". Questo effetto è conseguente all'applicazione del metodo del gradiente durante la fase di network unfolding citata precedentemente. In sintesi, durante lo svolgimento dell'algoritmo dato dalle equazioni \ref{eq:update}, si ottiene una catena di moltiplicazioni tra termini tutti inferiori a 1. In questo modo, il gradiente risultante tende ad annullarsi all'aumentare delle fasi di "dispiegamento", annullando quindi la possibilità di identificare un mininimo della funzione di costo. Grazie al CEC, si previene la scomparsa del gradiente perchè si inserisce un elemento che mantiene un peso sinaptico costante e pari a 1.
- **Output Gate**: Ultima rete che controlla il risultato finale della LSTM.
