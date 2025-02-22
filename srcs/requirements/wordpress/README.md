# PHP-FMP
PHP-FPM (FastCGI Process Manager) è un gestore di processi per PHP che ottimizza l'esecuzione di script PHP in ambienti ad alto traffico. Consente a server web come Nginx o Apache di eseguire codice PHP in modo efficiente.

Andrò ad installarlo nel container in quanto WordPress è un'applicazione web scritta in PHP. Per funzionare, ha bisogno di un interprete PHP che esegua i suoi script PHP.
```bash
(...)

RUN (...)
    # php82-fpm è un gestore di processi FastCGI per PHP. CIoè sto installanto PHP-FMP
    php82-fpm \ 
   (...)
```

## Perché serve PHP-FPM?
I server web come Nginx non possono eseguire direttamente codice PHP. Devono delegare l'elaborazione degli script PHP a un processo separato. PHP-FPM fa proprio questo:

- Riceve richieste PHP dal web server
- Esegue il codice PHP
- Restituisce la risposta al web server

PHP-FPM è una versione avanzata di FastCGI, progettata per gestire molte richieste in parallelo, migliorando le prestazioni e riducendo il consumo di risorse.

## Cos'è un gestore di processi?
Un gestore di processi è un software che si occupa di creare, gestire e terminare i processi di un'applicazione. Nel caso di PHP-FPM, il suo ruolo è gestire i processi PHP, distribuendo le richieste tra di essi per garantire prestazioni elevate e stabilità.

## Come lavora PHP-FPM come gestore di processi?
PHP-FPM mantiene un **pool di processi PHP sempre pronti** a elaborare richieste. Quando arriva una nuova richiesta:

1. **PHP-FPM assegna un processo libero** per eseguire il codice PHP.
2. **Il processo esegue lo script PHP e restituisce il risultato** a Nginx.
3. **Il processo torna in attesa di nuove richieste**, senza essere terminato.

In questo modo, il server può gestire molte richieste contemporaneamente senza creare nuovi processi ogni volta, riducendo il consumo di risorse.


***

# WWW.CONF
Il file www.conf è un file di configurazione per PHP-FPM (FastCGI Process Manager), che è un componente utilizzato per eseguire script PHP. Questo file deve essere incluso nel container di WordPress perché PHP-FPM è responsabile dell'elaborazione degli script PHP che costituiscono il core di WordPress.

### Esecuzione degli script PHP:
WordPress è un'applicazione PHP, quindi richiede un interprete PHP per eseguire i suoi script. PHP-FPM è un gestore di processi per PHP che gestisce l'esecuzione degli script PHP in modo efficiente.

### Configurazione di PHP-FPM:
Il file www.conf contiene la configurazione per PHP-FPM, specificando come devono essere gestiti i processi PHP. Questa configurazione include l'utente e il gruppo con cui eseguire i processi, il socket di ascolto per le connessioni FastCGI, e le impostazioni del gestore di processi.

### Integrazione con Nginx
Nginx è un server web che gestisce le richieste HTTP. Quando Nginx riceve una richiesta per uno script PHP, non lo elabora direttamente. Invece, inoltra la richiesta a PHP-FPM, che esegue lo script PHP e restituisce l'output a Nginx.


## FLUSSO DI LAVORO
- **Nginx riceve una richiesta HTTP**: 
    - Quando un utente visita il sito web WordPress, il browser invia una richiesta HTTP al server Nginx.
    - Esempio: L'utente visita https://ldi-fior.42.rm/wordpress/index.php.

- **Nginx determina come gestire la richiesta**: 
    - Nginx riceve la richiesta e, in base alla sua configurazione, determina che la richiesta è per uno script PHP (index.php).

- **Nginx inoltra la richiesta a PHP-FPM**: 
    - Nginx inoltra la richiesta a PHP-FPM utilizzando il protocollo FastCGI. Questo è configurato nel file nginx.conf con direttive come fastcgi_pass.
    - 
- **PHP-FPM esegue lo script PHP di WordPress**:
    - PHP-FPM è in esecuzione nel container di WordPress.
    - PHP-FPM, configurato con il file www.conf, riceve la richiesta inoltrata da Nginx.
    - PHP-FPM esegue lo script PHP (index.php) di WordPress.
    - Durante l'esecuzione, PHP-FPM può interagire con il database, leggere o scrivere file, e generare contenuti dinamici.

- **PHP-FPM restituisce l'output a Nginx:**
    - Una volta completata l'elaborazione, PHP-FPM restituisce l'output dello script PHP a Nginx.

- **Nginx restituisce la risposta all'utente:**
    - Nginx riceve l'output dello script PHP da PHP-FPM.
    - Nginx invia questa risposta HTTP al browser dell'utente.
    - L'utente vede il contenuto generato dallo script PHP di WordPress nel proprio browser.

