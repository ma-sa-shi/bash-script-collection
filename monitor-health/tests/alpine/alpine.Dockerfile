FROM alpine:3.18
RUN apk add --no-cache bash procps coreutils python3
RUN adduser -D tester
WORKDIR /app
COPY --chown=tester:tester ./scripts/monitor_health.sh ./scripts/
COPY --chown=tester:tester ./tests/test_monitor_health.sh ./tests/
RUN chmod 755 /app/scripts/monitor_health.sh /app/tests/test_monitor_health.sh
USER tester
CMD ["/bin/bash", "./tests/test_monitor_health.sh"]