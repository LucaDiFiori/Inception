FROM alpine:3.20.5

# Aggiorna i repository dei pacchetti, esegue l'upgrade dei pacchetti 
# installati e installa MariaDB e il client MariaDB

# Installa il server MariaDB, un sistema di gestione di database relazionale derivato da MySQL
# Installa il client MariaDB, che consente di connettersi e interagire con il server MariaDB
RUN apk update && apk upgrade && apk add --no-cache \
        mariadb \
        mariadb-client

# vedere se va tolto (claudia non lo mette)
# COPY tools/50-server.cnf /etc/my.cnf
        
COPY tools/configure.sh /tmp/configure.sh

ENTRYPOINT ["sh", "/tmp/configure.sh"]