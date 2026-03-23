#!/bin/bash

# =============================================================
# WordPress + WooCommerce Scaffold Script
# -------------------------------------------------------------
# This script provides a fast, automated way to scaffold a fully
# functional WordPress application with WooCommerce for testing
# and development.
#
# Before running this script, ensure you have installed and configured MySQL, Apache, and PHP.
#
# It performs the following:
# - Creates and configures a dedicated MySQL database
# - Sets up a new site under /srv/www/
# - Installs WordPress from a provided zip file
# - Installs WooCommerce from a provided zip file
# - Configures wp-config.php with database credentials
# - Creates and enables an Apache VirtualHost
# - Updates /etc/hosts for local access
#
# The goal is to eliminate repetitive setup steps and enable
# quick spin-up of isolated WooCommerce environments.
#
# --------------------
# Usage:
# chmod +x scaffold-wp.sh
# ./scaffold-wp.sh <site_name> <php_version> <wordpress_zip> <woocommerce_zip>
#
# Example:
# ./scaffold-wp.sh myshop 8.2 /path/to/wordpress.zip /path/to/woocommerce.zip
# --------------------
# =============================================================

set -e

SITE_NAME=$1
PHP_VERSION=$2
WP_ZIP=$3
WC_ZIP=$4

BASE_DIR="/srv/www"
SITE_DIR="$BASE_DIR/$SITE_NAME"
APACHE_CONF="/etc/apache2/sites-available/$SITE_NAME.conf"

if [ -z "$SITE_NAME" ] || [ -z "$PHP_VERSION" ] || [ -z "$WP_ZIP" ] || [ -z "$WC_ZIP" ]; then
  echo "Usage: $0 <site_name> <php_version> <wordpress_zip> <woocommerce_zip>"
  exit 1
fi

echo "🚀 Starting scaffold for $SITE_NAME with PHP $PHP_VERSION"

echo "🛢️ Creating database..."

DB_NAME=$(echo "$SITE_NAME" | tr '.' '_' )
DB_USER="${DB_NAME}_user"
DB_PASS=$(openssl rand -base64 12)

echo "➡️ DB Name: $DB_NAME"
echo "➡️ DB User: $DB_USER"
echo "➡️ DB Pass: $DB_PASS"

read -sp "Enter MySQL root password: " MYSQL_ROOT_PASS
echo ""

mysql -u root -p"$MYSQL_ROOT_PASS" <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "📁 Creating site directory..."
sudo mkdir -p $SITE_DIR

echo "📦 Extracting WordPress..."
sudo unzip -q $WP_ZIP -d /tmp/wp_temp
sudo cp -r /tmp/wp_temp/wordpress/* $SITE_DIR
sudo rm -rf /tmp/wp_temp

echo "🔐 Setting permissions..."
sudo chown -R www-data:www-data $SITE_DIR
sudo chmod -R 755 $SITE_DIR

echo "🌐 Creating Apache VirtualHost..."

sudo tee $APACHE_CONF > /dev/null <<EOL
<VirtualHost *:80>
    ServerName $SITE_NAME
    ServerAdmin webmaster@localhost

    DocumentRoot $SITE_DIR

    <Directory $SITE_DIR>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/${SITE_NAME}_error.log
    CustomLog \${APACHE_LOG_DIR}/${SITE_NAME}_access.log combined
</VirtualHost>
EOL

# Enable site + rewrite
sudo a2ensite $SITE_NAME.conf
sudo a2enmod rewrite
sudo systemctl reload apache2

echo "🛒 Installing WooCommerce..."

PLUGIN_DIR="$SITE_DIR/wp-content/plugins"
sudo mkdir -p $PLUGIN_DIR

sudo unzip -q $WC_ZIP -d /tmp/wc_temp
sudo cp -r /tmp/wc_temp/woocommerce $PLUGIN_DIR
sudo rm -rf /tmp/wc_temp

sudo chown -R www-data:www-data $PLUGIN_DIR

echo "⚙️ Configuring WordPress..."

if [ ! -f "$SITE_DIR/wp-config.php" ]; then
  sudo cp $SITE_DIR/wp-config-sample.php $SITE_DIR/wp-config.php
fi

sudo sed -i "s/database_name_here/$DB_NAME/" $SITE_DIR/wp-config.php
sudo sed -i "s/username_here/$DB_USER/" $SITE_DIR/wp-config.php
sudo sed -i "s/password_here/$DB_PASS/" $SITE_DIR/wp-config.php
sudo sed -i "s/localhost/127.0.0.1/" $SITE_DIR/wp-config.php

echo "🌍 Updating /etc/hosts..."
if ! grep -q "$SITE_NAME" /etc/hosts; then
  echo "127.0.0.1 $SITE_NAME" | sudo tee -a /etc/hosts
fi

echo ""
echo "✅ Scaffold complete!"
echo "➡️ Visit: http://$SITE_NAME"
echo ""
echo "⚠️ Next steps:"
echo "- Create database"
echo "- Update wp-config.php"
echo "- Finish WordPress install in browser"
echo "- Activate WooCommerce plugin"
