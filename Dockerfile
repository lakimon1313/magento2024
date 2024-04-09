# We are using the official PHP Docker image with the FPM tag
FROM php:8.2-fpm

# Install the necessary packages
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxml2-dev \
    libxslt1-dev \
    libzip-dev \
    nginx \
    git \
    unzip \
    wget \
    cron


RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install pdo_mysql mysqli gd intl soap xsl zip sockets opcache bcmath

# Xdebug config
RUN pecl install xdebug && docker-php-ext-enable xdebug
# Xdebug config
RUN echo 'xdebug.client_host=host.docker.internal' >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo 'xdebug.mode=develop,debug' >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo 'xdebug.start_with_request=yes' >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo 'xdebug.idekey=PHPSTORM' >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo 'xdebug.log=/tmp/xdebug.log' >> /usr/local/etc/php/conf.d/xdebug.ini

# Copy configuration files
COPY docker/nginx/default.conf /etc/nginx/sites-available/default
COPY docker/php-fpm/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY docker/php-fpm/php.ini /usr/local/etc/php/conf.d/php.ini

# Ensure nginx is running as the www-data user
RUN sed -i 's/user\ \ nginx\;/user\ \ www-data\;/g' /etc/nginx/nginx.conf

# Create a script that will start PHP-FPM and Nginx
RUN echo "#!/bin/bash\nphp-fpm & nginx -g \"daemon off;\"" >> /start_services.sh
RUN chmod +x /start_services.sh

# Start services when the container starts
CMD ["/start_services.sh"]

# Expose port 80
EXPOSE 80