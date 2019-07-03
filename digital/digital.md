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

4. **Sviluppo continuo e cultura "Data-driven"**: l'instaurazione di una strategia di manutenzione predittiva rappresenta, per il settore industriale, un vantaggio competitivo in quanto permette di sfruttare la raccolta dei dati, grazie a tecnologie di IoT, per la costruzione di una strategia a lungo termine improntata sull'abbattimento dei costi e l'ottimale utilizzo delle risorse disponibili. Ritroviamo questi importanti obiettivi anche nel settore Sanitario dove, a fronte di esigenze sanitarie sempre crescenti (dovute al progressivo invecchiamento della popolazione e al conseguente aumento dei malati cronici) è richiesta una continua evoluzione dei sistemi di cura tale da contenere le spese e rispondere a questi bisogni sanitari ottimizzando lo sfruttamento dei mezzi a disposizione.


To conclude …
The digitalization of production processes, that is the possibility of collecting factory data in real time and storing them correctly, allows to better know the problems of machinery and to avoid downtimes and micro-downtimes.

The creation of a digital factory, a fundamental requirement to implement a predictive maintenance program, makes it possible to use advanced analysis in decision-making processes based on increasingly accurate and simple data to be processed. To this already important result, we add the benefits related to cost advantages and efficiency improvements.

## Metodi analitici di predizione
Esistono fondamentalmente tre tipologie di domande alle quali la manutenzione predittiva cerca di dare risposta. Definiamo queste domande come Use Case, per indicare la tipologia di problema che si vuole affrontare.

Il primo Use Case rappresenta un classico problema di classificazione. Per problema di classificazione si intende l'identificazione della classe di appartenenza di nuove osservazioni, sulla base di un training set di dati che contengono istanze (osservazioni) la cui appartenenza alle classi in esame è nota.
