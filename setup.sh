#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

export LC_ALL='en_US.UTF-8'
export LANG='en_US.UTF-8'
export LANGUAGE='en_US.UTF-8'

apt-get clean && apt-get -y update && apt-get install -y locales && locale-gen en_US.UTF-8
echo "LC_ALL=en_US.UTF-8" >> /etc/environment
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen en_US.UTF-8
dpkg-reconfigure locales

# Install tools
apt-get install -qqy software-properties-common python-software-properties python-setuptools
add-apt-repository -y ppa:ondrej/php


# Install base packages
apt-get install -qqy apt-transport-https ca-certificates vim make git-core wget curl procps \
mcrypt mysql-client zip unzip redis-tools netcat-openbsd
apt-get -qqy --allow-insecure-repositories update
# Install php
apt-get install -y --allow-unauthenticated php7.1-fpm php7.1-cli php7.1-common php7.1-dev \
php7.1-mysql php7.1-curl php7.1-gd php7.1-mcrypt php7.1-xmlrpc php7.1-ldap \
php7.1-xsl php7.1-intl php7.1-soap php7.1-mbstring php7.1-zip php7.1-bz2 php7.1-redis || exit 1 

# Install nginx
apt-get install -qqy --reinstall nginx || exit 1

# Install composer
(curl -sS https://getcomposer.org/installer | php) || exit 1
mv composer.phar /usr/local/bin/composer.phar

# Create composer home dirs
mkdir -p -m 0744 /opt/composer/root
mkdir -p -m 0744 /opt/composer/www-data
chown www-data:www-data /opt/composer/www-data

# Create composer wrapper
echo '#!/usr/bin/env bash' >> /usr/local/bin/composer
echo 'COMPOSER_HOME=/opt/composer/$(whoami) /usr/local/bin/composer.phar $@' >> /usr/local/bin/composer
chmod 0755 /usr/local/bin/composer

# Install required composer-plugins
runuser -s /bin/sh -c 'composer global require fxp/composer-asset-plugin:1.4.4' www-data || exit 1

# Install node.js
apt-get install nodejs -y && apt-get install npm -y  || exit 1

# Install supervisor
easy_install supervisor || exit 1
easy_install supervisor-stdout || exit 1

apt-get -qq clean
rm -rf /var/lib/apt/lists/*