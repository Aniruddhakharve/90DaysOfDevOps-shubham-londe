# stage 1
FROM eclipse-temurin:21-jdk-jammy AS builder

WORKDIR /app

COPY Main.java .

RUN javac -d /app/lib Main.java

# stage 2
FROM gcr.io/distroless/java21-debian12

WORKDIR /app

COPY --from=builder /app/lib /app/lib

ENTRYPOINT ["java"]

CMD ["-cp", "/app/lib", "Main"]

