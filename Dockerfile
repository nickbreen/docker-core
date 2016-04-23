FROM scratch

ADD ubuntu-core-16.04-core-amd64.tar.gz /

ENV container docker

ENTRYPOINT [ "/bin/systemd" ]
