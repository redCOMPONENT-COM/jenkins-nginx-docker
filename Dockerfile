FROM jenkins/jenkins:lts-alpine
MAINTAINER Tito Alvarez <augustoalvarez@gmail.com>

USER root

# Install Docker (docker-in-docker) and sudo
RUN apk add --no-cache \
    docker \
    sudo

# Adds Jenkins to the Docker users and sudoers
RUN adduser jenkins docker && \
	echo "jenkins ALL=(root) NOPASSWD: /usr/bin/docker" > /etc/sudoers.d/jenkins && \
	chmod 0440 /etc/sudoers.d/jenkins

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]