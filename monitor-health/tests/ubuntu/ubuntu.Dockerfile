FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt install -y procps coreutils python3 --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*
RUN useradd -m tester
WORKDIR /app
COPY --chown=tester:tester ./scripts/monitor_health.sh ./scripts/
COPY --chown=tester:tester ./tests/test_monitor_health.sh ./tests/
RUN chmod 755 /app/scripts/monitor_health.sh /app/tests/test_monitor_health.sh
USER tester
CMD ["/bin/bash", "./tests/test_monitor_health.sh"]