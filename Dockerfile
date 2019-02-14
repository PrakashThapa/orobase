FROM ubuntu:16.04

MAINTAINER Donatas Navidonskis <donatas@navidonskis.com>

# Let the container know that there is no tty
ENV DEBIAN_FRONTEN noninteractive
RUN dpkg-divert --local --rename --add /sbin/initctl && \
	ln -sf /bin/true /sbin/initctl && \
	mkdir /var/run/sshd && \
	mkdir /run/php && \
	apt-get update && \
	apt-get install -y --no-install-recommends apt-utils \ 
		software-properties-common \
		python-software-properties \
		language-pack-en-base && \
	LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php && \
	apt-get update && apt-get upgrade -y && \
	apt-get install -y python-setuptools \ 
		curl \
		git \
		nano \
		sudo \
		unzip \
		openssh-server \
		openssl \
		supervisor \
		nginx \
		memcached \
		ssmtp \
		cron && \
	# Install PHP
	apt-get install -y php7.1-fpm \
		php7.1-mysql \
	    php7.1-curl \
	    php7.1-gd \
	    php7.1-intl \
	    php7.1-mcrypt \
	    php-memcache \
	    php7.1-sqlite \
	    php7.1-tidy \
	    php7.1-xmlrpc \
	    php7.1-pgsql \
	    php7.1-ldap \
	    freetds-common \
	    php7.1-pgsql \
	    php7.1-sqlite3 \
	    php7.1-json \
	    php7.1-xml \
	    php7.1-mbstring \
	    php7.1-soap \
	    php7.1-zip \
	    php7.1-cli \
	    php7.1-sybase \
	    php7.1-odbc
RUN curl -sS https://getcomposer.org/installer | php \
  && chmod +x composer.phar && mv composer.phar /usr/local/bin/composer.phar && \
mkdir -p -m 0744 /opt/composer/root && \
mkdir -p -m 0744 /opt/composer/www-data && \
chown www-data:www-data /opt/composer/www-data && \
# Create composer wrapper
echo '#!/usr/bin/env bash' >> /usr/local/bin/composer  && \
echo 'COMPOSER_HOME=/opt/composer/$(whoami) /usr/local/bin/composer.phar $@' >> /usr/local/bin/composer  && \
chmod 0755 /usr/local/bin/composer && \
# Install required composer-plugins
runuser -s /bin/sh -c 'composer global require fxp/composer-asset-plugin:1.2.2' www-data || exit 1  && \
runuser -s /bin/sh -c 'composer global require hirak/prestissimo' www-data || exit 1    && \
apt-get install -qqy --reinstall nginx || exit 1  && \
# Install node.js
apt-get install -qqy nodejs || exit 1  && \
# Install supervisor
easy_install supervisor || exit 1  \
easy_install supervisor-stdout || exit 1  && \
apt-get -qq clean  && \
rm -rf /var/lib/apt/lists/* 

COPY setup.sh /opt/bin/
COPY configure.sh /opt/bin/ 
COPY sources.list /etc/apt/sources.list.d/
#RUN /bin/bash /opt/bin/setup.sh
RUN /bin/bash /opt/bin/configure.sh
COPY bin/* /usr/local/bin/

RUN chmod +x /usr/local/bin/*
