#!/usr/bin/env bash


# Create composer home dirs
mkdir -p -m 0744 /opt/composer/root
mkdir -p -m 0744 /opt/composer/www-data
chown www-data:www-data /opt/composer/www-data

# Create composer wrapper
echo '#!/usr/bin/env bash' >> /usr/local/bin/composer
echo 'COMPOSER_HOME=/opt/composer/$(whoami) /usr/local/bin/composer.phar $@' >> /usr/local/bin/composer
chmod 0755 /usr/local/bin/composer

# Install required composer-plugins
runuser -s /bin/sh -c 'composer global require fxp/composer-asset-plugin:1.2.2' www-data || exit 1

# Install node.js
apt-get install -qqy nodejs || exit 1

# Install supervisor
easy_install supervisor || exit 1
easy_install supervisor-stdout || exit 1

apt-get -qq clean
rm -rf /var/lib/apt/lists/*
