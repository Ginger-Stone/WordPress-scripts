# WordPress scripts
- WordPress + WooCommerce Scaffold Script
- WordPress Plugin Packager (Include-Only, Production Ready)

### WordPress + WooCommerce Scaffold Script

This script provides a fast, automated way to scaffold a fully
functional WordPress application with WooCommerce for testing
and development.

To test a WordPress Woo Commerce plugin, you need to test with multiple WordPress versions as well as Woo Commerce versions and PHP versions.

Download WordPress and Woo Commerce using the links below:
 - [WordPress release archive](https://wordpress.org/download/releases/) 
 - [Woo Commerce release archive](https://github.com/woocommerce/woocommerce/releases)

To Install PHP, use the link below:
 - [PHP Downloads](https://www.php.net/downloads.php?usage=web&os=linux&osvariant=linux-ubuntu&version=8.2) 

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


### WordPress Plugin Packager (Include-Only, Production Ready)

This script creates a clean, installable ZIP archive of a
WordPress plugin using an allowlist (include list).

What it does:
 - Copies only explicitly allowed files/directories
 - Installs Composer dependencies in production mode (--no-dev)
 - Optimizes autoloading for performance
 - Shows a verification list of files to be packaged
 - Prompts for confirmation before creating the ZIP
 - Adds a packaging README file inside the zip

 IMPORTANT:
 - You SHOULD modify the INCLUDE_PATHS list below to match your
   plugin structure. This script only includes what you specify.

Usage:
```bash
chmod +x zip-plugin.sh
./zip-plugin.sh <plugin_path> [output_dir]
```

Example:
```bash
./zip-plugin.sh /path/to/my-plugin /path/to/output
```
