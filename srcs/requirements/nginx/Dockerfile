# Utilizza l'immagine base di Debian Bullseye
FROM debian:bullseye

# - Aggiorna l'elenco dei pacchetti disponibili
# - installa Nginx
# - installa OpenSSL:  è una libreria software e un toolkit per il protocollo SSL e TLS.
#                      Viene utilizzato per implementare la crittografia e garantire 
#                      comunicazioni sicure su reti di computer (creare e gestire i certificati).
#
# mkdir -p /run/nginx: 
# La directory /run/nginx è utilizzata da Nginx per memorizzare file temporanei 
# e di stato necessari per il funzionamento del server web.
# Ecco alcuni esempi di cosa potrebbe essere memorizzato in questa directory:
#
# - File di PID (Process ID): Nginx crea un file di PID che contiene l'ID del 
#                             processo principale di Nginx. Questo file è utilizzato p
#                             er gestire il processo di Nginx, ad esempio per inviare 
#                             segnali di riavvio o arresto
# - Socket Unix: socket Unix utilizzati  la comunicazione con altri servizi (come PHP-FPM), 
#               i file di socket possono essere memorizzati in questa directory.
#
# mkdir -p /etc/nginx/ssl:
# - I certificati SSL (Secure Sockets Layer) sono utilizzati per stabilire una connessione 
#   sicura e crittografata tra un server web e un client (come un browser web). 
#   Questo garantisce che i dati trasmessi tra il server e il client siano protetti da intercettazioni e manomissioni.
#
# - TLS (Transport Layer Security) è il successore di SSL e fornisce un livello di sicurezza migliorato. 
#   Anche se spesso si parla di SSL, la maggior parte delle connessioni sicure oggi utilizza TLS.
#
# Questo comando crea una directory /etc/nginx/ssl dove puoi memorizzare i certificati SSL/TLS. 
# Nginx utilizzerà questi certificati per stabilire connessioni HTTPS sicure con i client.
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    build-essential \
    nginx \
    bash \
    openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# directory per i socket di nginx
# Questa cartella  è utilizzata da Nginx per memorizzare file temporanei e di stato necessari per il suo funzionamento. 
# Nginx utilizza socket Unix per la comunicazione con altri servizi (come PHP-FPM), i file di socket possono essere memorizzati in questa directory.
RUN mkdir -p /run/nginx    


# Copia il file di configurazione di Nginx dalla directory 'conf' del contesto di build
# alla directory '/etc/nginx' all'interno del container, sovrascrivendo il file di configurazione di default.
#
# Se non volessi sovrascrivere la configurazione di defoult potrei salvarla nella
# La directory conf.d. Questa è utilizzata per organizzare la configurazione in file separati. 
# Ciò facilita la gestione di configurazioni complesse, poiché consente di modificare 
# o aggiungere configurazioni senza dover modificare il file principale nginx.conf.
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# Crea directory per i certificati SSL
RUN mkdir /etc/nginx/ssl

# Genera un certificato SSL autofirmato utilizzando OpenSSL
# - req: Questo comando viene utilizzato per generare e gestire i certificati X.509,
#        le richieste di firma dei certificati (CSR) e i file di chiavi private.
#
# - x509: Questo flag indica che si sta generando un certificato X.509.
# -nodes: Questa flag indica che la chiave privata generata non deve essere crittografata (no DES). 
#         Senza questa flag, OpenSSL richiederebbe una passphrase per proteggere la chiave privata.
# -out: Specifica il percorso e il nome del file in cui verrà salvato il certificato generato.
# -keyout: Specifica il percorso e il nome del file in cui verrà salvata la chiave privata generata.
# -subj: Specifica i valori dei campi del certificato X.509.
RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 \
     -nodes \
     -out /etc/nginx/ssl/ldi-fior.crt \
     -keyout /etc/nginx/ssl/ldi-fior.key \
     -subj "/C=IT/ST=Rome/L=Rome/O=42 School/OU=ldi-fior/CN=ldi-fior/"



EXPOSE 443


# - nginx: avvia il server web Nginx.
# --g "daemon off;": forza Nginx a rimanere in primo piano (non in modalità daemon), 
#  il che è necessario per mantenere il container in esecuzione. 
#  Se Nginx fosse eseguito in modalità daemon, il processo principale del container 
#  terminerebbe e il container si arresterebbe.
#
# In modalità daemon, un processo viene eseguito in background come servizio di sistema, 
# senza interazione diretta con l'utente. Questo significa che il processo non blocca il 
# terminale e continua a funzionare anche dopo che l'utente ha chiuso la sessione.
# Nel contesto di Nginx, eseguire in modalità daemon significa che Nginx si stacca dal 
# terminale e continua a funzionare in background. Tuttavia, in un container Docker, 
# è necessario che il processo principale rimanga in primo piano per mantenere il container attivo. 
# Ecco perché si utilizza l'opzione -g "daemon off;" per forzare Nginx a rimanere in primo piano.
CMD ["nginx", "-g", "daemon off;"]
