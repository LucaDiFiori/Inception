# PHP-FMP
PHP-FPM (FastCGI Process Manager) è un gestore di processi per PHP che ottimizza l'esecuzione di script PHP in ambienti ad alto traffico. Consente a server web come Nginx o Apache di eseguire codice PHP in modo efficiente.

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