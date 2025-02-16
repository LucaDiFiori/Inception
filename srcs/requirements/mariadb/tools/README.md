# CONCETTI IMPORTANTI
- [MYSQL SOCKET](#MYSQL_SOCKET)

***
***

# MYSQL SOCKET
Lo script inizia creando la cartella per i socket MySQL.
```sh
if [ ! -d "/run/mysqld" ]; then
    mkdir -p /run/mysqld
    chown -R mysql:mysql /run/mysqld
fi
```

## Cosa sono i socket di MySQL?
Un socket è un file speciale che permette la comunicazione tra processi all'interno dello stesso sistema operativo. MySQL utilizza un socket Unix (di solito un file con estensione .sock) per consentire ai client di connettersi al server in modo efficiente senza passare per la rete.


Quando un client MySQL (come mysql da terminale o un'applicazione PHP) si connette al server MySQL, può farlo in due modi principali:
1. **Tramite socket Unix** (quando client e server sono sulla stessa macchina):
    - Il server MySQL crea un file socket, ad esempio /run/mysqld/mysqld.sock.
    - Il client MySQL, invece di aprire una connessione di rete, scrive direttamente su questo file.
    - Il server legge il file, risponde, e la comunicazione avviene tramite il filesystem invece che tramite la rete.

2. **Tramite TCP/IP** (necessario quando il client è su un'altra macchina):
    - Il server MySQL si mette in ascolto su una porta (tipicamente 3306).
    - Il client invia richieste tramite la rete al server, specificando un indirizzo IP o un hostname.
    - La comunicazione avviene attraverso il protocollo TCP/IP, con più overhead rispetto al socket Unix.


## A cosa servono i socket in MySQL?
I socket servono quindi a stabilire connessioni più veloci rispetto a quelle basate su TCP/IP (Transmission Control Protocol / Internet Protocol). 
Quando un client MySQL si connette al server tramite socket:

1. **Non usa la rete**: il client e il server comunicano direttamente tramite il file .sock, evitando l'overhead della comunicazione TCP.
2. **È più veloce e sicuro**: non essendo esposto sulla rete, il socket riduce il rischio di attacchi esterni.
3. **Viene usato di default**: quando un client si connette senza specificare un indirizzo IP o un hostname, MySQL prova prima a usare il socket.

**NOTA**: Ricordiamo che il Protocolo TCP/IP è il sistema alla base delle comunicazioni su internet e sulle reti locali. Una connessione TCP/IP è una comunicazione tra due dispositivi su una rete, dove i dati vengono divisi in pacchetti e trasmessi in modo affidabile.


## Perché  creiamo la directory /run/mysqld?
Nello script verifichiamo se la directory /run/mysqld esiste. Se non esiste:

- La creiamo con mkdir -p /run/mysqld.
- Impostiamo i permessi corretti con chown -R mysql:mysql /run/mysqld, in modo che solo l'utente mysql possa accedervi e creare il file .sock.

Senza questa directory, MySQL potrebbe non riuscire a creare il socket e i client potrebbero non riuscire a connettersi al database localmente.