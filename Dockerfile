FROM jenkins/jenkins:lts-alpine
MAINTAINER Tito Alvarez <augustoalvarez@gmail.com>

USER root

# ensure docker group is set to 999 to match the same group from the host
RUN sed -i "s/999/99/" /etc/group && \
  addgroup -g 999 -S docker

# Install Docker (docker-in-docker) and sudo
RUN apk add --no-cache \
    docker \
    sudo

# Adds Jenkins to the Docker users and sudoers
RUN adduser jenkins docker && \
	echo "jenkins ALL=(root) NOPASSWD: /usr/bin/docker" > /etc/sudoers.d/jenkins && \
	chmod 0440 /etc/sudoers.d/jenkins

# Install redWEB development tools

#===================================================
# PHP
#===================================================
RUN apk add --no-cache \
	php7 \
	php7-curl \
	php7-mbstring \
	php7-dom \
	php7-zip \
	php7-ctype \
	php7-mysqli \
	php7-intl \
	php7-json \
	php7-phar \
	php7-xml \
	php7-xmlwriter \
	php7-simplexml \
	php7-tokenizer \
	php7-pdo \
	php7-pdo_mysql \
	php7-session \
	php7-gd \
	php7-ftp \
	php7-imagick \
	php7-fileinfo

#===================================================
# Node & Gulp
#===================================================
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.8/main" >> /etc/apk/repositories && \
	apk add --no-cache \
    nodejs=8.14.0-r0 \
    npm=8.14.0-r0 \
    && npm install -g gulp

#========================================
# Composer
#========================================
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php -r "if (hash_file('SHA384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
	&& php composer-setup.php --filename=composer --install-dir=/usr/local/bin \
	&& php -r "unlink('composer-setup.php');"

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]