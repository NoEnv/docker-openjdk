FROM openjdk:17-jdk-slim-buster

RUN ln -s /usr/local/openjdk-17 /docker-java-home

COPY cacerts /usr/local/openjdk-17/lib/security/
