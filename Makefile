MARIA_VOLUME = /home/ldi-fior/data/mariadb_data
WORDPRESS_VOLUME = /home/ldi-fior/data/wordpress_data
USER = ldi-fior

# DEVO CAMBIARE I PERCORSI DEI VOLUMI CON POSTI IN CUI NON HO BISOGNO DEL ROOT

all: set-host create-volume up

# Avvio i servizi docker
# Creo i volumi sul mio host se non esistono


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

up:
	docker-compose -f ./srcs/docker-compose.yml up --build



# modifico il file hosts per poter accedere al sito tramite l'indirizzo ldi-fior.42.rm
#
# Cosa sto facendo:
# Attraverso questo comando sto modificando il file hosts del mio sistema operativo
# "creando l'alias" `ldi-fior.42.rm` per l'indirizzo IP 127.0.0.1
#
# Perchè:
# L'indirizzo 127.0.0.1 è l'indirizzo di loopback, che rappresenta il tuo computer stesso. 
# È utilizzato per consentire ai programmi in esecuzione sulla tua macchina di comunicare 
# tra loro senza utilizzare una rete esterna.
# Visto che il server NGINX è in esecuzione come container sul mio host personale, 
# per accedere al sito dovrò inviare una richiesta al mio indirizzo IP di loopback 
# (127.0.0.1) rimappato a "ldi-fior.42.rm"
#
# Accesso locale: Quando accedi a un servizio in esecuzione sul tuo computer, come il server 
# web NGINX che hai configurato nei tuoi container Docker, lo fai tramite questo indirizzo. 
# Usando localhost o 127.0.0.1, stai dicendo al tuo browser di cercare il servizio sul tuo 
# stesso dispositivo.
set-host:
	@echo -e "\033[0;32m--> Setting up hosts file:\033[0m"
	@echo -e "\033[0;32m127.0.0.1 -> ldi-fior.42.rm\033[0m"
	@echo "127.0.0.1 ldi-fior.42.rm" | sudo tee -a /etc/hosts





# === CLEAN ===  

# PROBLEMI:  NON FUNZIONA NIENTE DI QUESTE CLEAN

# Questo comando ferma i container in esecuzione e rimuove i container, le reti create, 
# e i volumi definiti nel file docker-compose.yml.
stop:
	@docker-compose -f ./srcs/docker-compose.yml down
	

# - Se ho container in esecuzione, li stoppo e rimuovo
# - Se ho container fermi, li rimuovo
# - Rimuovo le immagini
# - Rimuovo i volumi (di docker)
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
#	@docker network ls --format "{{.Name}} {{.Driver}}" | \
#	grep -vE '(bridge|host|none)' | \
#	awk '{ print $$1 }' | \
#	xargs -r docker network rm


# Questo comando è utilizzato per ripulire il sistema Docker rimuovendo risorse non utilizzate
# capire cosa mettere qui
prune: clean
	docker system prune -a
	docker container prune 
	docker images -q | xargs -r docker rmi
#aggiunto questo!!!!!!!!!!!!!!!!!!!1
	docker volume prune 


