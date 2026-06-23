# Piano

## Obiettivo

Creare tre subagent leggeri (`commit-MC`, `comment-MC`, `ideas-organizer-MC`) basati su `deepseek/deepseek-v4-flash` per produrre manufatti finali, e aggiornare i primary esistenti perché li invochino quando appropriato.

## Contesto

L'utente vuole ottimizzare il consumo di token usando modelli leggeri solo per operazioni finali, non per computazioni intermedie. I subagent non devono generare output che altri agenti riutilizzano. I vincoli e gli esempi sono già stati esplorati e raccolti in `IDEAS.md`.

## Task

- [x] Creare `agents/commit-MC.md`
  - subagent con `model: deepseek/deepseek-v4-flash`
  - legge `git diff --staged` (o la working tree se richiesto)
  - propone un messaggio di commit in formato conventional commit
  - non esegue `git commit` autonomamente senza conferma esplicita
- [x] Creare `agents/comment-MC.md`
  - subagent con `model: deepseek/deepseek-v4-flash`
  - aggiunge o aggiorna commenti nel codice dei file indicati, senza modificare la logica
  - richiede l'elenco dei file o un pattern
- [x] Creare `agents/ideas-organizer-MC.md`
  - subagent con `model: deepseek/deepseek-v4-flash`
  - riorganizza e formatta `IDEAS.md` mantenendo il contenuto semantico
  - può essere invocato su richiesta o quando il file diventa disordinato
- [x] Aggiornare `agents/planner-MC.md`
  - aggiungere istruzioni per delegare a `commit-MC` e `comment-MC` quando l'utente lo richiede esplicitamente
- [x] Aggiornare `agents/small-feature-MC.md`
  - aggiungere istruzioni per offrire/invocare `commit-MC` e `comment-MC` al termine di una modifica
- [x] Aggiornare `agents/fixer-MC.md`
  - aggiungere istruzioni per offrire/invocare `commit-MC` e `comment-MC` dopo una fix
- [x] Aggiornare `agents/brainstormer-MC.md`
  - aggiungere istruzioni per invocare `ideas-organizer-MC` quando `IDEAS.md` diventa disordinato o su richiesta

## Note e vincoli

- Tutti i nuovi subagent usano il modello `deepseek/deepseek-v4-flash`.
- I subagent producono solo manufatti finali; non generano contesto per altri agenti.
- I primary devono chiedere conferma all'utente prima di applicare modifiche che toccano il codice o il repository (es. commenti, commit).
- Non modificare il comportamento core dei primary oltre all'aggiunta dei punti di delega.
- Non cambiare i modelli degli agenti esistenti.
