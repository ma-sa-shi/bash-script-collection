FROM rockylinux:9
RUN dnf -y update && \
    dnf install -y bash tar gzip findutils tree&& \
    dnf clean all
RUN useradd -m tester
WORKDIR /app
COPY ./scripts/archive_logs.sh ./scripts/
COPY ./tests/test_archive_logs.sh ./tests/
RUN chown -R tester:tester /app && \
    chmod 755 /app/scripts/archive_logs.sh /app/tests/test_archive_logs.sh
USER tester
CMD ["/bin/bash", "./tests/test_archive_logs.sh"]