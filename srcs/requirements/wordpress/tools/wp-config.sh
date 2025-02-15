#!/bin/bash





# #FORSE POI DA TOGLIERE!!!!!!!!!!!!!!!!!!
# # Ensure working directory exists and correct permissions
# mkdir -p /var/www/wordpress && chown -R nginx:nginx /var/www/wordpress
# cd /var/www/wordpress





# # Attendi che MariaDB sia pronto
# while ! mariadb -h$WORDPRESS_DB_HOST -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE &>/dev/null; do
#     echo "Waiting for MariaDB to be ready..."
#     sleep 3
# done

# echo "MariaDB is ready!"

# # Crea wp-config.php manualmente se non esiste
# if [ ! -f "wp-config.php" ]; then
#     wp core download --allow-root

#     # Crea wp-config.php
#     wp config create --allow-root \
#         --dbname="$WORDPRESS_DB_NAME" \
#         --dbuser="$WORDPRESS_DB_USER" \
#         --dbpass="$WORDPRESS_DB_PASSWORD" \
#         --dbhost="$WORDPRESS_DB_HOST"
    
#     wp core install --allow-root \
#         --url="https://$DOMAIN_NAME/wordpress" \
#         --title="$WP_SITE_TITLE" \
#         --admin_user="$ADMIN_USER" \
#         --admin_password="$ADMIN_PASSWORD" \
#         --admin_email="$ADMIN_EMAIL" \
#         --skip-email

#     # Crea utente aggiuntivo
#     wp user create \
#         "$WORDPRESS_DB_USER" "$WP_SECOND_EMAIL" \
#         --role=author \
#         --user_pass="$WORDPRESS_DB_PASSWORD" \
#         --allow-root || true
    
#     # installo un tema
#     # wp theme install bizboost --activate --allow-root || true
# fi

# # Avvia PHP-FPM
# echo "WordPress configuration is completed!. Starting PHP-FPM service..."
# exec php-fpm82 -F



# mkdir -p /var/www/wordpress && chown -R nginx:nginx /var/www/wordpress
# cd /var/www/wordpress

# # Attendi che MariaDB sia pronto
# echo "Waiting for MariaDB to be ready..."
# until mysqladmin ping -h"$WORDPRESS_DB_HOST" --silent; do
#     sleep 3
# done
# echo "MariaDB is ready!"


# # Crea wp-config.php manualmente se non esiste
# if [ ! -f "wp-config.php" ]; then
#     wp core download --allow-root

#     # Crea wp-config.php
#     wp config create --allow-root \
#         --dbname="$WORDPRESS_DB_NAME" \
#         --dbuser="$WORDPRESS_DB_USER" \
#         --dbpass="$WORDPRESS_DB_PASSWORD" \
#         --dbhost="$WORDPRESS_DB_HOST"

#     # Aggiungi chiavi di sicurezza nel wp-config.php
#     curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> wp-config.php

#     echo "wp-config.php has been generated successfully."

#     wp core install --allow-root \
#         --url="https://$DOMAIN_NAME/wordpress" \
#         --title="$WP_SITE_TITLE" \
#         --admin_user="$ADMIN_USER" \
#         --admin_password="$ADMIN_PASSWORD" \
#         --admin_email="$ADMIN_EMAIL" \
#         --skip-email

#     # Crea utente aggiuntivo
#     wp user create \
#         "$WP_SECOND_USER" "$WP_SECOND_EMAIL" \
#         --role=author \
#         --user_pass="$WP_SECOND_PASSWORD" \
#         --allow-root || true

#     # Verifica permessi su wp-content
#     chown -R nginx:nginx /var/www/wordpress/wp-content

#     echo "WordPress setup is complete."
# fi

# # Avvia PHP-FPM
# echo "Starting PHP-FPM service..."
# exec php-fpm82 -F








# mkdir -p /var/www/wordpress && chown -R nginx:nginx /var/www/wordpress
# cd /var/www/wordpress

# Attendi che MariaDB sia pronto
echo "Waiting for MariaDB to be ready..."
until mysqladmin -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" ping --silent; do
    sleep 3
done
echo "MariaDB is ready!"


# Scarica WordPress se non è già presente
if [ ! -f "wp-config.php" ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root



# Crea wp-config.php se non esiste
    echo "Creating wp-config.php..."
    wp config create --allow-root \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$WORDPRESS_DB_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST"

    # Aggiungi chiavi di sicurezza nel wp-config.php
    if ! grep -q "AUTH_KEY" wp-config.php; then
        curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> wp-config.php
    fi

    echo "wp-config.php has been generated successfully."

    # Installa WordPress
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

    wp theme install bizboost --activate --allow-root || true
fi

# Controlla che wp-content esista prima di cambiare i permessi
if [ -d "/var/www/html/wordpress/wp-content" ]; then
    chown -R nginx:nginx /var/www/html/wordpress/wp-content
fi

echo "WordPress setup is complete."

# Avvia PHP-FPM
echo "Starting PHP-FPM service..."
exec /usr/sbin/php-fpm82 -F
