# Idee

## Tema: Ottimizzazione consumo token per agenti opencode

### Idea: Modelli leggeri per task meccanici (direzione scelta)
- Creare subagent leggeri invocati dagli agenti primari esistenti per produrre manufatti finali: non devono generare output che altri agenti riutilizzano, ma solo risultati destinati all'utente o al repository.
- **Modello scelto**: `deepseek/deepseek-v4-flash` per tutti i subagent leggeri.
- **Come altri hanno affrontato problemi simili**: in molti setup di agent coding si distingue tra "fast model" (operazioni meccaniche) e "slow model" (ragionamento complesso e scrittura codice critico). Tool come commit-message generator, doc updater e changelog builder sono classici candidati per il fast model.
- **Perché**: questi task sono altamente strutturati e non richiedono ragionamento profondo; un modello leggero riduce il costo per richiesta e spesso la latenza.
- Vincoli emersi: gli agenti snelli sono subagent, non primary; producono solo manufatti finali (es. commit message, commenti, riorganizzazione file); non fanno computazioni intermedie per altri agenti.
- Pro: risparmio immediato su task ad alto volume; semplice da implementare in opencode cambiando il modello nel frontmatter dell'agente.
- Contro: richiede di modificare i primary per riconoscere quando delegare; rischio di qualità inferiore su task che in apparenza sono semplici ma nascondono edge case.
- Stato: promettente

#### Sotto-idea: `commit-MC`
- Subagent leggero che legge `git diff --staged` (o la working tree) e propone un messaggio di commit, preferibilmente in formato conventional commit.
- **Come altri hanno affrontato problemi simili**: tool come `aicommit`, `commitlint` con LLM o integrazioni in IDE generano messaggi di commit con modelli piccoli perché il task è altamente strutturato.
- **Perché`: il pattern del diff è prevedibile e il risultato desiderato ha un formato rigido; non serve ragionamento profondo.
- Integrazione: `@planner-MC`, `@small-feature-MC` o `@fixer-MC` lo invocano al termine del lavoro, oppure l'utente lo richiede esplicitamente a un primary.
- Stato: promettente

#### Sotto-idea: `comment-MC`
- Subagent leggero che aggiunge o aggiorna commenti nel codice di uno o più file selezionati, senza modificare la logica.
- **Come altri hanno affrontato problemi simili**: tool di docstring generation e di commenting assistito usano spesso modelli di medie dimensioni per produrre testo esplicativo derivato dal codice.
- **Perché`: spiegare cosa fa un frammento di codice è un task di riscrittura strutturata; non richiede inventare algoritmi.
- Integrazione: `@small-feature-MC` o `@planner-MC` lo invocano quando l'utente chiede esplicitamente commenti/documentazione inline; utile anche dopo una fix per chiarire il perché di una modifica.
- Stato: promettente

#### Sotto-idea: `ideas-organizer-MC`
- Subagent leggero che riorganizza, ripulisce e formatta `IDEAS.md` mantenendo il contenuto semantico, migliorandone la leggibilità e la struttura.
- **Come altri hanno affrontato problemi simili**: tool di linting/formatting per documentazione (es. prettier, markdownlint) sono comuni; con un LLM leggero si può fare una riorganizzazione semantica oltre che stilistica.
- **Perché`: la riorganizzazione di un file markdown esistente è un task meccanico di riscrittura.
- Integrazione: `@brainstormer-MC` lo invoca periodicamente o su richiesta dell'utente per tenere `IDEAS.md` ordinato.
- Stato: promettente

#### Sotto-idea: `changelog-MC` (opzionale)
- Subagent leggero che genera o aggiorna `CHANGELOG.md` a partire da una serie di commit o da `git log`.
- **Come altri hanno affrontato problemi simili**: molti progetti usano strumenti automatici (es. `semantic-release`, `release-please`) per generare changelog; un LLM leggero può riassumere e formattare quando gli strumenti strutturati non bastano.
- **Perché`: riassumere commit in voci di changelog è un task meccanico di riscrittura.
- Stato: in esplorazione

#### Sotto-idea: `doc-MC` (opzionale)
- Subagent leggero che aggiorna README o genera documentazione boilerplate derivata dal codice.
- **Come altri hanno affrontato problemi simili**: tool di doc generation usano spesso modelli di medie dimensioni per task ripetitivi.
- **Perché`: quando il contenuto è derivato direttamente dal codice, un modello leggero è spesso sufficiente.
- Stato: in esplorazione

### Idea: Small-feature su modello leggero
- `small-feature-MC` è pensato per modifiche piccole e ben delimitate; potrebbe usare un modello meno potente di `kimi-k2.7-code`, dato che non deve fare pianificazione architetturale né esplorazione ampia.
- **Come altri hanno affrontato problemi simili**: negli assistenti di coding, il flusso "quick edit" usa spesso un modello di medie dimensioni, riservando il top-tier solo a task che richiedono analisi multi-file o decisioni architetturali.
- **Perché`: small-feature è un entry point frequente; se la maggior parte delle richieste è davvero piccola, il risparmio complessivo può essere significativo.
- Pro: riduce il costo del caso d'uso più comune; il modello leggero può bastare per modifiche locali.
- Contro: se la richiesta non è così piccola come sembra, il modello leggero potrebbe fallire o produrre codice scadente, costringendo a rifare il lavoro con un modello più forte.
- Stato: scartata per ora (l'utente preferisce subagent finali, non modificare i primary su modelli leggeri)

### Idea: Routing della complessità verso builder diversi
- Invece di un unico `@builder-MC` su `deepseek-v4-pro`, prevedere due builder: uno forte per task complessi e uno leggero per task meccanici. Il planner (o `small-feature-MC`) sceglierebbe quale invocare in base alla natura del task.
- **Come altri hanno affrontato problemi simili**: nei sistemi di orchestrazione di agenti si usa un "router" o "dispatcher" che seleziona il worker in base alla difficoltà stimata del task.
- **Perché`: evita di usare il modello più potente per operazioni che non ne hanno bisogno, senza rinunciare alla qualità quando serve.
- Pro: flessibilità e potenziale risparmio sui task delegati.
- Contro: richiede una buona euristica per classificare i task; se il routing sbaglia, si perde tempo o qualità.
- Stato: scartata per ora (l'utente preferisce subagent finali, non routing su builder)

### Idea: Riduzione del contesto passato ai modelli
- Ottimizzare quanto contesto viene inviato agli agenti: per task semplici, passare solo i file rilevanti anziché l'intera codebase; usare riassunti pre-generati; evitare di includere file non necessari.
- **Come altri hanno affrontato problemi simili**: pattern "retrieve-then-generate" o RAG leggero, dove un modello (anche leggero) filtra i documenti rilevanti prima che il modello forte elabori.
- **Perché`: i token di input costano quanto (o più di) quelli di output; ridurre il contesto ha un impatto diretto indipendentemente dal modello.
- Pro: risparmio su ogni chiamata, anche con modelli forti; migliora anche la qualità riducendo il rumore.
- Contro: richiede di modificare il comportamento degli agenti per essere più selettivi; rischio di omettere contesto importante.
- Stato: scartata (l'utente ha esplicitamente deciso di non proseguire in questa direzione)

### Idea: Misurazione prima dell'ottimizzazione
- Aggiungere tracciamento dei costi/token per agente e per tipo di task, così da capire dove si consuma di più prima di decidere dove tagliare.
- **Come altri hanno affrontato problemi simili**: in ogni ottimizzazione di costi il primo passo è la misurazione ("you can't optimize what you don't measure"). Piattaforme e SDK offrono spesso metriche per modello/endpoint.
- **Perché`: senza dati si rischia di spostare modelli leggeri su task rari (risparmio irrisorio) o di mantenere modelli forti sui task che costano di più.
- Pro: decisioni basate su dati reali; evita ottimizzazioni inutili.
- Contro: non dà risparmio immediato; potrebbe richiedere un po' di logging manuale se opencode non espone metriche native.
- Stato: scartata per ora (l'utente preferisce agire direttamente sulla direzione 1)

### Idea: Modelli locali per task a basso rischio
- Per task come commit, riassunti o draft di documentazione, usare modelli locali (es. via Ollama, LM Studio) invece di API cloud.
- **Come altri hanno affrontato problemi simili**: sviluppatori che lavorano su codebase sensibili o che vogliono ridurre costi usano modelli locali per task di bassa criticità, riservando le API cloud a task dove la qualità conta di più.
- **Perché`: elimina il costo API per quei task; i modelli locali recenti sono sufficienti per compiti meccanici.
- Pro: costo zero per task semplici; privacy massima.
- Contro: richiede hardware adeguato; latenza più alta; setup aggiuntivo; qualità variabile.
- Stato: scartata per ora (l'utente preferisce subagent con modelli cloud leggeri)
