# Macro per la creazione di volumi e user
MARIA_VOLUME = /home/ldi-fior/data/mariadb_data
WORDPRESS_VOLUME = /home/ldi-fior/data/wordpress_data
USER = ldi-fior


all: set-host create-volume up


# create-volume target: crea i volumi necessari per MariaDB e WordPress.
# Controlla se le directory dei volumi non esistono già.
# Se non esistono, le crea, imposta i permessi a 777 e stampa un messaggio di conferma.
create-volume:
	@if [ ! -d $(MARIA_VOLUME) ]; then \
		mkdir -p $(MARIA_VOLUME); \
		echo -e "\033[0;32m--> Mariadb Volume created in: $(MARIA_VOLUME)\033[0m"; \
		chmod 777 $(MARIA_VOLUME); \
	fi

	@if [ ! -d $(WORDPRESS_VOLUME) ]; then \
		mkdir -p $(WORDPRESS_VOLUME); \
		echo -e "\033[0;32m--> WordPress Volume created in: $(WORDPRESS_VOLUME)\033[0m"; \
		chmod 777 $(WORDPRESS_VOLUME); \
	fi
	@echo -e "\033[0;32m--> STARTING DOCKER SERVICES:\033[0m"		


# up target: Avvia i servizi Docker utilizzando docker-compose.
# L'opzione --build nel comando docker-compose up forza la ricostruzione 
# delle immagini Docker definite nel file docker-compose.yml prima di avviare i servizi. 
# Questo significa che Docker ricostruirà le immagini anche se sono già presenti, 
# assicurandosi che eventuali modifiche apportate ai Dockerfile o al contesto di 
# build siano incluse nelle immagini utilizzate per avviare i container.
up:
	docker-compose -f ./srcs/docker-compose.yml up --build



# modifico il file hosts per poter accedere al sito tramite l'indirizzo ldi-fior.42.rm
#
# Cosa sto facendo:
# Attraverso questo comando sto modificando il file hosts del mio sistema operativo
# "creando l'alias" `ldi-fior.42.rm` per l'indirizzo IP 127.0.0.1
#
# Perchè:
# L'indirizzo 127.0.0.1 è l'indirizzo di loopback, che rappresenta il mio stesso computer. 
# È utilizzato per consentire ai programmi in esecuzione sulla macchina di comunicare 
# tra loro senza utilizzare una rete esterna.
# Visto che il server NGINX è in esecuzione come container sul mio host personale, 
# per accedere al sito dovrò inviare una richiesta al mio indirizzo IP di loopback 
# (127.0.0.1) rimappato a "ldi-fior.42.rm"
set-host:
	@echo -e "\033[0;32m--> Setting up hosts file:\033[0m"
	@echo -e "\033[0;32m127.0.0.1 -> ldi-fior.42.rm\033[0m"
	@echo "127.0.0.1 ldi-fior.42.rm" | sudo tee -a /etc/hosts





# down target: Ferma e rimuove i container, le reti, i volumi e le immagini create 
# dai servizi definiti nel file docker-compose.yml.
down:
	@docker-compose -f ./srcs/docker-compose.yml down
	

# clean target:
# - Se ci sono container in esecuzione, li ferma.
# - Se ci sono container fermi, li rimuove.
# - Rimuove tutte le immagini Docker.
# - Rimuove tutti i volumi Docker.
# - Rimuove la voce specifica dal file hosts.
# - Rimuove tutti i dati nella directory specificata.
# - Esegue una pulizia completa del sistema Docker, rimuovendo tutte le risorse inutilizzate.
clean:
	@if [ -n "$$(docker ps -q)" ]; then \
		docker container stop $$(docker ps -q); \
	fi
	@if [ -n "$$(docker ps -aq)" ]; then \
		docker rm $$(docker ps -aq); \
	fi
	@if [ -n "$$(docker images -q)" ]; then \
		docker rmi -f $$(docker images -q); \
	fi
	@if [ -n "$$(docker volume ls -q)" ]; then \
		docker volume rm $$(docker volume ls -q); \
	fi
	@sudo sed -i '/127\.0\.0\.1 ldi-fior\.42\.rm/d' /etc/hosts
	@sudo rm -rf /home/$(USER)/data/*
	@docker system prune -a -f



