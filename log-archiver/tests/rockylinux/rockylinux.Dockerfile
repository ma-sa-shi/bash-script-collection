FROM rockylinux:9
RUN dnf install -y \ 
    bash \ 
    tar \
    gzip \
    findutils && \ 
    dnf clean all
WORKDIR /app
COPY ./scripts/archive_logs.sh ./tests/test_archive_logs.sh ./
RUN chmod 755 archive_logs.sh test_archive_logs.sh
CMD ["/bin/bash", "./test_archive_logs.sh"]