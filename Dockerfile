FROM scratch

MAINTAINER Nick Breen <nick@foobar.net.nz>

ADD ubuntu-core-16.04-core-amd64.tar.gz /

ENV container docker

# Disable (rather, mask) all systemd services
#
# From https://github.com/maci0/docker-systemd-unpriv/blob/master/Dockerfile
RUN systemctl mask \
  dev-hugepages.mount \
  dev-mqueue.mount \
  display-manager.service \
  graphical.target \
  sys-fs-fuse-connections.mount \
  sys-kernel-config.mount \
  sys-kernel-debug.mount \
  systemd-logind.service \
  systemd-remount-fs.service

# Replace the 'ischroot' tool to make it always return true.
# Prevent initscripts updates from breaking /dev/shm.
# https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
# https://bugs.launchpad.net/launchpad/+bug/974584
#
# From: https://github.com/phusion/baseimage-docker/blob/master/image/prepare.sh
RUN dpkg-divert --local --rename --add /usr/bin/ischroot && ln -sf /bin/true /usr/bin/ischroot

# Install add-apt-repository
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -qy --no-install-recommends software-properties-common && apt-get clean

# Install runit and replace init
RUN add-apt-repository universe && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -qy --no-install-recommends runit && apt-get clean
RUN dpkg-divert --local --rename --add /sbin/init && ln -sf /sbin/runit-init /sbin/init

# Install crond and syslogd
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -qy --no-install-recommends cron rsyslog && apt-get clean

# Add phusion/baseimage-docker compatible container_environment, except for JSON
# Add default system services
COPY etc /etc

# Do we really care about the locale? Not really, but let's go Kiwi anyway.
RUN locale-gen en_NZ.UTF-8 && update-locale LANG=en_NZ.UTF-8 LC_CTYPE=en_NZ.UTF-8
RUN echo -n en_NZ.UTF-8 > /etc/container_environment/LANG
RUN echo -n en_NZ.UTF-8 > /etc/container_environment/LC_CTYPE

CMD [ "/sbin/init" ]
