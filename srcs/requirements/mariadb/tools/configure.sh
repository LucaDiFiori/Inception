#!/bin/sh

if [ ! -d "/run/mysqld" ]; then
	mkdir -p /run/mysqld
	chown -R mysql:mysql /run/mysqld
fi

if [ ! -d "/var/lib/mysql/mysql" ]; then
	
	chown -R mysql:mysql /var/lib/mysql

	# init database
	mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --rpm > /dev/null

	tfile=`mktemp`
	if [ ! -f "$tfile" ]; then
		return 1
	fi

	cat << EOF > $tfile
	
USE mysql;
FLUSH PRIVILEGES;

DELETE FROM	mysql.user WHERE User='';
DROP DATABASE test;
DELETE FROM mysql.db WHERE Db='test';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Creo il database
CREATE DATABASE $MYSQL_DATABASE CHARACTER SET utf8 COLLATE utf8_general_ci;

-- Creo un utente non-root e garantisco i privilegi 
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED by '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';

-- Creo una root password e concedo accesso root da qualsiasi host
ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD '$MYSQL_ROOT_PASSWORD';

FLUSH PRIVILEGES;
EOF
# CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
# ALTER USER 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
# GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

	# run init.sql
	/usr/bin/mysqld --user=mysql --bootstrap < $tfile
	rm -f $tfile
fi


# permesso connessioni remote
sed -i "s|skip-networking|# skip-networking|g" /etc/my.cnf.d/mariadb-server.cnf
sed -i "s|.*bind-address\s*=.*|bind-address=0.0.0.0|g" /etc/my.cnf.d/mariadb-server.cnf

exec /usr/bin/mysqld --user=mysql --console






# echo "Creating initdb.d directory..."
# mkdir -p initdb.d
# echo "✅ Directory created succesfully!"

# # Generate initialization SQL file
# echo "Creating init.sql file for db and user setup..."
# cat << EOF > /initdb.d/init.sql
# -- Creo il database
# CREATE DATABASE $MYSQL_DATABASE CHARACTER SET utf8 COLLATE utf8_general_ci;

# -- Creo un utente non-root e garantisco i privilegi 
# CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED by '$MYSQL_PASSWORD';
# GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';

# -- Creo una root password e concedo accesso root da qualsiasi host
# ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
# CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
# GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

# -- Flush privileges to apply changes
# FLUSH PRIVILEGES;
# EOF

# echo "✅ init.sql created succesfully!"

# echo "======== Starting Mariadb ========"

# cat << "EOF"

# ,---.    ,---.   ____    .-------.   .-./`)    ____     ______      _______    
# |    \  /    | .'  __ `. |  _ _   \  \ .-.') .'  __ `. |    _ `''. \  ____  \  
# |  ,  \/  ,  |/   '  \  \| ( ' )  |  / `-' \/   '  \  \| _ | ) _  \| |    \ |  
# |  |\_   /|  ||___|  /  ||(_ o _) /   `-'`"`|___|  /  ||( ''_'  ) || |____/ /  
# |  _( )_/ |  |   _.-`   || (_,_).' __ .---.    _.-`   || . (_) `. ||   _ _ '.  
# | (_ o _) |  |.'   _    ||  |\ \  |  ||   | .'   _    ||(_    ._) '|  ( ' )  \ 
# |  (_,_)  |  ||  _( )_  ||  | \ `'   /|   | |  _( )_  ||  (_.\.' / | (_{;}_) | 
# |  |      |  |\ (_ o _) /|  |  \    / |   | \ (_ o _) /|       .'  |  (_,_)  / 
# '--'      '--' '.(_,_).' ''-'   `'-'  '---'  '.(_,_).' '-----'`    /_______.'  
                                                                               
# EOF

# sed -i "s|skip-networking|# skip-networking|g" /etc/my.cnf.d/mariadb-server.cnf
# sed -i "s|.*bind-address\s*=.*|bind-address=0.0.0.0|g" /etc/my.cnf.d/mariadb-server.cnf

# # Start MariaDB with the initialization file
# exec mysqld --datadir="$MARIADB_DATA_DIR" --user=mysql --init-file=/initdb.d/init.sql