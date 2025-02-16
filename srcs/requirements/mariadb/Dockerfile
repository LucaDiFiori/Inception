# Dockerfile per l'immagine MariaDB:
# ----------------------------------
# - FROM: utilizza Alpine Linux come immagine base, nella versione 3.20.5.
#         Alpine è una distribuzione leggera e minimale, ideale per container Docker.
# - RUN: aggiorna i pacchetti esistenti e installa MariaDB e il client MariaDB senza cache.
#        L'opzione --no-cache evita il salvataggio degli indici dei pacchetti per ridurre lo spazio occupato.
#   - mariadb: installa il server MariaDB, un sistema di gestione di database relazionale (RDBMS) compatibile con MySQL.
#   - mariadb-client: installa il client a riga di comando per MariaDB, necessario per connettersi al server
#                     ed eseguire comandi SQL. Viene installato per consentire la gestione del database 
#                     direttamente dal container senza bisogno di strumenti esterni.
# - COPY: copia lo script configure.sh dalla directory tools del contesto di build alla cartella temporanea del container.
# - ENTRYPOINT: imposta lo script configure.sh come comando eseguito all'avvio del container.
FROM alpine:3.20.5

RUN apk update && apk upgrade && apk add --no-cache \
        mariadb \
        mariadb-client
        
COPY tools/configure.sh /tmp/configure.sh

ENTRYPOINT ["sh", "/tmp/configure.sh"]