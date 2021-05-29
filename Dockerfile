# See https://hub.docker.com/_/wordpress/ for the latest
FROM wordpress:5.3.2-php7.4-apache

EXPOSE 8080
# Use the PORT environment variable in Apache configuration files.
RUN sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf
# wordpress conf
COPY wordpress/wp-config.php /var/www/html/wp-config.php

# Copy WordPress THEMES
COPY themes /usr/src/wordpress/wp-content/themes/

# Copy WordPress PLUGINS
COPY plugins /usr/src/wordpress/wp-content/plugins/

# download and install cloud_sql_proxy
RUN apt-get update && apt-get install curl -y
RUN curl -o /usr/local/bin/cloud_sql_proxy https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 && chmod +x /usr/local/bin/cloud_sql_proxy

# custom entrypoint
# COPY wordpress/cloud-run-entrypoint.sh /usr/local/bin/

# RUN chmod u+x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["cloud_sql_proxy -instances=${CLOUDSQL_INSTANCE}=tcp:3306","docker-entrypoint.sh"]
CMD ["apache2-foreground"]
