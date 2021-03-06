# Dockerfile Raspberry Pi Nginx
FROM debian:latest

# Update sources && install packages
RUN DEBIAN_FRONTEND=noninteractive ;\
apt-get update && \
apt-get install --assume-yes \
    nginx \
    php5-fpm \
    php5 \
    php5-json \
    php5-gd \
    php5-sqlite \
    php5-curl \
    php5-common \
    php-xml-parser \
    php-apc \
    ntp \
    supervisor

# COPY PHP-FPM Configuration
COPY ./nginx/conf.d/php5-fpm.conf /etc/nginx/conf.d/php5-fpm.conf

# COPY nginx/sites-available/default
COPY ./nginx/sites-available/default /etc/nginx/sites-available/default

# COPY index.php info
COPY ./phpinfo.php /var/www/html/phpinfo.php

# Turn off daemon mode
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf

RUN sed -i -e "s/listen \= 127.0.0.1\:9000/listen \= \/var\/run\/php5-fpm.sock/" /etc/php5/fpm/pool.d/www.conf && \
sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf && \
sed -i -e "s/;env/env/g" /etc/php5/fpm/pool.d/www.conf 

RUN echo "Europe/Paris" > /etc/timezone && dpkg-reconfigure tzdata && sed -i 's/.debian./.fr./g' /etc/ntp.conf

RUN mkdir -p /var/log/supervisor

# Volume
VOLUME ["/etc/nginx", "/etc/nginx/conf.d", "/var/www/html"]

# Set the current working directory
WORKDIR /var/www/html

# Ports 
EXPOSE 80 443

# Boot up Nginx, and PHP5-FPM when container is started
CMD service php5-fpm start && nginx
