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
         ESUM='f541f545c0e8046c2b242a1701e5be4a7abda2ffbc150d7f96b6cd5571f17429'; \
         BINARY_URL='https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21%2B35-ea-beta/OpenJDK21U-jdk_aarch64_linux_hotspot_ea_21-0-35.tar.gz'; \
         ;; \
       amd64|i386:x86-64) \
         ESUM='b6586c432948134387b801add3b46048e3fb58390d74eea80e00c539016a54e6'; \
         BINARY_URL='https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21%2B35-ea-beta/OpenJDK21U-jdk_x64_linux_hotspot_ea_21-0-35.tar.gz'; \
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
    rm -rf /tmp/openjdk.tar.gz && \
    ln -s /usr/local/openjdk /docker-java-home

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    JAVA_VERSION=jdk-21+35 \
    JAVA_HOME=/usr/local/openjdk \
    PATH="/usr/local/openjdk/bin:$PATH"

COPY cacerts /usr/local/openjdk/lib/security/

CMD ["java", "--version"]
