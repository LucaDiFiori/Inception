#!/bin/bash

# Attendi che MariaDB sia pronto
echo "Waiting for MariaDB to be ready..."
until mysqladmin -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" ping --silent; do
    sleep 3
done
echo "MariaDB is ready!"

# verifico se il file di configurazione di WordPress (wp-config.php) esiste già. Se non esiste, scarica WordPress 
# utilizzando WP-CLI (WordPress Command Line Interface).
# Il file wp-config.php è il file di configurazione principale di WordPress. Contiene le impostazioni cruciali 
# per il funzionamento del sito WordPress, come le credenziali del database, le chiavi di sicurezza, e altre 
# configurazioni importanti. 
if [ ! -f "wp-config.php" ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root


# Crea wp-config.php utilizzando WP-CLI
    echo "Creating wp-config.php..."
    # Questo comando di WP-CLI crea il file wp-config.php nella directory corrente.
    # --allow-root=:  Questa opzione consente di eseguire WP-CLI come utente root.
    # --dbname="$WORDPRESS_DB_NAME": Specifica il nome del database da utilizzare per WordPress.
    # --dbuser="$WORDPRESS_DB_USER": Specifica l'utente del database.
    # --dbpass="$WORDPRESS_DB_PASSWORD": Specifica la password dell'utente del database.
    # --dbhost="$WORDPRESS_DB_HOST": Specifica l'host del database (il mio container MariaDB).
    wp config create --allow-root \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$WORDPRESS_DB_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST"

    # Aggiungi chiavi di sicurezza nel wp-config.php eseguendo il comando curl per scaricare le chiavi
    # generate dinamicamente dall'API di WordPress e le aggiunge al file wp-config.php.
    #
    # Queste chiavi vengono utilizzate per crittografare le informazioni memorizzate nei cookie, 
    # rendendo più difficile per gli attaccanti decifrare i dati e compromettere la sicurezza del sito.
    if ! grep -q "AUTH_KEY" wp-config.php; then
        curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> wp-config.php
    fi

    echo "wp-config.php has been generated successfully."

    # Questo comando di WP-CLI installa WordPress nella directory corrente.
    # --allow-root: Questa opzione consente di eseguire WP-CLI come utente root.
    # --url="https://$DOMAIN_NAME/wordpress": Specifica l'URL del sito WordPress.
    # --title="$WP_SITE_TITLE": Specifica il titolo del sito WordPress.
    # --admin_user="$ADMIN_USER": Specifica il nome utente dell'amministratore.
    # --admin_password="$ADMIN_PASSWORD": Specifica la password dell'amministratore.
    # --admin_email="$ADMIN_EMAIL": Specifica l'indirizzo email dell'amministratore.
    # --skip-email: Evita l'invio dell'email di notifica di installazione.
    wp core install --allow-root \
        --url="https://$DOMAIN_NAME/wordpress" \
        --title="$WP_SITE_TITLE" \
        --admin_user="$ADMIN_USER" \
        --admin_password="$ADMIN_PASSWORD" \
        --admin_email="$ADMIN_EMAIL" \
        --skip-email \

    # Crea un utente aggiuntivo
    wp user create \
        "$WORDPRESS_DB_USER" "$WP_SECOND_EMAIL" \
        --role=author \
        --user_pass="$WORDPRESS_DB_PASSWORD" \
        --allow-root || true

    # installo un tema personalizzato
    wp theme install bizboost --activate --allow-root || true
fi

#  verifico se la directory wp-content di WordPress esiste e, se esiste, 
# cambia il proprietario e il gruppo della directory e di tutti i 
# suoi contenuti all'utente e al gruppo nginx.
#
# La directory wp-content è una delle directory principali di un'installazione di WordPress create durante
# il processo di installazione di Wordpress. 
# Contiene tutti i contenuti personalizzati del sito, inclusi temi, plugin e file caricati dagli utenti. 
if [ -d "/var/www/html/wordpress/wp-content" ]; then
    chown -R nginx:nginx /var/www/html/wordpress/wp-content
fi

echo "WordPress setup is complete."

# Avvia PHP-FPM
echo "Starting PHP-FPM service..."
exec /usr/sbin/php-fpm82 -F
