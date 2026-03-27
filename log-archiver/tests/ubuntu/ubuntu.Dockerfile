FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y bash coreutils tar gzip findutils tree && \
    rm -rf /var/lib/apt/lists/*
RUN useradd -m tester
WORKDIR /app
COPY ./scripts/archive_logs.sh ./scripts/
COPY ./tests/test_archive_logs.sh ./tests/
RUN chown -R tester:tester /app && \
    chmod 755 /app/scripts/archive_logs.sh /app/tests/test_archive_logs.sh
USER tester
CMD ["/bin/bash", "/app/tests/test_archive_logs.sh"]