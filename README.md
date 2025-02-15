# INCEPTION
This project aims to broaden your knowledge of system administration by using Docker. You will virtualize several Docker images, creating them in your new personal virtual machine.

# Sources
- GitHun
  - https://github.com/Forstman1/inception-42 (recommended)
  - https://github.com/shameleon/inception-42?tab=readme-ov-file
  - https://github.com/hel-kame/inception_vagrant (Inception virtual environment)
- Medium
  - https://medium.com/@imyzf/inception-3979046d90a0
  - https://medium.com/@ssterdev/inception-guide-42-project-part-i-7e3af15eb671 (Part 1)
  - https://medium.com/@ssterdev/inception-42-project-part-ii-19a06962cf3b (Part 2)
  - https://medium.com/edureka/docker-networking-1a7d65e89013 (How Containers Communicate)
- Grademe.fr
  - https://tuto.grademe.fr/inception/#nginx
 
# Table of contents
- [What is a Container?](#What_is_a_Container?)
- [What is a Docker Image?](#What_is_a_Docker_Image?)
- [What is a Dockerfile?](#What_is_a_Dockerfile?)
- [What is a Docker Daemon](#What_is_a_Docker_Daemon)
- [Docker Networking](#Docker_Networking) --> VEDERE QUESTO
- [What is a Docker Compose?](#What_is_a_Docker_Compose?)
- [What is a Volume?](#What_is_a_Volume?)
- [Mariadb](#Mariadb)
- [Wordpress + php-fpm](#Wordpress_+_php-fpm)
- [Nginx + TLSv1.2 - TLSv1.3](#Nginx_+_TLSv1.2_TLSv1.3)

<br>
<br>

***
***
# What is a Container?
A container is a lightweight, portable, and self-sufficient environment that packages an application and all its dependencies (libraries, binaries, configuration files) together. It ensures the application runs consistently regardless of the host system or environment.

Containers virtualize at the operating system level instead of the hardware level (as virtual machines do), making them faster and more efficient.

--> Watch this: [NetworkChuck](https://www.youtube.com/watch?v=eGz9DS-aIeY)

<br>
<br>

***


# What is a Docker Image?
Docker Image is a lightweight executable package that includes everything the application needs to run, including the code, runtime environment, system tools, libraries, and dependencies.

Although it cannot guarantee error-free performance, as the behavior of an application ultimately depends on many factors beyond the image itself, using Docker can reduce the likelihood of unexpected errors.

Docker Image is built from a DOCKERFILE, which is a simple text file that contains a set of instructions for building the image, with each instruction creating a new layer in the image.

<br>
<br>

***

# What is a Dockerfile?
Dockerfile is that SIMPLE TEXT FILE that I mentioned earlier, which contains a set of instructions for building a Docker Image. It specifies the base image to use and then includes a series of commands that automate the process for configuring and building the image, such as installing packages, copying files, and setting environment variables. Each command in the Dockerfile creates a new layer in the image.

Here’s an example of a Dockerfile to make things a little bit clear:
```yaml
# This Specifies the base images for the container
# (in this case, it's the 3.14 version of Alpine)
FROM alpine:3.14

# This Run commands in the container shell,
# and installs the specified packages
# (it will install nginx & openssl,
# and will create the directory "/run/nginx" as well)
RUN apk update && \
    apk add nginx openssl && \
    mkdir -p /run/nginx

# This Copies the contents of "./conf/nginx.conf" on the host
# machine to the "/etc/nginx/http.d/"
# directory inside the container
COPY ./conf/nginx.conf /etc/nginx/http.d/default.conf

# This Specifies the command that will run when the container get started
CMD ["nginx", "-g", "daemon off;"]
```


<br>
<br>

***
# What is a Docker Daemon
A daemon is a background process that runs continuously on a computer, typically without direct user interaction. Daemons are often used to handle system tasks, services, or processes that need to operate autonomously in the background.

The Docker daemon, also known as dockerd, is the core background process that runs on a host machine to manage Docker containers and related resources. It acts as the "brain" of Docker, responsible for executing Docker commands and orchestrating all Docker objects such as containers, images, networks, and volumes.

## Key Roles of the Docker Daemon
**Container Management:** <br>
- Creates, starts, stops, and removes containers.
- Handles container lifecycle events (e.g., restarting containers if configured).

**Image Management:** <br>
- Pulls images from Docker registries like Docker Hub.
- Builds and stores images on the host system.

**Network Management:** <br>
- Configures container networks.
- Creates isolated networks for communication between containers.

**API Listener:** <br>
- Listens for requests sent via the Docker CLI or third-party tools using the Docker API.
- Executes the requested operations and returns responses to the client.

**Resource Allocation:** <br>
- Allocates CPU, memory, and other resources to running containers.
- Manages resource isolation using Linux technologies like cgroups and namespaces.

<br>
<br>

***

# Docker Networking
A Docker network is a virtual networking layer that enables communication between Docker containers, the host system, and external systems. Networks allow containers to interact seamlessly while providing isolation and security.

Docker uses several network drivers (types) to cater to different networking needs and scenarios, allowing users to choose the appropriate configuration for their applications.

--> Read this: [Medium](https://medium.com/edureka/docker-networking-1a7d65e89013) <br>
--> Whatc this: [NetworkChuck](https://www.youtube.com/watch?v=bKFMS5C4CG0)


## Purpose of Docker Networks
- **Container Communication**: Facilitate communication between containers.
- **Isolation**: Keep container networks separate to prevent unauthorized access.
- **Flexibility**: Tailor networks to specific applications or environments.
- **Resource Management**: Control resource allocation and traffic management.


## Types of Docker Networks
Docker provides several network drivers, each suited for different use cases. Here are seven types of Docker networks:

### 1. Bridge Network
- **Description:** The default network driver. It creates a private internal network on a single host, allowing containers to communicate with each other while isolating them from external networks.
- **Use Case:** Best suited for applications that require container-to-container communication on the same host.
- **Key Features:**
  - Containers can communicate using their container names as hostnames.
  - Automatic IP address assignment.
- **Example:** Create and run a container in the bridge network:
```bash
docker run -d --name webapp --network bridge nginx
```


### 2. Host Network
- **Description:** This driver removes the isolation between the container and the Docker host, allowing the container to share the host's network stack.
- **Use Case:** Useful for performance-sensitive applications that require high-speed network access or when you need to use specific network features of the host.
- **Key Features:**
  - No network address translation (NAT); the container uses the host's IP address.
  - Containers can bind to ports on the host directly.
- **Example:** Run a container using the host network:
```bash
docker run -d --network host nginx
```


### 3. None Network
- **Description:** This driver disables all networking for the container, isolating it completely.
- **Use Case:** Suitable for containers that do not need network access, such as batch jobs or isolated processes.
- **Key Features:**
  - Containers cannot communicate over the network.
  - Useful for specific security scenarios.
- **Example:** Run a container with no network:
```bash
docker run --network none --name isolated-container alpine
```


### 4. Overlay Network
- **Description:**  Creates a network that spans multiple Docker hosts, allowing containers to communicate across different hosts. This is essential for multi-host deployments in clustered environments.
- **Use Case:** Primarily used in Docker Swarm or Kubernetes setups where containers across different machines need to interact.
- **Key Features:**
  - Uses a built-in overlay driver and requires a key-value store (like etcd or Consul) for service discovery.
  - Provides a consistent and simple networking layer.
- **Example:** Create an overlay network:
```bash
docker network create --driver overlay my-overlay
```


### 5. Macvlan Network
- **Description:** Assigns a MAC address to each container, making them appear as physical devices on the network. This allows for easier integration with existing physical networks.
- **Use Case:**  Useful for applications that require containers to be directly accessible on the local network, such as legacy applications or services requiring a specific MAC address.
- **Key Features:**
  - Containers can be addressed directly via their MAC address.
  - Allows for better integration with VLANs.
- **Example:** Create a Macvlan network:
```bash
docker network create -d macvlan --subnet=192.168.1.0/24 --gateway=192.168.1.1 my-macvlan
```


### 6. IAM Network
- **Description:** This type of network allows containers to communicate securely within the same environment, supporting both public and private IP ranges.
- **Use Case:** Useful for applications that need to manage sensitive data and maintain strict security boundaries.
- **Key Features:**
  - Provides options for public IP ranges and enhanced security.
  - Facilitates seamless integration with existing IAM solutions.


### 7. External Network
- **Description:** Allows you to connect to networks created outside of Docker's control. This can be useful when integrating Docker containers with existing network infrastructure.
- **Use Case:** Best for scenarios where Docker containers need to connect to existing applications or services running outside of Docker.
- **Key Features:**
  - Provides flexibility to connect with pre-existing networks
  - Allows for configuration management of external services.
- **Example:**
```bash
docker run --network <external-network> <image>
```



<br>
<br>

***

# What is a Docker Compose?
Docker Compose is a tool that allows you to define and manage multi-container Docker applications. It uses a YAML file (docker-compose.yml) to configure the services, networks, and volumes needed for your application. With Docker Compose, you can start, stop, and manage all the containers defined in the configuration file with simple commands.

--> Watch this: [NetworkChuck](https://www.youtube.com/watch?v=DM65_JyGxCo)


A Docker Compose has 5 important parts, which are:

## 1. Service Definition
Docker Compose allows you to define multiple services (containers) in a single docker-compose.yml file.

**What is a service?** <br>
A service represents a single container, including all its configuration (e.g., image, ports, environment variables).

**How does it work?** <br>
Each service you define in the docker-compose.yml file corresponds to a container. For example:
```yaml
services:
  app:
    image: myapp:latest
  db:
    image: mysql:latest
```
- The `app` service will create a container from the myapp:latest image.
- The `db` service will create a container from the mysql:latest image.

**Benefit**: <br>
You can define all components of your application (like a web server, database, and caching layer) in one place. This ensures the components run together smoothly.


## 2. Networking
Docker Compose automatically sets up a default network for your services to communicate with each other without any manual configuration.

**Default network**: <br>
Compose creates an isolated network for your application, ensuring the services can communicate securely.

**Service communication**: <br>
Services can reference each other by name. For instance:
```yaml
services:
  web:
    image: nginx:latest
  db:
    image: postgres:latest
```
- The `web` service can connect to the `db` service using db as the hostname.

**Benefit**: <br>
No need to manually set up or configure IPs or network links—Compose handles it automatically.


## 3. Volume Management
Compose makes it easy to **define and share volumes** between services for persistent data storage.

**What is a volume?** <br>
A volume stores data that persists even if the container is stopped or restarted.

**How to configure volumes:** <br>
In the docker-compose.yml file:

```yaml
services:
  db:
    image: postgres:latest
    volumes:
      - db_data:/var/lib/postgresql/data
volumes:
  db_data:
```
- The db_data volume will store database files persistently.

**Benefit**: <br>
Ensures data (e.g., databases or user files) is not lost when containers are restarted.


## 4. Scaling
Docker Compose makes it easy to scale services up or down with a single command.

**How does scaling work?** <br>
You can specify the number of container instances (replicas) for a service. For example:
```bash
docker-compose up --scale web=3
```

## 5. Multi-environment Deployment
Compose allows you to easily configure environments like development, staging, or production.

**Environment-specific configuration:** <br>
Use override files or environment files to define different settings. For example:<br>
`docker-compose.override.yml`:
```yaml
services:
  web:
    build:
      context: .
      args:
        ENV: development
```

**Environment variables:** <br>
You can load environment-specific variables from a .env file:
```yaml
services:
  app:
    image: myapp:latest
    environment:
      - ENV=${APP_ENV}
```

Define the value in a .env file:
```bash
APP_ENV=production
```

**Benefit**: <br>
Simplifies deployment by allowing the same docker-compose.yml to be reused across environments.

<br>

# Example
Here’s an example of a Docker Compose to make things a little bit clear:
```yaml
version: '3'

# All the services that you will work with should be declared under
# the SERVICES section!
services:

  # Name of the first service (for example: nginx)
  nginx:
  
    # The hostname of the service (will be the same as the service name!)
    hostname: nginx
    
    # Where the service exist (path) so you can build it (using a Dockerfile)
    build:
      context: ./requirements/nginx
      dockerfile: Dockerfile
      
    # Restart to always keep the service restarting in case of
    # any unexpected errors causing it to go down
    restart: always
    
    # This line explains itself!!!
    depends_on:
      - wordpress
      
    # The ports that will be exposed and you will work with
    ports:
      - 443:443
      
    # The volumes that you will be mounted when the container gets built
    volumes:
      - wordpress:/var/www/html
      
    # The networks that the container will connect and communicate
    # with the other containers
    networks:
      - web

  # Name of the second service (for example: db)
  db:
    etc...
```
- `version`: Specifies the version of the Docker Compose file format.
- `services`: Lists the containers to be run. Each service has its own configuration:
- `volumes`: Specifies volumes for persistent storage.

<br>
<br>

***

# What is a Volume?
In Docker, a volume is a persistent storage location that is used to store data from a container. Volumes are used to persist data from a container even after the container is deleted, and they can be shared between containers.

There are two types of volumes in Docker:

- **Bind mount**: A bind mount is a file or directory on the host machine that is mounted into a container. Any changes made to the bind mount are reflected on the host machine and in any other containers that mount the same file or directory.<br>
- **Named volume**: A named volume is a managed volume that is created and managed by Docker. It is stored in a specific location on the host machine, and it is not tied to a specific file or directory on the host. Named volumes are useful for storing data that needs to be shared between containers, as they can be easily attached and detached from containers.<br>

You can create and manage volumes using the docker volume command. For example, to create a new named volume, you can use the following command:
```bash
docker volume create my-volume
```
This command creates a Docker volume named my-volume in a directory on the host.

- Volumes are used for persistent data storage in Docker.
- The data stored in the volume will remain even if the container using it is removed.
- This command only creates the volume; **it doesn't attach it to any container**.
- By default, Docker stores volumes in a directory on the host, typically:
  - Linux: /var/lib/docker/volumes/

you can inspect the volume's details, including its location on the host, using:
```bash
docker volume inspect my-volume
```
<br>

To mount a volume into a container, you can use the -v flag when starting the container. For example:
```bash
docker run -v my-volume:/var/lib/mysql mysql
```
This command will start a container running the mysql image and mount the my-volume volume at /var/lib/mysql in the container. Any data written to this location in the container will be persisted in the volume, even if the container is deleted. 
<br>
<br>

You can also use Docker Compose to create and manage volumes. In a Compose file, you can define a volume and attach it to a service. For example:
```yaml
version: '3'
services:
  db:
    image: mysql
    volumes:
      - db-data:/var/lib/mysql
volumes:
  db-data:
```
This Compose file defines a db-data volume and attaches it to the db service at /var/lib/mysql. Any data written to this location in the container will be persisted in the volume.


<br>
<br>

***
# Mariadb
MariaDB is an open-source relational database management system (RDBMS) that is a fork of MySQL. It was created by the original developers of MySQL after concerns arose about the acquisition of MySQL by Oracle Corporation. MariaDB aims to remain open-source and provide better performance, reliability, and compatibility.

### Common Use Case
- **Web Applications**: Frequently used in web development stacks (e.g., LAMP/LEMP).
- **Enterprise Systems**: Provides reliability for handling large-scale data in enterprise environments.
- **Data Warehousing**: Supports analytical workloads with advanced query optimizations.

<br>

**RDBMS** <br>
A **Relational Database Management System (RDBMS)** is software that manages and organizes data stored in a relational database. It follows the relational model, where data is structured into tables (also called relations) that are logically connected to one another.
- A table represents a collection of related data.
- It consists of rows (records) and columns (attributes or fields).

Example:
```sql
Employees Table
+----+--------+---------+
| ID | Name   | Role    |
+----+--------+---------+
| 1  | Alice  | Manager |
| 2  | Bob    | Engineer|
+----+--------+---------+
``` 

<br>

**MySQL** <br>
**MySQL** is a popular Relational Database Management System (RDBMS) that is used to store, manage, and retrieve structured data. It is open-source, free to use, and supports the **SQL** (Structured Query Language) standard for database operations. MySQL is developed and maintained by Oracle Corporation.

<br>

**LAMP** <br>
LAMP is a software stack used for web application development. The name is an acronym for the technologies it comprises:

- Linux: The operating system that serves as the foundation.
- Apache: A widely-used web server for hosting websites.
- MySQL: The database management system for storing application data (or MariaDB as a common alternative).
- PHP (or Perl/Python): The programming language for creating dynamic web content.

Example Use Case:
A LAMP stack might power a blog where:

- Linux runs the server.
- Apache delivers the blog pages to visitors.
- MySQL stores blog posts, user comments, and metadata.
- PHP generates the blog pages dynamically based on the stored data.

<br>

**LEMP** <br>
LEMP is a variation of the LAMP stack that replaces Apache with Nginx (pronounced "Engine-X"). The acronym stands for:

- Linux: The operating system.
- Engine-X (Nginx): A high-performance web server and reverse proxy.
- MySQL: The database (or MariaDB as an alternative).
- PHP (or Perl/Python): The programming language for server-side scripting.

<br>
<br>

***
# Wordpress + php-fpm
WordPress is a content management system (CMS) based on PHP and MySQL. It is an open-source platform that is widely used for building websites, blogs, and applications. With WordPress, users can easily create and manage their own websites without the need for advanced technical skills. 

### FastCGI 
FastCGI is a protocol that allows web servers to communicate with web applications, such as PHP scripts. It is designed to allow web servers to execute scripts in a more efficient way than traditional CGI (Common Gateway Interface) protocols, which involve starting a new process to execute each script.

**How FastCGI Works** <br>
- Separation of Concerns
  - FastCGI separates the web server from the application logic, allowing each to focus on its strengths.
  - The web server handles HTTP requests, while the FastCGI process (or application server) executes application code.

- Persistent Processes
  - Unlike CGI, which starts a new process for every request, FastCGI maintains persistent processes.
  - These processes handle multiple requests, reducing the overhead of repeatedly starting and stopping processes.

- Communication
  - The web server forwards client requests to the FastCGI server over a network or Unix socket.
  - FastCGI processes the request and sends the response (e.g., HTML) back to the web server.


### PHP-FPM
PHP-FPM (FastCGI Process Manager) is an implementation of the FastCGI protocol specifically designed for use with PHP. It works by starting a pool of worker processes that are responsible for executing PHP scripts. When a web server receives a request for a PHP script, it passes the request to one of the worker processes, which then executes the script and returns the result to the web server. This allows PHP scripts to be executed more efficiently, as the worker processes can be reused for multiple requests.
It is widely used in conjunction with web servers like Nginx or Apache to process PHP requests efficiently.

**How FastCGI Works** <br>
- Web Server Interaction
  - When a web server (e.g., Nginx) receives a PHP request, it forwards the request to PHP-FPM.
  - PHP-FPM processes the PHP code and sends the generated HTML back to the web server, which then delivers it to the user.

- FastCGI Communication
  - PHP-FPM uses the FastCGI protocol to communicate with the web server, ensuring efficient handling of requests.

- Socket or Port Binding
  - PHP-FPM listens on a Unix socket (/run/php/php7.4-fpm.sock) or a TCP port (127.0.0.1:9000) for incoming requests.

<br>
<br>

***
# Nginx + TLSv1.2 - TLSv1.3
NGINX is a web server that can also be used as a reverse proxy, load balancer, and HTTP cache. It is known for its high performance, stability, and low resource consumption. NGINX is often used to handle server-side requests for web applications, and it can also be used to serve static content such as images and JavaScript files.

It is often used in conjunction with other software, such as databases and content management systems, to build robust and scalable web applications. <br>

A **web server** is a software or hardware system that serves content (web pages, files, images, etc.) to users over the Internet. It processes incoming requests from clients (usually web browsers) and delivers the requested resources using the HTTP (Hypertext Transfer Protocol) or HTTPS (HTTP Secure) protocol.


### Key Features of Nginx
**1. Web Server** <br>
Nginx can serve static content such as HTML, CSS, JavaScript, and images efficiently. It uses an event-driven architecture, which makes it faster and more resource-efficient than traditional web servers like Apache.<br>

**2. Reverse Proxy** <br>
Nginx can act as a reverse proxy, sitting between clients and backend servers, forwarding client requests to the appropriate backend server. This setup improves security, hides the backend server details, and allows for load balancing.<br>

**3. Load Balancing** <br>
It distributes incoming client requests across multiple backend servers to ensure no single server is overwhelmed, enhancing performance and reliability.<br>

**4. Caching** <br>
Nginx can cache responses from backend servers, reducing the load on those servers and improving response times for users.<br>

**5. Media Streaming** <br>
Supports real-time streaming of audio and video using protocols like HLS (HTTP Live Streaming) and RTMP (Real-Time Messaging Protocol).<br>

**6. Security** <br>
It provides features like:
- SSL/TLS termination
- IP whitelisting/blacklisting
- Rate limiting to prevent DDoS attacks<br>

**7. Highly Scalable Architecture** <br>
Nginx’s non-blocking, event-driven design allows it to handle large numbers of concurrent connections with minimal hardware resources.<br>

## TLS
Transport Layer Security (TLS) is a cryptographic protocol designed to provide secure communication over a computer network. It is widely used on the internet to secure data transmitted between clients (like web browsers) and servers (like web servers). TLS ensures confidentiality, data integrity, and authentication, making it essential for protecting sensitive information during transmission.

TLS works by using public key encryption to establish a secure connection between two parties. When a client wants to communicate with a server using TLS, the client and server exchange a series of messages to establish a secure connection. This process includes the exchange of digital certificates and the negotiation of encryption keys. Once the connection is established, the client and server can communicate securely over the internet. <br>

### Key Objectives of TLS
- Confidentiality:
  - Encrypts data exchanged between clients and servers to prevent unauthorized access.
  - Only the intended recipient can decrypt and read the data.

- Data Integrity:
  - Ensures that data is not altered during transmission. Any modification of data can be detected.
  - Uses cryptographic checksums (hash functions) to verify the integrity of the transmitted data.

- Authentication:
  - Confirms the identity of the parties involved in the communication, ensuring that clients are communicating with legitimate servers.
  - Typically achieved through digital certificates issued by trusted Certificate Authorities (CAs).


### Use Cases for TLS
- Web Browsing: Securing HTTP traffic to create HTTPS (HTTP over TLS), ensuring that data sent between the browser and server is encrypted.
- Email: Securing email communications through protocols like SMTPS (SMTP over TLS), IMAPS (IMAP over TLS), and POP3S (POP3 over TLS).
- VoIP: Securing voice communications over the Internet Protocol using TLS.
Messaging: Securing messaging applications and APIs to protect user data. <br> <br>

## OpenSSL
OpenSSL is an open-source software library that provides a robust set of tools and libraries for implementing cryptographic functions and protocols, including TLS and SSL (Secure Sockets Layer). It is widely used for securing communications over networks, especially on the Internet.

OpenSSL can be used for a variety of tasks related to SSL and TLS, including:

- Creating and managing SSL/TLS certificates and private keys
- Setting up and configuring SSL/TLS-enabled servers
- Connecting to SSL/TLS-enabled servers as a client
- Debugging SSL/TLS connections
- Generating and signing digital certificates

<br>
<br>

***
***
# Usefull Command - Docker 
## 1. containers
- Pull an immage from docker hub
```bash
docker pull <img>
```
- This command runs a command in a new container, pulling the image if needed and starting the container.
```bash
docker run <img-name>
```
- Delete an immage. Use `-f` after `rmi` if needed
```bash
docker rmi  <img-name>
```

- remove all stopped containers
```bash
docker container prune [OPTIONS]
```

## 2. Networks
- Create a Network
```bash
docker network create <network-name>
```

- List Networks
```bash
docker network ls
```

- Inspect a Network
```bash
docker network inspect <network-name>
```

- Remove a Network
```bash
docker network rm <network-name>
```

- Connect a Container to a Network
```bash
docker network connect <network-name> <container-name>
```

- Disconnect a Container from a Network
```bash
docker network disconnect <network-name> <container-name>
```


## 3. Volums
- This command creates a Docker volume named my-volume in a directory on the host.
```bash
docker volume create my-volume
```

- Mount a volume into a container
```bash
docker run -v my-volume:/var/lib/mysql mysql
```

<br>

***
# Usefull Command - Docker Compose
**Start Services:**
```bash
docker-compose up
```
Use `-d` for detached mode:


**Stop Services:**
```bash
docker-compose down
```


**View Logs:**
```bash
docker-compose logs
```


**Scale a Service:**
```bash
docker-compose up --scale web=3
```


**Rebuild Services:**
```bash
docker-compose up --build
```
