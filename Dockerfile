FROM debian:trixie-slim

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
         ESUM='c37879e0d08eeb1baa69fcbb7758cd455b7b1c0ceab1e2a136ccb1713c530984'; \
         BINARY_URL='https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.5.1%2B2/OpenJDK25U-jdk_aarch64_linux_hotspot_25.0.5.1_2.tar.gz'; \
         ;; \
       amd64|i386:x86-64) \
         ESUM='760f91b22c3efc9bd1b64ff950598231be82928cc807e30691a0e7a2995a62c0'; \
         BINARY_URL='https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.5.1%2B2/OpenJDK25U-jdk_x64_linux_hotspot_25.0.5.1_2.tar.gz'; \
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
    JAVA_VERSION=jdk-25.0.5.1+2 \
    JAVA_HOME=/usr/local/openjdk \
    PATH="/usr/local/openjdk/bin:$PATH"

CMD ["java", "--version"]
