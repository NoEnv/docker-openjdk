FROM debian:bookworm-slim

COPY ca-bundle /tmp/ca-bundle

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends tzdata curl ca-certificates fontconfig locales binutils && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* && \
    ARCH="$(dpkg --print-architecture)" && \
    case "${ARCH}" in \
       aarch64|arm64) \
         ESUM='04fe1273f624187d927f1b466e8cdb630d70786db07bee7599bfa5153060afd3'; \
         BINARY_URL='https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.6%2B7/OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.6_7.tar.gz'; \
         ;; \
       amd64|i386:x86-64) \
         ESUM='a2650fba422283fbed20d936ce5d2a52906a5414ec17b2f7676dddb87201dbae'; \
         BINARY_URL='https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.6%2B7/OpenJDK21U-jdk_x64_linux_hotspot_21.0.6_7.tar.gz'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    curl -LfsSo /tmp/openjdk.tar.gz ${BINARY_URL} && \
    echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c - && \
    mkdir -p /usr/local/openjdk && \
    cd /usr/local/openjdk && \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1 && \
    /usr/local/openjdk/bin/keytool -import -noprompt -trustcacerts -cacerts -storepass changeit -alias noenv_ca -file /tmp/ca-bundle/noenv.pem && \
    /usr/local/openjdk/bin/keytool -import -noprompt -trustcacerts -cacerts -storepass changeit -alias goldrush_ca -file /tmp/ca-bundle/goldrush.pem && \
    rm -rf /tmp/openjdk.tar.gz /tmp/ca-bundle && \
    ln -s /usr/local/openjdk /docker-java-home

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    JAVA_VERSION=jdk-21.0.6+7 \
    JAVA_HOME=/usr/local/openjdk \
    PATH="/usr/local/openjdk/bin:$PATH"

CMD ["java", "--version"]
