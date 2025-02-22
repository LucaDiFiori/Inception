FROM alpine:3.20.5

RUN apk update && apk upgrade && apk add --no-cache \
    php82 \
    # php82-fpm è un gestore di processi FastCGI per PHP. Cioè sto installanto PHP-FMP
    php82-fpm \ 
    php82-mysqli \
    php82-json \
    php82-curl \
    php82-dom \
    php82-exif \
    php82-fileinfo \
    php82-mbstring \
    php82-openssl \
    php82-xml \
    php82-zip \
    php82-phar \
    php82-gd \
    php82-iconv \
    php82-pdo \
    php82-pdo_mysql \
    php82-session \
    php82-simplexml \
    php82-tokenizer \
    wget \
    curl \
    mariadb-client

# crea un link simbolico che permette di eseguire php82 utilizzando semplicemente il comando php. 
# Questo è utile per garantire che gli script e i comandi che si aspettano di trovare php 
# nel percorso predefinito funzionino correttamente con la versione specifica di PHP installata
RUN ln -sf /usr/bin/php82 /usr/bin/php

# creazione utente e gruppo nginx
# Verranno utilizzati per eseguire il server web Nginx e per gestire i file e le directory serviti dal server
# Eseguire il server web Nginx con un utente non privilegiato (non root) riduce il rischio di compromissione 
# del sistema. Se un attaccante riesce a sfruttare una vulnerabilità nel server web, 
# avrà accesso limitato al sistema, poiché l'utente nginx ha permessi limitati rispetto all'utente root.
#
# Specificherò poi l'uso di questo utente e gruppo per eseguire il server web nel file di configurazione di Nginx (www.conf)
RUN adduser -S nginx && addgroup -S nginx
    
# Copia il file di configurazione di PHP-FPM
COPY tools/www.conf /etc/php82/php-fpm.d/www.conf
   
# Scarichiamo lo strumento WP-CLI (WordPress Command Line Interface) per
# configurare e gestire il sito WordPress da riga di comando.
# Questo strumento semplifica questa operazione, incluso il settaggio del
# file di configurazione wp-config.php.
#
# WordPress infatti necessita di dettagli del database (nome, utente, password e host) 
# per potersi connettere. Queste informazioni vengono solitamente 
# definite nel file wp-config.php. Se non configurate, quando accedi 
# al sito verrai reindirizzato alla pagina di configurazione guidata di WordPress
#
# Dopo aver scaricato wp-cli, lo rendiamo eseguibile e lo spostiamo nella directory /usr/local/bin
# per usarlo facilmmente con il comando wp (comando principale di wp-cli)
# senza dover specificare il percorso dove è installato
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Impostiamo la directory di lavoro in /var/www/html/wordpress
WORKDIR /var/www/html/wordpress

# copia script di configurazione di wp
COPY tools/wp-config.sh /usr/local/bin/

# rendi eseguibile lo script
RUN chmod +x /usr/local/bin/wp-config.sh

# CAPIRE SE VA RIMESSO OPPURE NO: RUNNARE COSI E VEDERE SE FUNZIONA, ALTRIMENTI RIMETTERLO <-------
# RUN echo "memory_limit = 512M" >> /etc/php82/php.ini

# Usare ENTRYPOINT garantisce che il comportamento desiderato (configurare WordPress 
# e avviare il server PHP) venga sempre eseguito ogni volta che il container viene avviato, 
# indipendentemente da eventuali comandi aggiuntivi forniti.
ENTRYPOINT ["/bin/sh", "/usr/local/bin/wp-config.sh"]

