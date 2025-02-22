#!/bin/sh

# Controlla se la directory dei socket di MySQL non esiste
# Se non esiste la crea e ne cambia il proprietario in mysql:mysql
if [ ! -d "/run/mysqld" ]; then
    mkdir -p /run/mysqld
    chown -R mysql:mysql /run/mysqld
fi

# Controlla se MySQL è già stato inizializzato verificando la directory dei dati
if [ ! -d "/var/lib/mysql/mysql" ]; then
    # Cambia il proprietario della directory dei dati di MySQL
    chown -R mysql:mysql /var/lib/mysql

    # Inizializza il database di MySQL: 
    # Questo comando crea le directory e i file di sistema necessari per il funzionamento del database. 
    #
    # NOTA:
    # L'utente mysql è un utente del sistema operativo creato durante l'installazione 
    # di MySQL o MariaDB. Questo utente ha permessi limitati e viene utilizzato per 
    # eseguire il server MySQL e gestire i file di dati del database.
    # Questo utente viene  creato durante l'installazione di MySQL o MariaDB. 
    # Questo utente è specificamente creato per eseguire il server MySQL e gestire i file di dati del database.
    mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --rpm > /dev/null

    # Crea un file temporaneo utilizzato per memorizzare i comandi SQL di 
    # configurazione iniziale che verranno eseguiti per configurare il database MariaDB
    tfile=`mktemp`
    if [ ! -f "$tfile" ]; then
        return 1  # Se il file temporaneo non è stato creato, esce con errore
    fi

    # Scrivo i comandi SQL di configurazione iniziale nel file temporaneo
    cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;

-- elimino tutti gli account utente anonimi dalla tabella mysql.user
DELETE FROM mysql.user WHERE User='';

-- Rimuove il database di test creato automaticamente durante l'installazione di MySQL o Mariadb
DROP DATABASE test;
DELETE FROM mysql.db WHERE Db='test';

-- Restringe l'accesso dell'utente root alle sole connessioni locali
-- Questo significa che l'utente root potrà connettersi al database 
-- solo dal computer locale (localhost) e non da indirizzi IP remoti.
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Crea il database specificato dalla variabile d'ambiente
CREATE DATABASE $MYSQL_DATABASE CHARACTER SET utf8 COLLATE utf8_general_ci;

-- Questi comandi creano un secondo utente nel database MariaDB con il nome e la password 
-- specificati dalle variabili d'ambiente e concedono a questo utente 
-- tutti i privilegi sul database. Questo utente 
-- è separato dall'utente root e viene utilizzato per operazioni quotidiane sul database.
-- NOTA: In '$MYSQL_USER'@'%', la "@" specifica che l'utente può connettersi da qualsiasi host remoto.
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';

--  questo comando modifica l'utente root per utilizzare il metodo di autenticazione 
-- mysql_native_password e imposta la password dell'utente root alla password specificata 
-- nella variabile d'ambiente. Questo garantisce che l'utente root possa autenticarsi con 
-- la nuova password quando si connette al database dal localhost
ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD '$MYSQL_ROOT_PASSWORD';

FLUSH PRIVILEGES;
EOF

    # Questo comando avvia il server MySQL in modalità bootstrap e esegue i comandi SQL 
    # di configurazione iniziale contenuti nel file temporaneo $tfile.
    # La modalità bootstrap di MySQL (o MariaDB) è una modalità speciale utilizzata 
    # per eseguire comandi SQL di inizializzazione prima che il server MySQL sia 
    # completamente operativo. In questa modalità, il server non accetta connessioni 
    # client esterne e viene utilizzato principalmente per configurare il database 
    # con le impostazioni iniziali.
    /usr/bin/mysqld --user=mysql --bootstrap < $tfile
    # Rimuove il file temporaneo dopo l'inizializzazione
    rm -f $tfile
fi

# Abilita connessioni remote al server MariaDB: rimuove 'skip-networking' dal file di configurazione di MySQL
# La direttiva skip-networking nel file di configurazione di MariaDB disabilita 
# le connessioni di rete al server MariaDB, permettendo solo connessioni locali 
# tramite socket Unix. Commentando questa direttiva
# il comando sed la disabilita, permettendo al server MariaDB di accettare connessioni dalla rete e non solo
# da localhost (il computer in cui è in esecuzione il server MariaDB).
#
# NOTA:
# Nel file di configurazioni iniziale ho limitato l'accesso dell'utente root alle sole connessioni locali per motivi di sicurezza, 
# ma ho anche creando un nuovo utente che può connettersi da remoto.
# Con questo comando abilito le connessioni remote al server MariaDB
sed -i "s|skip-networking|# skip-networking|g" /etc/my.cnf.d/mariadb-server.cnf

# Configura MySQL per accettare connessioni da qualsiasi indirizzo IP:
# Di default, MySQL è configurato per accettare connessioni solo da localhost.
# Questo comando modifica la direttiva bind-address nel file di configurazione di MySQL
# per accettare connessioni da qualsiasi indirizzo IP.
sed -i "s|.*bind-address\s*=.*|bind-address=0.0.0.0|g" /etc/my.cnf.d/mariadb-server.cnf

# Avvia il server MySQL in modalità normale:
# exec: sostituisce il processo corrente con il processo specificato. 
# In questo caso, sostituisce il processo dello script di shell con il processo 
# del server MySQL. Questo significa che il server MySQL diventa il processo principale in esecuzione nel container.
#
# /usr/bin/mysqld: Questo è il percorso dell'eseguibile del server MySQL (o MariaDB). 
# mysqld è il demone del server MySQL che gestisce le operazioni del database
#
# --user=mysql:  specifica che il server MySQL deve essere eseguito con l'utente mysql. Questo è 
# importante per garantire che il server abbia i permessi corretti per accedere ai file di dati del database.
#
# --console: specifica che i log del server MySQL devono essere inviati alla console del container.
#
# Dopo aver eseguito la configurazione iniziale in modalità bootstrap, questo comando 
# avvia il server MySQL in modalità normale, pronto per accettare connessioni client 
# e gestire le operazioni del database.
# Eseguire il server con l'utente mysql garantisce che il server abbia i permessi 
# corretti per accedere ai file di dati del database.
exec /usr/bin/mysqld --user=mysql --console