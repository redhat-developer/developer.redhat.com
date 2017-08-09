#!/bin/bash
set -e

cd /var/www/drupal

# This sleep seems to be required for certain Docker/OS combos as the bind mounts may not be fully ready
sleep 10

# Check if drupal is installed, install if needed
ruby drupal_install_checker.rb

# Run all database migrations
ruby /var/www/drupal/phinx.rb migrate

# Make sure we're not confused by old, incompletely-shutdown httpd
# context after restarting the container.  httpd won't start correctly
# if it thinks it is already running.
rm -rf /run/httpd/*

# Set it up so apache can write to everything
chown -R apache:apache /var/www/drupal/web/sites
chown -R apache:apache /var/www/drupal/web/config/active # just to make sure we can write changes to active

exec /usr/sbin/apachectl -D FOREGROUND