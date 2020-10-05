FROM jenkins/jenkins:lts-alpine

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

# Jenkins key folder and key validation removal for redWEB repositories

USER jenkins
RUN mkdir -p ~/.ssh && \
	chmod 0700 ~/.ssh && \
	ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts && \
	ssh-keyscan -t rsa gitlab.redweb.dk >> ~/.ssh/known_hosts

USER root

## Packages
RUN apk add --no-cache \
	zip

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
	php7-fileinfo \
	php7-bcmath \
	php7-sockets

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
	&& php -r "if (hash_file('SHA384', 'composer-setup.php') === '795f976fe0ebd8b75f26a6dd68f78fd3453ce79f32ecb33e7fd087d39bfeb978342fb73ac986cd4f54edd0dc902601dc') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
	&& php composer-setup.php --filename=composer --install-dir=/usr/local/bin \
	&& php -r "unlink('composer-setup.php');"

RUN composer -g config bin-dir /usr/local/bin && \
	composer -g config vendor-dir /usr/local/lib/vendor

#===================================================
# Phing
#===================================================
RUN composer global require phing/phing

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]