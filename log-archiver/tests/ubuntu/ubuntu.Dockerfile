FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y \
    bash \
    coreutils \
    tar \
    gzip \
    findutils && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY ./scripts/archive_logs.sh ./tests/test_archive_logs.sh ./
RUN chmod 755 /app/archive_logs.sh /app/test_archive_logs.sh
CMD ["/bin/bash", "/app/test_archive_logs.sh"]