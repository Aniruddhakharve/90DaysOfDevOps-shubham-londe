# Day 37 – Docker Revision & Cheat Sheet

## Overview

Day 37 is a dedicated Docker revision day covering the concepts and hands-on work completed during Days 29–36.

The goal is to make Docker concepts easier to recall during daily practice, troubleshooting, and DevOps interviews.

---

# Part 1 – Self-Assessment

| Topic | Status | Notes |
|---|---|---|
| Run a container from Docker Hub | 🟢 Can do | Practiced interactive and detached containers |
| List, stop, and remove containers | 🟢 Can do | `docker ps`, `docker stop`, `docker rm` |
| Manage Docker images | 🟢 Can do | Build, tag, pull, push, inspect, remove |
| Image layers and caching | 🟢 Can do | Practiced Docker build cache hands-on |
| Write a Dockerfile | 🟢 Can do | Practiced `FROM`, `RUN`, `COPY`, `WORKDIR`, `CMD` |
| CMD vs ENTRYPOINT | 🟢 Can do | Practiced behavior with custom commands |
| Build and tag custom images | 🟢 Can do | Used multiple image tags |
| Named volumes | 🟢 Can do | Practiced database persistence |
| Bind mounts | 🟢 Can do | Practiced host-to-container file mounting |
| Custom Docker networks | 🟢 Can do | Practiced container communication and DNS |
| Docker Compose | 🟢 Can do | Built multi-container applications |
| `.env` and environment variables | 🟢 Can do | Practiced with Compose |
| Multi-stage Docker builds | 🟢 Can do | Used Maven builder + runtime stage |
| Docker Hub | 🟢 Can do | Pushed versioned images |
| Healthchecks and `depends_on` | 🟢 Can do | Used in Compose |
| `jlink` Java runtime optimization | 🟡 Shaky | Concept understood during Day 36; needs more repetition |

---

# Part 2 – Quick-Fire Questions

## Q1. What is the difference between an image and a container?

### Answer

A Docker image is an immutable template containing the application, dependencies, files, and configuration required to create a container.

A container is a running or stopped instance created from an image.

```text
Docker Image
     │
     │ docker run
     ▼
Docker Container
```

Example:

```bash
docker pull nginx
docker run -d --name web nginx
```

Here:

- `nginx` is the image.
- `web` is the container created from that image.

---

## Q2. What happens to data inside a container when you remove it?

Data written only to the container's writable layer is lost when the container is removed.

For persistent data, use a Docker volume or another persistent storage mechanism.

```text
Container
    │
    ├── Writable layer
    │       ↓
    │    removed with container
    │
    └── Named volume
            ↓
       survives container removal
```

Example:

```bash
docker volume create postgres-data
```

A database should normally use persistent storage.

---

## Q3. How do two containers on the same custom network communicate?

Containers connected to the same user-defined Docker network can communicate using container or service names.

Docker provides DNS-based name resolution on user-defined networks.

Example:

```text
three-tier-network
        │
        ├── java-app
        │
        └── postgres
```

The Java application can connect using:

```text
postgres
```

instead of depending on a hard-coded container IP.

This is important because container IP addresses can change.

---

## Q4. What is the difference between `docker compose down` and `docker compose down -v`?

### `docker compose down`

Removes the Compose project's:

- Containers
- Compose-managed networks

It normally preserves named volumes.

```bash
docker compose down
```

### `docker compose down -v`

Also removes Compose-managed volumes.

```bash
docker compose down -v
```

Therefore, if PostgreSQL data is stored in a Compose-managed named volume:

```text
docker compose down
        ↓
volume remains
        ↓
data remains
```

Whereas:

```text
docker compose down -v
        ↓
volume removed
        ↓
database data removed
```

`-v` does not mean "delete every Docker volume on the machine."

---

## Q5. Why are multi-stage Docker builds useful?

Multi-stage builds separate the build environment from the runtime environment.

For example, our Day 36 Java application used:

```text
Stage 1
────────────────────
Maven
JDK
Source code
Dependencies
Build tools
       │
       │ Maven
       ▼
    app.war
```

Then:

```text
Stage 2
────────────────────
Debian Slim
Tomcat
Minimal Java runtime
app.war
Non-root user
```

The final image does not need:

```text
Maven
Java compiler
Source code
Build dependencies
```

This reduces image size and removes unnecessary build tools from the runtime environment, reducing the attack surface.

---

## Q6. What is the difference between `COPY` and `ADD`?

### COPY

Used for straightforward copying of files/directories into an image.

```dockerfile
COPY source/test.txt /app/
```

It can also copy files from another build stage:

```dockerfile
COPY --from=builder /build/target/app.war /opt/tomcat/webapps/ROOT.war
```

### ADD

`ADD` also copies files but provides additional behavior, such as automatic extraction of local tar archives and URL sources.

Example:

```dockerfile
ADD app.tar.gz /app/
```

For normal file copying, `COPY` is generally preferred because it is explicit and predictable.

### Easy memory trick

```text
COPY = straightforward copying

ADD = COPY + additional features
```

---

## Q7. What does `-p 8080:80` mean?

```bash
docker run -p 8080:80 nginx
```

means:

```text
Host machine              Container
     :8080  ───────────────>  :80
```

- `8080` = host port
- `80` = container port
- `-p` = publish/map the port

Therefore:

```text
http://localhost:8080
```

can reach the service listening on port `80` inside the container.

---

## Q8. How do you check how much disk space Docker is using?

Use:

```bash
docker system df
```

It shows Docker disk usage for areas such as:

- Images
- Containers
- Local volumes
- Build cache

For more detailed information:

```bash
docker system df -v
```

---

# Part 3 – Docker Image Layers & Build Cache

Docker builds images in layers corresponding to Dockerfile instructions.

Example:

```dockerfile
FROM alpine:3.22

RUN echo "Installing application dependencies..."

RUN echo "Setting up application..."

COPY app.txt /app/app.txt

CMD ["cat", "/app/app.txt"]
```

Conceptually:

```text
Layer 1
FROM alpine

Layer 2
RUN install...

Layer 3
RUN setup...

Layer 4
COPY app.txt

Container configuration
CMD
```

When the same Dockerfile is built again without changes, Docker can reuse cached layers.

Example:

```text
FROM       → CACHED
RUN        → CACHED
RUN        → CACHED
COPY       → CACHED
```

If `app.txt` changes:

```text
FROM       → CACHED
RUN        → CACHED
RUN        → CACHED
COPY       → REBUILT
```

If a layer changes, subsequent layers may also need to be rebuilt.

---

# Part 4 – Why Dockerfile Order Matters

Consider:

```dockerfile
FROM ubuntu:24.04

COPY . /app

RUN apt-get update && apt-get install -y python3

CMD ["python3", "/app/app.py"]
```

If only `app.py` changes:

```text
FROM
 ↓
CACHED

COPY
 ↓
CHANGED

RUN apt-get install
 ↓
REBUILT
```

The `RUN` instruction is rebuilt because it comes after the changed `COPY` layer.

A better order is:

```dockerfile
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y python3

COPY . /app

CMD ["python3", "/app/app.py"]
```

Now a change to application source code does not invalidate the earlier dependency installation layer.

### General rule

Put:

```text
Rarely changing instructions
        ↓
Frequently changing instructions
```

For example:

```text
FROM
System packages
Application dependencies
Source code
```

---

# Part 5 – Day 36 Java Dockerfile Caching Example

Our Day 36 Dockerfile used:

```dockerfile
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
```

This ordering was intentional.

`pom.xml` and dependencies generally change less frequently than Java source code.

Therefore, when source code changes:

```text
COPY pom.xml
      ↓
CACHED

Maven dependencies
      ↓
CACHED

COPY src
      ↓
REBUILT
```

This avoids unnecessarily repeating dependency setup.

---

# Part 6 – Multi-Stage Java Build Revision

Our Day 36 application was a Java web application packaged as a WAR.

The overall flow is:

```text
Java Source Code
       │
       ▼
     Maven
       │
       ├── Downloads dependencies
       ├── Compiles Java source
       └── Packages application
       │
       ▼
    app.war
       │
       ▼
    Tomcat
       │
       ▼
Running Java Web Application
       │
       │ JDBC
       ▼
   PostgreSQL
```

---

## Stage 1 – Build

The builder image:

```dockerfile
FROM maven:3.9-eclipse-temurin-11 AS builder
```

contains:

```text
Maven
+
Java 11
+
Build tools
```

Then:

```dockerfile
WORKDIR /build
```

sets the working directory.

```dockerfile
COPY pom.xml .
```

copies Maven's project configuration.

```dockerfile
COPY src ./src
```

copies the Java application source code.

Then:

```dockerfile
RUN mvn dependency:go-offline && mvn clean package -DskipTests
```

downloads dependencies and builds the WAR.

The result is:

```text
/build/target/app.war
```

---

# Part 7 – WAR and Tomcat

WAR means:

```text
Web Application Archive
```

The WAR contains the packaged Java web application, compiled classes, dependencies, and web resources.

Tomcat is the servlet container/application server that runs the Java web application.

The final runtime looks like:

```text
Tomcat
   │
   └── ROOT.war
          │
          ├── HealthServlet
          ├── UserServlet
          ├── DatabaseConnection
          └── Application resources
```

Naming the application:

```text
ROOT.war
```

allows the application to run at the root URL:

```text
http://localhost:8080/
```

rather than:

```text
http://localhost:8080/app/
```

---

# Part 8 – jlink Revision

A normal Java JDK contains many modules and development components that may not be required by an application at runtime.

`jlink` creates a custom Java runtime containing only the required Java modules.

Conceptually:

```text
Full JDK
   │
   │ jlink
   ▼
Required Java modules only
```

Our Dockerfile used modules such as:

```text
java.base
java.logging
java.management
java.naming
java.sql
java.xml
java.desktop
java.security.jgss
java.instrument
jdk.crypto.ec
jdk.unsupported
```

It also used:

```text
--strip-debug
--no-man-pages
--no-header-files
--compress=2
```

to reduce the runtime.

The custom runtime was created at:

```text
/opt/java-minimal
```

---

# Part 9 – Final Runtime Stage

The runtime stage starts with:

```dockerfile
FROM debian:bookworm-slim
```

It then installs only the required runtime utilities and Tomcat.

The custom Java runtime is copied from the builder:

```dockerfile
COPY --from=builder /opt/java-minimal ${JAVA_HOME}
```

The WAR is also copied from the builder:

```dockerfile
COPY --from=builder /build/target/app.war ${CATALINA_HOME}/webapps/ROOT.war
```

The final runtime contains approximately:

```text
Debian Slim
     +
Tomcat
     +
Minimal Java Runtime
     +
app.war
```

It does not contain the complete Maven build environment.

---

# Part 10 – Non-Root Runtime

The Dockerfile creates a dedicated user:

```dockerfile
groupadd --system tomcat
useradd --system --gid tomcat --home-dir ${CATALINA_HOME} tomcat
```

Ownership is assigned:

```dockerfile
chown -R tomcat:tomcat ${CATALINA_HOME}
```

Then:

```dockerfile
USER tomcat
```

makes the container run as the `tomcat` user instead of root.

This is a security best practice.

---

# Part 11 – Day 36 Image Optimization

The initial image was approximately:

```text
~209 MB
```

The optimized `jlink` image was approximately:

```text
~81 MB
```

The optimization combined:

```text
Multi-stage build
        +
jlink custom Java runtime
        +
Debian Slim
        +
Removal of unnecessary Tomcat webapps
        +
Removal of package/cache files
        +
Non-root runtime
```

Result:

```text
~209 MB
    ↓
~81 MB
```

The important distinction is:

```text
Multi-stage build
    ↓
removes build-time environment

jlink
    ↓
removes unnecessary Java runtime modules
```

They solve different problems and work well together.

---

# Part 12 – Docker Networking Revision

List networks:

```bash
docker network ls
```

Inspect a network:

```bash
docker network inspect NETWORK_NAME
```

Create a custom network:

```bash
docker network create my-app-net
```

Run a container on it:

```bash
docker run -d --name app --network my-app-net nginx
```

Connect an existing container:

```bash
docker network connect my-app-net container-name
```

On a user-defined network, containers can communicate using their names.

Example:

```text
app container
     │
     │ postgres
     ▼
PostgreSQL container
```

Docker's embedded DNS resolves the name.

---

# Part 13 – Docker Volumes Revision

Create:

```bash
docker volume create my-volume
```

List:

```bash
docker volume ls
```

Inspect:

```bash
docker volume inspect my-volume
```

Use:

```bash
docker run -v my-volume:/data nginx
```

Remove:

```bash
docker volume rm my-volume
```

Volumes are useful for persistent data such as databases.

---

# Part 14 – Bind Mount Revision

Bind mount:

```bash
docker run \
  -v /host/path:/container/path \
  nginx
```

A bind mount maps an explicit host filesystem directory into the container.

Example:

```text
Host
/website/index.html
       │
       │ bind mount
       ▼
Container
/usr/share/nginx/html/index.html
```

A change made on the host can immediately be reflected inside the container.

---

# Part 15 – Docker Compose Revision

Start services:

```bash
docker compose up
```

Detached mode:

```bash
docker compose up -d
```

Build and start:

```bash
docker compose up --build
```

Stop/remove Compose resources:

```bash
docker compose down
```

Remove volumes too:

```bash
docker compose down -v
```

List services:

```bash
docker compose ps
```

View all logs:

```bash
docker compose logs
```

Follow logs:

```bash
docker compose logs -f
```

View a specific service:

```bash
docker compose logs web
```

Build images:

```bash
docker compose build
```

Scale a service:

```bash
docker compose up --scale web=3
```

---

# Part 16 – Docker Compose Concepts

Compose automatically creates a project network unless explicitly configured otherwise.

Services can communicate using their service names.

Example:

```yaml
services:
  app:
    build: ./app

  db:
    image: postgres:15
```

The application can use:

```text
db
```

as the database hostname.

This is preferable to hard-coding a container IP.

---

# Part 17 – Environment Variables

Environment variables can be specified directly:

```yaml
environment:
  DB_HOST: db
  DB_NAME: appdb
```

Or referenced from `.env`:

```text
DB_NAME=appdb
DB_USER=appuser
DB_PASSWORD=secret
```

Compose:

```yaml
environment:
  POSTGRES_DB: ${DB_NAME}
  POSTGRES_USER: ${DB_USER}
  POSTGRES_PASSWORD: ${DB_PASSWORD}
```

Avoid committing real secrets into Git repositories.

---

# Part 18 – Docker Healthchecks

A healthcheck determines whether a containerized service is actually ready/healthy.

Example:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U appuser -d appdb"]
  interval: 10s
  timeout: 5s
  retries: 5
```

This is different from simply checking whether the container process has started.

---

# Part 19 – `depends_on`

Basic:

```yaml
depends_on:
  - db
```

This controls service startup ordering but does not necessarily mean the database is ready to accept connections.

With healthchecks, Compose can use:

```yaml
depends_on:
  db:
    condition: service_healthy
```

This allows the application to wait for the database health condition.

---

# Part 20 – Docker Hub

Login:

```bash
docker login
```

Tag:

```bash
docker tag local-image:tag username/repository:tag
```

Push:

```bash
docker push username/repository:tag
```

Pull:

```bash
docker pull username/repository:tag
```

List images:

```bash
docker images
```

Inspect an image:

```bash
docker image inspect image:tag
```

View image history:

```bash
docker history image:tag
```

---

# Part 21 – Container Commands Cheat Sheet

| Command | Purpose |
|---|---|
| `docker run IMAGE` | Create and start a container |
| `docker run -it IMAGE sh` | Start interactive shell |
| `docker run -d IMAGE` | Run detached |
| `docker ps` | List running containers |
| `docker ps -a` | List all containers |
| `docker stop NAME` | Stop container |
| `docker start NAME` | Start stopped container |
| `docker restart NAME` | Restart container |
| `docker rm NAME` | Remove container |
| `docker rm -f NAME` | Force remove container |
| `docker exec -it NAME sh` | Open shell inside container |
| `docker logs NAME` | View logs |
| `docker logs -f NAME` | Follow logs |
| `docker inspect NAME` | Inspect container configuration |
| `docker stats` | View container resource usage |

---

# Part 22 – Image Commands Cheat Sheet

| Command | Purpose |
|---|---|
| `docker images` | List images |
| `docker image ls` | List images |
| `docker pull IMAGE` | Pull image |
| `docker build -t NAME:TAG .` | Build image |
| `docker tag IMAGE NAME:TAG` | Create image tag |
| `docker push NAME:TAG` | Push image |
| `docker image inspect IMAGE` | Inspect image |
| `docker history IMAGE` | View image layers |
| `docker rmi IMAGE` | Remove image |
| `docker rmi -f IMAGE` | Force remove image |

---

# Part 23 – Volume Commands Cheat Sheet

| Command | Purpose |
|---|---|
| `docker volume create NAME` | Create named volume |
| `docker volume ls` | List volumes |
| `docker volume inspect NAME` | Inspect volume |
| `docker volume rm NAME` | Remove volume |
| `docker volume prune` | Remove unused volumes |

---

# Part 24 – Network Commands Cheat Sheet

| Command | Purpose |
|---|---|
| `docker network ls` | List networks |
| `docker network create NAME` | Create network |
| `docker network inspect NAME` | Inspect network |
| `docker network connect NET CONTAINER` | Connect container to network |
| `docker network disconnect NET CONTAINER` | Disconnect container |
| `docker network rm NAME` | Remove network |
| `docker network prune` | Remove unused networks |

---

# Part 25 – Cleanup Commands Cheat Sheet

Check Docker disk usage:

```bash
docker system df
```

Detailed disk usage:

```bash
docker system df -v
```

Remove unused containers:

```bash
docker container prune
```

Remove unused images:

```bash
docker image prune
```

Remove unused volumes:

```bash
docker volume prune
```

Remove unused networks:

```bash
docker network prune
```

General cleanup:

```bash
docker system prune
```

More aggressive cleanup including unused images:

```bash
docker system prune -a
```

Be careful with cleanup commands because they permanently remove unused Docker resources.

---

# Part 26 – Dockerfile Instructions Cheat Sheet

| Instruction | Purpose |
|---|---|
| `FROM` | Select base image |
| `RUN` | Execute command during image build |
| `COPY` | Copy files into image |
| `ADD` | Copy files with additional features |
| `WORKDIR` | Set working directory |
| `ENV` | Set environment variable |
| `EXPOSE` | Document intended container port |
| `CMD` | Default command |
| `ENTRYPOINT` | Define main executable |
| `USER` | Set runtime user |
| `ARG` | Build-time variable |

---

# Part 27 – CMD vs ENTRYPOINT

## CMD

Example:

```dockerfile
CMD ["echo", "hello"]
```

Running:

```bash
docker run image
```

produces:

```text
hello
```

A command supplied at runtime can replace the CMD.

```bash
docker run image echo hi
```

Result:

```text
hi
```

Think:

```text
CMD = default command
```

---

## ENTRYPOINT

Example:

```dockerfile
ENTRYPOINT ["echo"]
```

Running:

```bash
docker run image hello
```

produces:

```text
hello
```

The supplied argument is passed to the entrypoint.

Think:

```text
ENTRYPOINT = main executable
```

---

# Part 28 – `EXPOSE` vs `-p`

Dockerfile:

```dockerfile
EXPOSE 8080
```

documents that the application listens on port 8080.

It does **not** automatically publish the port to the host.

To publish it:

```bash
docker run -p 8080:8080 IMAGE
```

Remember:

```text
EXPOSE → documentation/metadata

-p → actual host-to-container port publishing
```

---

# Part 29 – Important Docker Mental Model

The most important concepts from Days 29–36 can be visualized like this:

```text
                    Dockerfile
                        │
                        ▼
                 Docker Image
                        │
                   docker run
                        │
                        ▼
                 Docker Container
                        │
          ┌─────────────┼─────────────┐
          │             │             │
       Network        Volume        Ports
          │             │             │
          ▼             ▼             ▼
     Container       Persistent     Host
     communication     data       communication
```

For multi-container applications:

```text
                Docker Compose
                      │
          ┌───────────┼───────────┐
          │           │           │
          ▼           ▼           ▼
        App           DB        Cache
          │           │           │
          └───────────┼───────────┘
                      │
                Custom Network
```

---

# Part 30 – Day 36 Portfolio Project Flow

The project we worked on during Day 36 followed this architecture:

```text
                    Browser
                       │
                       │ HTTP :8080
                       ▼
              ┌─────────────────┐
              │ Java App        │
              │                 │
              │ Tomcat          │
              │ Java Runtime    │
              │ ROOT.war        │
              └────────┬────────┘
                       │
                       │ JDBC
                       ▼
              ┌─────────────────┐
              │ PostgreSQL      │
              │                 │
              │ Persistent      │
              │ Volume          │
              └─────────────────┘
```

Docker Compose manages the services and network.

---

# Part 31 – Key Lessons From Days 29–36

### Containers

Containers are isolated runtime environments created from images.

### Images

Images are immutable templates used to create containers.

### Volumes

Volumes provide persistent storage outside the container's writable layer.

### Networks

Custom Docker networks provide container-to-container communication and DNS-based service discovery.

### Dockerfiles

Dockerfiles describe how images are built.

### Compose

Docker Compose defines and manages multi-container applications.

### Multi-stage builds

Separate build-time requirements from runtime requirements.

### jlink

Creates a minimal Java runtime containing only required Java modules.

### Docker Hub

Provides a registry for storing and distributing container images.

### Healthchecks

Allow applications/orchestrators to determine whether a service is actually healthy.

### Non-root containers

Running applications as non-root users reduces security risk.

---

# Final Day 37 Summary

The most important Docker concepts to remember are:

```text
IMAGE
  ↓
Template

CONTAINER
  ↓
Running instance of image

VOLUME
  ↓
Persistent data

NETWORK
  ↓
Container communication

DOCKERFILE
  ↓
Build instructions

COMPOSE
  ↓
Multi-container orchestration

MULTI-STAGE
  ↓
Separate build and runtime

DOCKER HUB
  ↓
Image distribution

HEALTHCHECK
  ↓
Service health

jlink
  ↓
Minimal Java runtime
```

## Day 37 Status

- [x] Self-assessment completed
- [x] Quick-fire questions completed
- [x] `COPY` vs `ADD` practiced
- [x] Docker layer caching practiced
- [x] Dockerfile layer ordering understood
- [x] Multi-stage builds revised
- [x] Docker Compose revised
- [x] Volumes revised
- [x] Networking revised
- [x] Docker Hub revised
- [x] Java/Tomcat/Maven Docker architecture revised
- [x] jlink concept revised
- [x] Docker cheat sheet prepared

**Docker Revision — COMPLETE ✅**
