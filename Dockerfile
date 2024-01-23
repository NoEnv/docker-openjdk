FROM debian:bookworm-slim

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
         ESUM='3ce6a2b357e2ef45fd6b53d6587aa05bfec7771e7fb982f2c964f6b771b7526a'; \
         BINARY_URL='https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2%2B13/OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.2_13.tar.gz'; \
         ;; \
       amd64|i386:x86-64) \
         ESUM='454bebb2c9fe48d981341461ffb6bf1017c7b7c6e15c6b0c29b959194ba3aaa5'; \
         BINARY_URL='https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2%2B13/OpenJDK21U-jdk_x64_linux_hotspot_21.0.2_13.tar.gz'; \
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
    curl -LfsSo /tmp/noenv.ca.crt https://noenv.com/ca.pem && \
    echo "2ecfa5dafd7d5e47313953ae0278f59657f9e3c8f8ee8b99b9cf5d31d45fd4dd */tmp/noenv.ca.crt" | sha256sum -c - && \
    /usr/local/openjdk/bin/keytool -import -noprompt -trustcacerts -cacerts -storepass changeit -alias noenvca -file /tmp/noenv.ca.crt && \
    rm -rf /tmp/openjdk.tar.gz /tmp/noenv.ca.crt && \
    ln -s /usr/local/openjdk /docker-java-home

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    JAVA_VERSION=jdk-21.0.2+13 \
    JAVA_HOME=/usr/local/openjdk \
    PATH="/usr/local/openjdk/bin:$PATH"

CMD ["java", "--version"]
