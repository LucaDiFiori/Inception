#!/bin/sh

# Controlla se la directory dei socket di MySQL non esiste
# Se non esiste la crea e ne cambia il proprietario in mysql:mysql
if [ ! -d "/run/mysqld" ]; then
    mkdir -p /run/mysqld
    chown -R mysql:mysql /run/mysqld
fi



# DA FINIRE DI COMMENTARE



# Controlla se MySQL è già stato inizializzato verificando la directory dei dati
if [ ! -d "/var/lib/mysql/mysql" ]; then
    # Cambia il proprietario della directory dei dati di MySQL
    chown -R mysql:mysql /var/lib/mysql

    # Inizializza il database di MySQL
    mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --rpm > /dev/null

    # Crea un file temporaneo per i comandi SQL di inizializzazione
    tfile=`mktemp`
    if [ ! -f "$tfile" ]; then
        return 1  # Se il file temporaneo non è stato creato, esce con errore
    fi

    # Scrive i comandi SQL di configurazione iniziale nel file temporaneo
    cat << EOF > $tfile

USE mysql;
FLUSH PRIVILEGES;

-- Rimuove utenti anonimi
DELETE FROM mysql.user WHERE User='';

-- Rimuove il database di test
DROP DATABASE test;
DELETE FROM mysql.db WHERE Db='test';

-- Restringe l'accesso dell'utente root alle connessioni locali
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Crea il database specificato dalla variabile d'ambiente
CREATE DATABASE $MYSQL_DATABASE CHARACTER SET utf8 COLLATE utf8_general_ci;

-- Crea un utente con privilegi sul database creato
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';

-- Imposta la password di root e permette l'accesso da qualsiasi host
ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD '$MYSQL_ROOT_PASSWORD';

FLUSH PRIVILEGES;
EOF

    # Esegue i comandi SQL iniziali usando MySQL in modalità bootstrap
    /usr/bin/mysqld --user=mysql --bootstrap < $tfile
    # Rimuove il file temporaneo dopo l'inizializzazione
    rm -f $tfile
fi

# Abilita connessioni remote: rimuove 'skip-networking' dal file di configurazione di MySQL
sed -i "s|skip-networking|# skip-networking|g" /etc/my.cnf.d/mariadb-server.cnf

# Configura MySQL per accettare connessioni da qualsiasi indirizzo IP
sed -i "s|.*bind-address\s*=.*|bind-address=0.0.0.0|g" /etc/my.cnf.d/mariadb-server.cnf

# Avvia il server MySQL in modalità normale
exec /usr/bin/mysqld --user=mysql --console