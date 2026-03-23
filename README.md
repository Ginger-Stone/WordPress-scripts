# WordPress + WooCommerce Scaffold Script

This script provides a fast, automated way to scaffold a fully
functional WordPress application with WooCommerce for testing
and development.

Before running this script, ensure you have installed and configured MySQL, Apache, and PHP.

It performs the following:
 - Creates and configures a dedicated MySQL database
 - Sets up a new site under /srv/www/
 - Installs WordPress from a provided zip file
 - Installs WooCommerce from a provided zip file
 - Configures wp-config.php with database credentials
 - Creates and enables an Apache VirtualHost
 - Updates /etc/hosts for local access

The goal is to eliminate repetitive setup steps and enable
quick spin-up of isolated WooCommerce environments.

Usage:
```bash
chmod +x scaffold-wp.sh
./scaffold-wp.sh <site_name> <php_version> <wordpress_zip> <woocommerce_zip>
```
Example:
```bash
./scaffold-wp.sh myshop.test 8.2 /path/to/wordpress.zip /path/to/woocommerce.zip
```
