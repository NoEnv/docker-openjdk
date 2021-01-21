FROM openjdk:15.0.2-jdk-slim-buster

RUN ln -s /usr/local/openjdk-15 /docker-java-home

COPY cacerts /usr/local/openjdk-15/lib/security/
