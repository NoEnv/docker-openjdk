FROM openjdk:16.0.1-jdk-slim-buster

RUN ln -s /usr/local/openjdk-16 /docker-java-home

COPY cacerts /usr/local/openjdk-16/lib/security/
