FROM alpine:3.18
RUN apk add --no-cache bash tar coreutils findutils
WORKDIR /app
COPY ./scripts/archive_logs.sh ./tests/test_archive_logs.sh ./
RUN chmod 755 /app/archive_logs.sh /app/test_archive_logs.sh
CMD ["/bin/bash", "./test_archive_logs.sh"]